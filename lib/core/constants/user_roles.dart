/// Roles de usuario en FutBase Web
///
/// Niveles de permisos según la base de datos:
/// - 1: SuperAdmin - Acceso total al sistema
/// - 2: Entrenador - Gestión de equipos y jugadores
/// - 3: Club - Administración de club
/// - 10: Coordinador - Coordinación de categorías/equipos
enum UserRole {
  /// Acceso total, gestión de todos los clubs y usuarios
  superAdmin(1, 'Super Admin', 'Administrador total del sistema'),

  /// Gestión de equipos, jugadores, entrenamientos y partidos
  entrenador(2, 'Entrenador', 'Gestión de equipos y jugadores'),

  /// Administración de club, usuarios y configuración
  club(3, 'Club', 'Administración del club'),

  /// Coordinación de categorías y equipos
  coordinador(10, 'Coordinador', 'Coordinación de categorías');

  const UserRole(this.permisos, this.displayName, this.description);

  /// Nivel de permisos en la base de datos
  final int permisos;

  /// Nombre para mostrar en la UI
  final String displayName;

  /// Descripción del rol
  final String description;

  /// Convierte un nivel de permisos a UserRole
  /// Si el permiso no está definido, retorna null
  static UserRole? fromPermisos(int permisos) {
    for (final role in UserRole.values) {
      if (role.permisos == permisos) {
        return role;
      }
    }
    return null;
  }

  /// Convierte un nivel de permisos a UserRole
  /// Si el permiso no está definido, retorna el rol más bajo
  static UserRole fromPermisosOrDefault(int permisos) {
    return fromPermisos(permisos) ?? UserRole.entrenador;
  }
}

/// Extensión para verificar permisos específicos
extension UserRolePermissions on UserRole {
  /// Puede gestionar todos los clubs
  bool get canManageAllClubs => this == UserRole.superAdmin;

  /// Puede gestionar usuarios
  bool get canManageUsers =>
      this == UserRole.superAdmin || this == UserRole.club;

  /// Puede gestionar equipos
  bool get canManageTeams =>
      this == UserRole.superAdmin ||
      this == UserRole.club ||
      this == UserRole.coordinador ||
      this == UserRole.entrenador;

  /// Puede ver estadísticas globales
  bool get canViewGlobalStats =>
      this == UserRole.superAdmin ||
      this == UserRole.club ||
      this == UserRole.coordinador;

  /// Puede gestionar entrenamientos
  bool get canManageTrainings =>
      this == UserRole.superAdmin ||
      this == UserRole.club ||
      this == UserRole.coordinador ||
      this == UserRole.entrenador;

  /// Puede gestionar partidos
  bool get canManageMatches =>
      this == UserRole.superAdmin ||
      this == UserRole.club ||
      this == UserRole.coordinador ||
      this == UserRole.entrenador;

  /// Puede ver Dashboard completo
  bool get hasFullDashboard => this == UserRole.superAdmin;

  /// Puede ver resultados de partidos
  bool get canViewResults =>
      this == UserRole.superAdmin ||
      this == UserRole.club ||
      this == UserRole.coordinador ||
      this == UserRole.entrenador;

  /// Puede ver informes
  bool get canViewReports =>
      this == UserRole.superAdmin ||
      this == UserRole.club ||
      this == UserRole.coordinador ||
      this == UserRole.entrenador;

  /// Puede cambiar de temporada
  bool get canChangeSeason =>
      this == UserRole.superAdmin ||
      this == UserRole.club ||
      this == UserRole.coordinador ||
      this == UserRole.entrenador;
}
