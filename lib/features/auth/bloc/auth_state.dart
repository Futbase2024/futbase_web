import 'package:equatable/equatable.dart';
import 'package:futbase_core_datasource/futbase_core_datasource.dart';

import '../../../core/constants/user_roles.dart';

enum AuthStatus {
  initial,
  checking,
  authenticated,
  unauthenticated,
  needsMigration, // Legacy user without Supabase Auth account
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UsuariosEntity? user;
  final String? errorMessage;
  final bool isLoading;
  final int? idTemporada; // Temporada actual desde tconfig

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
    this.idTemporada,
  });

  // Factory constructors for different states
  const factory AuthState.initial() = AuthState;

  factory AuthState.checking() => const AuthState(status: AuthStatus.checking);

  factory AuthState.authenticated(UsuariosEntity user, {int? idTemporada}) =>
      AuthState(
        status: AuthStatus.authenticated,
        user: user,
        idTemporada: idTemporada,
      );

  factory AuthState.unauthenticated() => const AuthState(
        status: AuthStatus.unauthenticated,
      );

  factory AuthState.needsMigration({
    required String email,
    required int legacyUserId,
  }) =>
      AuthState(
        status: AuthStatus.needsMigration,
        errorMessage: email,
        user: UsuariosEntity(
          id: legacyUserId.toString(),
          nombre: '',
          apellidos: '',
          email: email,
          idclub: 0,
          idequipo: 0,
          permisos: 0,
          createdAt: DateTime.now(),
        ),
      );

  factory AuthState.error(String message) => AuthState(
        status: AuthStatus.error,
        errorMessage: message,
      );

  factory AuthState.loading() => const AuthState(isLoading: true);

  // Computed properties
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get needsPasswordMigration => status == AuthStatus.needsMigration;
  bool get hasError => status == AuthStatus.error;

  // Get email for migration
  String? get migrationEmail =>
      status == AuthStatus.needsMigration ? errorMessage : null;

  // Get legacy user ID for migration
  int? get legacyUserId =>
      status == AuthStatus.needsMigration ? int.tryParse(user?.id ?? '') : null;

  /// Get user role from permisos
  UserRole? get role {
    if (user == null) return null;
    return UserRole.fromPermisos(user!.permisos);
  }

  /// Get user role or default
  UserRole get roleOrDefault => role ?? UserRole.entrenador;

  @override
  List<Object?> get props => [status, user, errorMessage, isLoading, idTemporada];

  AuthState copyWith({
    AuthStatus? status,
    UsuariosEntity? user,
    String? errorMessage,
    bool? isLoading,
    int? idTemporada,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      idTemporada: idTemporada ?? this.idTemporada,
    );
  }
}
