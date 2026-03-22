import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';

import 'package:futbase_web_3/core/datasources/datasource_factory.dart';
import 'package:futbase_web_3/core/datasources/app_datasource.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AppDataSource _dataSource;

  AuthBloc({AppDataSource? dataSource})
      : _dataSource = dataSource ?? DataSourceFactory.instance,
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

  /// Convierte un Map a UsuariosEntity
  UsuariosEntity? _mapToEntity(Map<String, dynamic>? map) {
    if (map == null) return null;
    try {
      return UsuariosEntity.fromJson(map);
    } catch (e) {
      debugPrint('AuthBloc: Error parsing user: $e');
      return null;
    }
  }

  /// Check current authentication status
  Future<void> _onStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.checking());

    try {
      if (_dataSource.isAuthenticated) {
        final uid = _dataSource.currentUserId;
        if (uid != null) {
          // User is authenticated, get their data
          final userMap = await _dataSource.getUsuarioByUid(uid: uid);
          final user = _mapToEntity(userMap);
          if (user != null) {
            // Obtener idtemporada del appUser (ya viene en la respuesta de auth.php)
            final idTemporada = userMap?['idtemporada'] as int?;
            emit(AuthState.authenticated(user, idTemporada: idTemporada));
          } else {
            emit(AuthState.unauthenticated());
          }
        } else {
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
      final response = await _dataSource.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.success && response.data != null) {
        final uid = response.data!['uid'] as String;
        final userMap = await _dataSource.getUsuarioByUid(uid: uid);
        final user = _mapToEntity(userMap);

        if (user != null) {
          // Obtener idtemporada del appUser (ya viene en la respuesta de auth.php)
          final idTemporada = userMap?['idtemporada'] as int?;
          emit(AuthState.authenticated(user, idTemporada: idTemporada));
        } else {
          // Try to find by email and link
          final userByEmailMap = await _dataSource.getUsuarioByEmail(email: event.email);
          if (userByEmailMap != null) {
            // Update uid in tusuarios
            await _dataSource.updateUsuarioUid(
              userId: userByEmailMap['id'].toString(),
              uid: uid,
            );
            final userByEmail = _mapToEntity(userByEmailMap);
            if (userByEmail != null) {
              // Obtener idtemporada del usuario
              final idTemporada = userByEmailMap['idtemporada'] as int?;
              emit(AuthState.authenticated(userByEmail, idTemporada: idTemporada));
            } else {
              emit(AuthState.unauthenticated());
            }
          } else {
            emit(AuthState.unauthenticated());
          }
        }
      } else {
        // Check if user exists in tusuarios but needs migration
        final message = response.message ?? '';
        if (message.contains('incorrectos') || message.contains('Invalid')) {
          final legacyUserMap = await _dataSource.getUsuarioByEmail(email: event.email);
          if (legacyUserMap != null) {
            // Check if already has UID (already migrated)
            final uid = legacyUserMap['uid'];
            if (uid != null && uid.toString().isNotEmpty) {
              emit(AuthState.error('Email o contraseña incorrectos.'));
              return;
            }
            // User exists but needs migration
            emit(AuthState.needsMigration(
              email: event.email,
              legacyUserId: int.parse(legacyUserMap['id'].toString()),
            ));
            return;
          }
        }

        emit(AuthState.error(_getFriendlyErrorMessage(message)));
      }
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
      // 1. First check if email already exists in tusuarios
      final existingUserMap = await _dataSource.getUsuarioByEmail(email: event.email);

      if (existingUserMap != null) {
        debugPrint('AuthBloc: Usuario ya existe en tusuarios con id=${existingUserMap['id']}');

        // Check if already has UID linked
        final existingUid = existingUserMap['uid'];
        if (existingUid != null && existingUid.toString().isNotEmpty) {
          emit(AuthState.error('Este email ya está registrado. Intenta iniciar sesión.'));
          return;
        }

        // No UID - create in auth and link
        debugPrint('AuthBloc: Usuario existe sin UID, creando en Auth...');
        final response = await _dataSource.signUp(
          email: event.email,
          password: event.password,
        );

        if (response.success && response.data != null) {
          final uid = response.data!['uid'] as String;

          // Update UID in tusuarios
          await _dataSource.updateUsuarioUid(
            userId: existingUserMap['id'].toString(),
            uid: uid,
          );

          // Get updated user
          final updatedUserMap = await _dataSource.getUsuarioById(id: existingUserMap['id'].toString());
          final updatedUser = _mapToEntity(updatedUserMap);
          if (updatedUser != null) {
            // Obtener idtemporada del usuario
            final idTemporada = updatedUserMap?['idtemporada'] as int?;
            emit(AuthState.authenticated(updatedUser, idTemporada: idTemporada));
          } else {
            emit(AuthState.error('Error al actualizar el usuario.'));
          }
        } else {
          emit(AuthState.error(response.message ?? 'No se pudo crear la cuenta.'));
        }
        return;
      }

      // 2. New user - create in auth first
      debugPrint('AuthBloc: Usuario nuevo, creando en Auth...');
      final response = await _dataSource.signUp(
        email: event.email,
        password: event.password,
        nombre: event.nombre,
        apellidos: event.apellidos,
        idclub: event.idclub,
      );

      if (response.success && response.data != null) {
        final uid = response.data!['uid'] as String;

        // 3. Create user in tusuarios
        final createdUserMap = await _dataSource.createUsuario(
          nombre: event.nombre,
          apellidos: event.apellidos,
          email: event.email,
          idclub: event.idclub ?? 0,
          uid: uid,
        );

        if (createdUserMap != null) {
          final createdUser = _mapToEntity(createdUserMap);
          if (createdUser != null) {
            // Obtener idtemporada del usuario creado
            final idTemporada = createdUserMap['idtemporada'] as int?;
            emit(AuthState.authenticated(createdUser, idTemporada: idTemporada));
          } else {
            emit(AuthState.error('No se pudo crear el usuario.'));
          }
        } else {
          emit(AuthState.error('No se pudo crear el usuario.'));
        }
      } else {
        emit(AuthState.error(response.message ?? 'No se pudo crear la cuenta.'));
      }
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
      await _dataSource.signOut();
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
      final response = await _dataSource.resetPasswordForEmail(email: event.email);
      if (response.success) {
        emit(const AuthState()); // Return to initial state
      } else {
        emit(AuthState.error(response.message ?? 'Error al enviar email de recuperación.'));
      }
    } catch (e) {
      emit(AuthState.error('Error al enviar email de recuperación.'));
    }
  }

  /// Migrate legacy user to Auth
  Future<void> _onMigrateLegacyUser(
    AuthMigrateLegacyUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      // Create user in Auth
      final response = await _dataSource.signUp(
        email: event.email,
        password: event.newPassword,
      );

      if (response.success && response.data != null) {
        final uid = response.data!['uid'] as String;

        // Update the uid in tusuarios
        await _dataSource.updateUsuarioUid(
          userId: event.legacyUserId.toString(),
          uid: uid,
        );

        // Get the updated user
        final userMap = await _dataSource.getUsuarioById(id: event.legacyUserId.toString());
        final user = _mapToEntity(userMap);
        if (user != null) {
          // Obtener idtemporada del usuario
          final idTemporada = userMap?['idtemporada'] as int?;
          emit(AuthState.authenticated(user, idTemporada: idTemporada));
        } else {
          emit(AuthState.unauthenticated());
        }
      } else {
        emit(AuthState.error(response.message ?? 'No se pudo completar la migración.'));
      }
    } catch (e) {
      debugPrint('AuthBloc: Migration error: $e');
      emit(AuthState.error('Error en la migración. Intenta de nuevo.'));
    }
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

  /// Convert error message to friendly message
  String _getFriendlyErrorMessage(String message) {
    if (message.contains('Invalid login credentials') ||
        message.contains('incorrectos')) {
      return 'Email o contraseña incorrectos.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Por favor, confirma tu email antes de iniciar sesión.';
    }
    if (message.contains('User already registered') ||
        message.contains('email-already-in-use')) {
      return 'Este email ya está registrado.';
    }
    if (message.contains('Password should be at least') ||
        message.contains('weak-password')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (message.contains('Invalid email')) {
      return 'El formato del email no es válido.';
    }
    return message;
  }
}
