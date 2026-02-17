import 'package:futbase_core_datasource/futbase_core_datasource.dart';

/// Repository for authentication operations
///
/// Uses UsuariosDataSource for data operations
class AuthRepository {
  final UsuariosDataSource _usuariosDataSource;

  AuthRepository({UsuariosDataSource? usuariosDataSource})
      : _usuariosDataSource =
            usuariosDataSource ?? UsuariosDataSourceFactory.createSupabase();

  /// Authenticates a user with email and password
  ///
  /// Returns the user entity if authentication succeeds, null otherwise
  Future<UsuariosEntity?> authenticate(
      String email, String password) async {
    return await _usuariosDataSource.authenticate(email, password);
  }

  /// Gets the current user by ID
  Future<UsuariosEntity?> getCurrentUser(String id) async {
    return await _usuariosDataSource.getById(id);
  }

  /// Gets a user by email
  Future<UsuariosEntity?> getUserByEmail(String email) async {
    return await _usuariosDataSource.getByEmail(email);
  }

  /// Gets all users for a club
  Future<List<UsuariosEntity>> getUsersByClub(int clubId) async {
    return await _usuariosDataSource.getByClub(clubId);
  }

  /// Creates a new user
  Future<UsuariosEntity> createUser(UsuariosEntity user) async {
    return await _usuariosDataSource.create(user);
  }

  /// Updates an existing user
  Future<UsuariosEntity> updateUser(UsuariosEntity user) async {
    return await _usuariosDataSource.update(user);
  }

  /// Updates user password
  Future<void> updatePassword(String userId, String newPassword) async {
    await _usuariosDataSource.updatePassword(userId, newPassword);
  }

  /// Streams users for a club (real-time)
  Stream<List<UsuariosEntity>> watchUsersByClub(int clubId) {
    return _usuariosDataSource.watchByClub(clubId);
  }
}
