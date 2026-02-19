import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check current authentication status
class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

/// Login with email and password
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Register new user
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String nombre;
  final String apellidos;
  final int idclub;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.nombre,
    required this.apellidos,
    required this.idclub,
  });

  @override
  List<Object?> get props => [email, password, nombre, apellidos, idclub];
}

/// Logout
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Password reset requested
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Migrate legacy user (from tusuarios table)
class AuthMigrateLegacyUser extends AuthEvent {
  final String email;
  final String newPassword;
  final int legacyUserId;

  const AuthMigrateLegacyUser({
    required this.email,
    required this.newPassword,
    required this.legacyUserId,
  });

  @override
  List<Object?> get props => [email, newPassword, legacyUserId];
}

/// Change current season (temporada)
class AuthTemporadaChanged extends AuthEvent {
  final int idTemporada;

  const AuthTemporadaChanged({required this.idTemporada});

  @override
  List<Object?> get props => [idTemporada];
}
