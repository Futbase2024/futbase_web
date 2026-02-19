import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:futbase_core_datasource/futbase_core_datasource.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabase;
  final UsuariosDataSource _usuariosDataSource;

  AuthBloc({
    SupabaseClient? supabase,
    UsuariosDataSource? usuariosDataSource,
  })  : _supabase = supabase ?? Supabase.instance.client,
        _usuariosDataSource =
            usuariosDataSource ?? UsuariosDataSourceFactory.createSupabase(),
        super(const AuthState.initial()) {
    on<AuthStatusChecked>(_onStatusChecked);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthMigrateLegacyUser>(_onMigrateLegacyUser);
    on<AuthTemporadaChanged>(_onTemporadaChanged);

    // Check auth status on init
    add(const AuthStatusChecked());
  }

  /// Check current authentication status
  Future<void> _onStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.checking());

    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        // User is authenticated in Supabase, get their data from tusuarios
        final user = await _getUsuarioByUid(session.user.id);
        if (user != null) {
          // Obtener temporada actual desde tconfig
          final idTemporada = await _getCurrentTemporada();
          emit(AuthState.authenticated(user, idTemporada: idTemporada));
        } else {
          // User exists in Supabase Auth but not in tusuarios
          // This shouldn't happen, but handle gracefully
          emit(AuthState.unauthenticated());
        }
      } else {
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      debugPrint('AuthBloc: Error checking status: $e');
      emit(AuthState.unauthenticated());
    }
  }

  /// Handle login request
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      // Try Supabase Auth first
      final response = await _supabase.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        // Login successful in Supabase Auth
        final user = await _getUsuarioByUid(response.user!.id);
        if (user != null) {
          // Obtener temporada actual desde tconfig
          final idTemporada = await _getCurrentTemporada();
          emit(AuthState.authenticated(user, idTemporada: idTemporada));
        } else {
          // Try to find by email and link
          final userByEmail = await _usuariosDataSource.getByEmail(event.email);
          if (userByEmail != null) {
            // Update uid in tusuarios
            await _updateUsuarioUid(userByEmail.id, response.user!.id);
            // Obtener temporada actual desde tconfig
            final idTemporada = await _getCurrentTemporada();
            emit(AuthState.authenticated(userByEmail, idTemporada: idTemporada));
          } else {
            emit(AuthState.unauthenticated());
          }
        }
      }
    } on AuthException catch (e) {
      debugPrint('AuthBloc: AuthException: ${e.message}');

      // Check if it's because user doesn't exist in Supabase Auth
      if (e.message.contains('Invalid login credentials')) {
        // Check if user exists in legacy tusuarios table
        debugPrint('AuthBloc: Checking legacy user for email: ${event.email}');
        try {
          final legacyUser = await _usuariosDataSource.getByEmail(event.email);
          debugPrint('AuthBloc: Legacy user result: ${legacyUser?.email ?? "null"}');
          if (legacyUser != null) {
            // User exists in tusuarios but not in Supabase Auth
            // They need to migrate
            debugPrint('AuthBloc: Emitting needsMigration state');
            emit(AuthState.needsMigration(
              email: event.email,
              legacyUserId: int.parse(legacyUser.id),
            ));
            return;
          }
        } catch (legacyError) {
          debugPrint('AuthBloc: Error checking legacy user: $legacyError');
        }
      }

      emit(AuthState.error(_getFriendlyErrorMessage(e.message)));
    } catch (e) {
      debugPrint('AuthBloc: Error: $e');
      emit(AuthState.error('Error inesperado. Intenta de nuevo.'));
    }
  }

  /// Handle register request
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      // Create user in Supabase Auth
      final response = await _supabase.auth.signUp(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        // Create user in tusuarios table
        final newUser = UsuariosEntity(
          id: '0', // Will be assigned by database
          nombre: event.nombre,
          apellidos: event.apellidos,
          email: event.email,
          idclub: event.idclub,
          idequipo: 0,
          permisos: 1, // Default permission level
          uid: response.user!.id,
          createdAt: DateTime.now(),
        );

        final createdUser = await _usuariosDataSource.create(newUser);
        // Obtener temporada actual desde tconfig
        final idTemporada = await _getCurrentTemporada();
        emit(AuthState.authenticated(createdUser, idTemporada: idTemporada));
      } else {
        emit(AuthState.error('No se pudo crear la cuenta.'));
      }
    } on AuthException catch (e) {
      emit(AuthState.error(_getFriendlyErrorMessage(e.message)));
    } catch (e) {
      debugPrint('AuthBloc: Register error: $e');
      emit(AuthState.error('Error al registrar. Intenta de nuevo.'));
    }
  }

  /// Handle logout request
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _supabase.auth.signOut();
      emit(AuthState.unauthenticated());
    } catch (e) {
      debugPrint('AuthBloc: Logout error: $e');
      emit(AuthState.unauthenticated());
    }
  }

  /// Handle password reset request
  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      await _supabase.auth.resetPasswordForEmail(event.email);
      emit(const AuthState()); // Return to initial state
    } on AuthException catch (e) {
      emit(AuthState.error(_getFriendlyErrorMessage(e.message)));
    } catch (e) {
      emit(AuthState.error('Error al enviar email de recuperación.'));
    }
  }

  /// Migrate legacy user to Supabase Auth
  Future<void> _onMigrateLegacyUser(
    AuthMigrateLegacyUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      // Create user in Supabase Auth
      final response = await _supabase.auth.signUp(
        email: event.email,
        password: event.newPassword,
      );

      if (response.user != null) {
        // Update the uid in tusuarios
        await _updateUsuarioUid(
          event.legacyUserId.toString(),
          response.user!.id,
        );

        // Get the updated user
        final user = await _usuariosDataSource.getById(event.legacyUserId.toString());
        if (user != null) {
          // Obtener temporada actual desde tconfig
          final idTemporada = await _getCurrentTemporada();
          emit(AuthState.authenticated(user, idTemporada: idTemporada));
        } else {
          emit(AuthState.unauthenticated());
        }
      } else {
        emit(AuthState.error('No se pudo completar la migración.'));
      }
    } on AuthException catch (e) {
      emit(AuthState.error(_getFriendlyErrorMessage(e.message)));
    } catch (e) {
      debugPrint('AuthBloc: Migration error: $e');
      emit(AuthState.error('Error en la migración. Intenta de nuevo.'));
    }
  }

  /// Get usuario from tusuarios by Supabase UID
  /// Also loads the active role from troles where selectedrol = 1
  Future<UsuariosEntity?> _getUsuarioByUid(String uid) async {
    try {
      // First get the user from tusuarios
      final userResponse = await _supabase
          .from('tusuarios')
          .select()
          .eq('uid', uid)
          .maybeSingle();

      if (userResponse == null) {
        return null;
      }

      // Then get the active role from troles
      final rolResponse = await _supabase
          .from('troles')
          .select()
          .eq('uid', uid)
          .eq('selectedrol', 1)
          .maybeSingle();

      // If there's an active role, use its values for idclub, idequipo, and tipo
      if (rolResponse != null) {
        debugPrint('AuthBloc: Found active role - tipo: ${rolResponse['tipo']}, idclub: ${rolResponse['idclub']}, idequipo: ${rolResponse['idequipo']}');

        // Merge the role data into the user data
        userResponse['idclub'] = rolResponse['idclub'] ?? userResponse['idclub'];
        userResponse['idequipo'] = rolResponse['idequipo'] ?? userResponse['idequipo'];
        userResponse['permisos'] = rolResponse['tipo'] ?? userResponse['permisos'];
      } else {
        debugPrint('AuthBloc: No active role found (selectedrol=1), using default values from tusuarios');
      }

      return UsuariosEntity.fromJson(userResponse);
    } catch (e) {
      debugPrint('AuthBloc: Error getting user by uid: $e');
      return null;
    }
  }

  /// Update UID in tusuarios and troles tables
  Future<void> _updateUsuarioUid(String userId, String uid) async {
    try {
      final userIdInt = int.parse(userId);

      // Update tusuarios
      await _supabase
          .from('tusuarios')
          .update({'uid': uid})
          .eq('id', userIdInt);

      // Update troles
      await _supabase
          .from('troles')
          .update({'uid': uid})
          .eq('idusuario', userIdInt);

      debugPrint('AuthBloc: Updated uid=$uid in tusuarios and troles for userId=$userIdInt');
    } catch (e) {
      debugPrint('AuthBloc: Error updating uid: $e');
    }
  }

  /// Convert Supabase error to friendly message
  String _getFriendlyErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email o contraseña incorrectos.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Por favor, confirma tu email antes de iniciar sesión.';
    }
    if (message.contains('User already registered')) {
      return 'Este email ya está registrado.';
    }
    if (message.contains('Password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (message.contains('Invalid email')) {
      return 'El formato del email no es válido.';
    }
    return message;
  }

  /// Handle temporada change request
  void _onTemporadaChanged(
    AuthTemporadaChanged event,
    Emitter<AuthState> emit,
  ) {
    final currentState = state;
    if (currentState.isAuthenticated && currentState.user != null) {
      debugPrint('AuthBloc: Changing temporada to ${event.idTemporada}');
      emit(currentState.copyWith(idTemporada: event.idTemporada));
    }
  }

  /// Get current temporada from tconfig
  Future<int?> _getCurrentTemporada() async {
    try {
      final response = await _supabase
          .from('tconfig')
          .select('idtemporada')
          .limit(1)
          .maybeSingle();

      if (response != null) {
        final idTemporada = response['idtemporada'] as int?;
        debugPrint('AuthBloc: Current temporada from tconfig: $idTemporada');
        return idTemporada;
      }
      return null;
    } catch (e) {
      debugPrint('AuthBloc: Error getting current temporada: $e');
      return null;
    }
  }
}
