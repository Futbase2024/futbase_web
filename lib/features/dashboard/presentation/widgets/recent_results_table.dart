import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Tabla de últimos resultados
/// Diseño basado en dashboard_principal_futbase (code.html)
/// Muestra una tabla con los resultados de los últimos partidos
class RecentResultsTable extends StatelessWidget {
  const RecentResultsTable({
    super.key,
    this.results = const [],
    this.onViewAll,
  });

  final List<MatchResultData> results;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Últimos Resultados',
                style: AppTypography.h6.copyWith(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // Navigation arrows
              Row(
                children: [
                  _buildNavButton(Icons.chevron_left, () {}),
                  const SizedBox(width: 8),
                  _buildNavButton(Icons.chevron_right, () {}),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Table
          _buildTable(),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.gray400,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
        4: FlexColumnWidth(1),
      },
      children: [
        // Header row
        TableRow(
          children: [
            _buildHeaderCell('Equipo'),
            _buildHeaderCell('Rival'),
            _buildHeaderCell('Resultado', alignCenter: true),
            _buildHeaderCell('Estado'),
            _buildHeaderCell('Fecha', alignRight: true),
          ],
        ),
        // Data rows
        ...results.map((result) => _buildDataRow(result)),
      ],
    );
  }

  Widget _buildHeaderCell(String text, {bool alignCenter = false, bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.gray400,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 1.5,
        ),
        textAlign: alignCenter
            ? TextAlign.center
            : alignRight
                ? TextAlign.right
                : TextAlign.left,
      ),
    );
  }

  TableRow _buildDataRow(MatchResultData result) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.gray50),
        ),
      ),
      children: [
        _buildDataCell(result.teamName, isBold: true),
        _buildDataCell(result.opponent),
        _buildScoreCell(result.homeScore, result.awayScore),
        _buildStatusCell(result.status),
        _buildDataCell(result.date, alignRight: true),
      ],
    );
  }

  Widget _buildDataCell(String text, {bool isBold = false, bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: isBold ? AppColors.gray900 : AppColors.gray500,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
        ),
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
      ),
    );
  }

  Widget _buildScoreCell(int homeScore, int awayScore) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$homeScore - $awayScore',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCell(MatchStatus status) {
    final (color, bgColor, text) = switch (status) {
      MatchStatus.victory => (const Color(0xFF16A34A), const Color(0xFFDCFCE7), 'VICTORIA'),
      MatchStatus.draw => (const Color(0xFFD97706), const Color(0xFFFEF3C7), 'EMPATE'),
      MatchStatus.defeat => (const Color(0xFFDC2626), const Color(0xFFFEE2E2), 'DERROTA'),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          text,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Estado del partido
enum MatchStatus { victory, draw, defeat }

/// Modelo de resultado de partido
class MatchResultData {
  const MatchResultData({
    required this.teamName,
    required this.opponent,
    required this.homeScore,
    required this.awayScore,
    required this.status,
    required this.date,
  });

  final String teamName;
  final String opponent;
  final int homeScore;
  final int awayScore;
  final MatchStatus status;
  final String date;

  /// Datos de ejemplo
  static const List<MatchResultData> sampleData = [
    MatchResultData(
      teamName: 'Juvenil Nacional',
      opponent: 'Rival A',
      homeScore: 3,
      awayScore: 1,
      status: MatchStatus.victory,
      date: '18 MAY',
    ),
    MatchResultData(
      teamName: 'Infantil A',
      opponent: 'Rival B',
      homeScore: 2,
      awayScore: 2,
      status: MatchStatus.draw,
      date: '18 MAY',
    ),
    MatchResultData(
      teamName: 'Cadete A',
      opponent: 'Rival C',
      homeScore: 0,
      awayScore: 1,
      status: MatchStatus.defeat,
      date: '17 MAY',
    ),
  ];
}
