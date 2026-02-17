import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';

/// Widget del próximo partido con countdown
/// Diseño modo claro basado en dashboard-blanco.html
/// Muestra información del próximo partido con temporizador en tiempo real
class UpcomingMatchCard extends StatefulWidget {
  const UpcomingMatchCard({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchDateTime,
    this.venue,
  });

  final String homeTeam;
  final String awayTeam;
  final DateTime matchDateTime;
  final String? venue;

  @override
  State<UpcomingMatchCard> createState() => _UpcomingMatchCardState();
}

class _UpcomingMatchCardState extends State<UpcomingMatchCard> {
  Timer? _timer;
  late Duration _timeRemaining;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.matchDateTime.difference(DateTime.now());
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _timeRemaining = widget.matchDateTime.difference(DateTime.now());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppSpacing.borderRadiusXl,
        border: Border.all(color: AppColors.gray100),
        boxShadow: AppColors.cardShadowLight,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLg),
              ),
              border: Border(
                bottom: BorderSide(color: context.borderColor),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  color: context.primaryColor,
                  size: AppSpacing.iconSm,
                ),
                const SizedBox(width: 8),
                Text(
                  'Próximo Partido',
                  style: AppTypography.labelMedium.copyWith(
                    color: context.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Teams
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTeamWidget(context, widget.homeTeam, isHome: true),
                    _buildVsWidget(context),
                    _buildTeamWidget(context, widget.awayTeam, isHome: false),
                  ],
                ),
                const SizedBox(height: 24),
                // Countdown
                _buildCountdown(context),
                const SizedBox(height: 16),
                // Venue info
                if (widget.venue != null) _buildVenueInfo(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamWidget(BuildContext context, String name, {required bool isHome}) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.gray50,
            shape: BoxShape.circle,
            border: Border.all(color: context.borderColor),
          ),
          child: Center(
            child: Icon(
              isHome ? Icons.shield : Icons.shield_outlined,
              color: isHome ? context.primaryColor : AppColors.gray300,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: AppTypography.labelSmall.copyWith(
            color: context.textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildVsWidget(BuildContext context) {
    return Text(
      'VS',
      style: AppTypography.h6.copyWith(
        color: AppColors.gray300,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildCountdown(BuildContext context) {
    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTimeUnit(context, days.toString().padLeft(2, '0'), 'Días'),
        _buildTimeUnit(context, hours.toString().padLeft(2, '0'), 'Horas'),
        _buildTimeUnit(context, minutes.toString().padLeft(2, '0'), 'Min'),
        _buildTimeUnit(context, seconds.toString().padLeft(2, '0'), 'Seg'),
      ],
    );
  }

  Widget _buildTimeUnit(BuildContext context, String value, String label) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        border: Border.all(color: context.borderColor),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.statMedium.copyWith(
              color: context.primaryColor,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: context.textSecondaryColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        border: Border.all(color: context.borderColor),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: context.primaryColor,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                widget.venue!,
                style: AppTypography.caption.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: context.primaryColor,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDateTime(widget.matchDateTime),
                style: AppTypography.caption.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${weekdays[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} PM';
  }
}
