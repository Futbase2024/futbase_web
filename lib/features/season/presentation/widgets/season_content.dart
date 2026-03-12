import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/config/app_config_cubit.dart';

/// Modelo simple para temporada
class SeasonModel {
  final int id;
  final int idtemporada;
  final String temporada;

  const SeasonModel({
    required this.id,
    required this.idtemporada,
    required this.temporada,
  });

  factory SeasonModel.fromJson(Map<String, dynamic> json) {
    return SeasonModel(
      id: json['id'] as int,
      idtemporada: json['idtemporada'] as int,
      temporada: json['temporada'] as String,
    );
  }
}

/// Contenido para el cambio de temporada
class SeasonContent extends StatefulWidget {
  const SeasonContent({super.key});

  @override
  State<SeasonContent> createState() => _SeasonContentState();
}

class _SeasonContentState extends State<SeasonContent> {
  List<SeasonModel> _seasons = [];
  bool _isLoading = true;
  String? _error;
  int? _changingToSeasonId;

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  Future<void> _loadSeasons() async {
    try {
      final response = await Supabase.instance.client
          .from('ttemporadas')
          .select()
          .order('idtemporada', ascending: false);

      setState(() {
        _seasons = (response as List)
            .map((json) => SeasonModel.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _changeSeason(SeasonModel season) async {
    setState(() {
      _changingToSeasonId = season.idtemporada;
    });

    try {
      // Actualizar solo en memoria (AppConfigCubit)
      // NO tocar tconfig - eso es solo para el admin
      if (mounted) {
        context.read<AppConfigCubit>().setActiveSeason(
              season.idtemporada,
              season.temporada,
            );

        // Mostrar confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Temporada cambiada a ${season.temporada}'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _changingToSeasonId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppConfigCubit, AppConfigState>(
      builder: (context, configState) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(configState),
              const SizedBox(height: 32),

              // Content
              Expanded(
                child: _buildContent(configState),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppConfigState configState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cambio de Temporada',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selecciona la temporada activa para el club',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Current season badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Temporada actual: ${configState.activeSeasonName}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(AppConfigState configState) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar las temporadas',
              style: AppTypography.h6.copyWith(color: AppColors.gray900),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.gray500),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadSeasons,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_seasons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: AppColors.gray300,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay temporadas disponibles',
              style: AppTypography.h6.copyWith(color: AppColors.gray500),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Temporadas disponibles',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.gray700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: _seasons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final season = _seasons[index];
              final isCurrentSeason =
                  season.idtemporada == configState.activeSeasonId;
              final isChanging = _changingToSeasonId == season.idtemporada;

              return _SeasonCard(
                season: season,
                isCurrentSeason: isCurrentSeason,
                isChanging: isChanging,
                onTap: isCurrentSeason || isChanging
                    ? null
                    : () => _changeSeason(season),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Tarjeta individual de temporada
class _SeasonCard extends StatelessWidget {
  const _SeasonCard({
    required this.season,
    required this.isCurrentSeason,
    required this.isChanging,
    this.onTap,
  });

  final SeasonModel season;
  final bool isCurrentSeason;
  final bool isChanging;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isCurrentSeason
                ? AppColors.primary.withValues(alpha: 0.05)
                : AppColors.white,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: isCurrentSeason
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.gray200,
              width: isCurrentSeason ? 2 : 1,
            ),
            boxShadow: isCurrentSeason
                ? null
                : [
                    BoxShadow(
                      color: AppColors.gray900.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Icon/Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCurrentSeason
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.gray100,
                  shape: BoxShape.circle,
                ),
                child: isChanging
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : Icon(
                        isCurrentSeason
                            ? Icons.check_circle
                            : Icons.calendar_today_outlined,
                        color: isCurrentSeason
                            ? AppColors.primary
                            : AppColors.gray400,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 16),

              // Season info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      season.temporada,
                      style: AppTypography.h6.copyWith(
                        color: isCurrentSeason
                            ? AppColors.primary
                            : AppColors.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCurrentSeason ? 'Temporada activa' : 'Click para activar',
                      style: AppTypography.bodySmall.copyWith(
                        color: isCurrentSeason
                            ? AppColors.primary.withValues(alpha: 0.8)
                            : AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow or check
              if (!isCurrentSeason && !isChanging)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.gray400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
