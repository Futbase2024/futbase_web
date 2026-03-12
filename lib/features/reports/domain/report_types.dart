/// Tipos de informes disponibles en la aplicación
enum ReportType {
  player('Informe de Jugador', 'Estadísticas individuales del jugador'),
  match('Informe de Partido', 'Resumen completo del partido'),
  convocatoria('Informe de Convocatoria', 'Jugadores convocados y alineación'),
  attendanceMonthly('Asistencia Mensual', 'Asistencia a entrenamientos por mes'),
  teamStats('Estadísticas de Equipo', 'Estadísticas agregadas del equipo');

  final String title;
  final String description;

  const ReportType(this.title, this.description);
}

/// Períodos predefinidos para filtros
enum ReportPeriod {
  week('Última semana', 7),
  month('Último mes', 30),
  quarter('Último trimestre', 90),
  season('Temporada actual', 0),
  custom('Personalizado', 0);

  final String label;
  final int days;

  const ReportPeriod(this.label, this.days);

  /// Calcula la fecha de inicio basándose en el período
  DateTime getStartDate(DateTime referenceDate, {int? seasonStartYear}) {
    switch (this) {
      case ReportPeriod.week:
        return referenceDate.subtract(const Duration(days: 7));
      case ReportPeriod.month:
        return referenceDate.subtract(const Duration(days: 30));
      case ReportPeriod.quarter:
        return referenceDate.subtract(const Duration(days: 90));
      case ReportPeriod.season:
        // Temporada empieza en septiembre del año dado
        final year = seasonStartYear ?? (referenceDate.month >= 9
            ? referenceDate.year
            : referenceDate.year - 1);
        return DateTime(year, 9, 1);
      case ReportPeriod.custom:
        return referenceDate; // Se maneja con fromDate/toDate
    }
  }
}
