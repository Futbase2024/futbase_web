import 'package:flutter/material.dart';

import '../../domain/report_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Vista del informe de partido
class MatchReportView extends StatelessWidget {
  const MatchReportView({
    super.key,
    required this.data,
    required this.teamId,
    required this.onBack,
    required this.onExportPdf,
    required this.onExportExcel,
  });

  final MatchReportData data;
  final int teamId;
  final VoidCallback onBack;
  final VoidCallback onExportPdf;
  final VoidCallback onExportExcel;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScoreCard(),
                const SizedBox(height: 24),
                _buildEventsSection(),
                const SizedBox(height: 24),
                _buildConvocatoriaSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              foregroundColor: AppColors.gray700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Informe de Partido',
            style: AppTypography.h5.copyWith(
              color: AppColors.gray900,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: onExportExcel,
            icon: const Icon(Icons.table_chart, size: 18),
            label: const Text('Excel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: onExportPdf,
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    final resultColor = data.isWin
        ? AppColors.success
        : data.isLoss
            ? AppColors.error
            : AppColors.gray500;

    final resultText = data.isWin
        ? 'Victoria'
        : data.isLoss
            ? 'Derrota'
            : 'Empate';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          // Competición y jornada
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (data.competition != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    data.competition!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              if (data.matchday != null) ...[
                const SizedBox(width: 8),
                Text(
                  'Jornada ${data.matchday}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Marcador
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Equipo local
              Expanded(
                child: Column(
                  children: [
                    Text(
                      data.isHome ? 'FUTBASE' : data.rival.toUpperCase(),
                      style: AppTypography.h6.copyWith(
                        color: data.isHome ? AppColors.primary : AppColors.gray700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Goles
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      data.teamScore.toString(),
                      style: AppTypography.h2.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '-',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.gray400,
                        ),
                      ),
                    ),
                    Text(
                      data.rivalScore.toString(),
                      style: AppTypography.h2.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Equipo visitante
              Expanded(
                child: Column(
                  children: [
                    Text(
                      data.isHome ? data.rival.toUpperCase() : 'FUTBASE',
                      style: AppTypography.h6.copyWith(
                        color: data.isHome ? AppColors.gray700 : AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Resultado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: resultColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              resultText,
              style: AppTypography.labelMedium.copyWith(
                color: resultColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
    if (data.events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sports_soccer,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Eventos del partido',
                style: AppTypography.h6.copyWith(
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...data.events.map((event) => _buildEventItem(event)),
        ],
      ),
    );
  }

  Widget _buildEventItem(MatchEventDetail event) {
    final icon = _getEventIcon(event.eventType);
    final color = _getEventColor(event.eventType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          if (event.minute != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "${event.minute}'",
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              event.playerName,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray900,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              event.eventType,
              style: AppTypography.labelSmall.copyWith(
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(String type) {
    return switch (type.toLowerCase()) {
      'gol' => Icons.sports_soccer,
      'asistencia' => Icons.assistant_direction,
      'amarilla' => Icons.warning_amber,
      'roja' => Icons.dangerous,
      _ => Icons.circle,
    };
  }

  Color _getEventColor(String type) {
    return switch (type.toLowerCase()) {
      'gol' => AppColors.success,
      'asistencia' => AppColors.accent,
      'amarilla' => AppColors.warning,
      'roja' => AppColors.error,
      _ => AppColors.gray500,
    };
  }

  Widget _buildConvocatoriaSection() {
    if (data.convocatoria.isEmpty) {
      return const SizedBox.shrink();
    }

    final starters = data.convocatoria.where((p) => p.isStarter).toList();
    final substitutes = data.convocatoria.where((p) => !p.isStarter && p.isConvoked).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Alineación',
                style: AppTypography.h6.copyWith(
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Titulares
          Text(
            'Titulares',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: starters.map((p) => _buildPlayerChip(p, isStarter: true)).toList(),
          ),

          if (substitutes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Suplentes',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.gray600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: substitutes.map((p) => _buildPlayerChip(p, isStarter: false)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerChip(ConvocadoPlayer player, {required bool isStarter}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isStarter
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.gray100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isStarter
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.gray200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (player.dorsal != null) ...[
            Text(
              '#${player.dorsal}',
              style: AppTypography.labelSmall.copyWith(
                color: isStarter ? AppColors.primary : AppColors.gray600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            player.fullName,
            style: AppTypography.labelSmall.copyWith(
              color: isStarter ? AppColors.primary : AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }
}
