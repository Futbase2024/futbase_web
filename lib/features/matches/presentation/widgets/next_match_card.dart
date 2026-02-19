import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Tarjeta destacada del próximo encuentro con countdown
class NextMatchCard extends StatefulWidget {
  const NextMatchCard({
    super.key,
    required this.match,
    required this.competition,
    required this.onConvocatoria,
    required this.onLineup,
    required this.onEdit,
  });

  final Map<String, dynamic> match;
  final String? competition;
  final VoidCallback onConvocatoria;
  final VoidCallback onLineup;
  final VoidCallback onEdit;

  @override
  State<NextMatchCard> createState() => _NextMatchCardState();
}

class _NextMatchCardState extends State<NextMatchCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateRemaining() {
    final fecha = _parseDate(widget.match['fecha']);
    // Campo 'hora' de vpartido (ej: "10:00")
    final horaStr = widget.match['hora']?.toString() ?? '10:00';

    if (fecha != null) {
      // Parsear hora (formato "HH:mm")
      final horaParts = horaStr.split(':');
      final hora = int.tryParse(horaParts.elementAtOrNull(0) ?? '10') ?? 10;
      final minuto = int.tryParse(horaParts.elementAtOrNull(1) ?? '00') ?? 0;

      final matchDateTime = DateTime(fecha.year, fecha.month, fecha.day, hora, minuto);
      _remaining = matchDateTime.difference(DateTime.now());
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _calculateRemaining();
        setState(() {});
      }
    });
  }

  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    return DateTime.tryParse(dateValue.toString());
  }

  @override
  Widget build(BuildContext context) {
    final rival = widget.match['rival']?.toString() ?? 'Sin rival';
    // casafuera: 1 = visitante, 0 o null = local (campo de vpartido)
    final casafuera = widget.match['casafuera'];
    final local = !(casafuera == 1 || casafuera == true);
    final fecha = _parseDate(widget.match['fecha']);
    // Campo 'campo' de vpartido (nombre del estadio/campo)
    final campo = widget.match['campo']?.toString();
    // Campo 'hora' de vpartido
    final hora = widget.match['hora']?.toString();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withBlue(180),
          ],
        ),
        borderRadius: AppSpacing.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            local ? Icons.home : Icons.flight_takeoff,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            local ? 'LOCAL' : 'VISITANTE',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.competition != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.competition!,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'PRÓXIMO ENCUENTRO',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Equipos y countdown
            Row(
              children: [
                // Equipo local
                Expanded(
                  child: _TeamInfo(
                    name: local
                        ? (widget.match['ncortoclub'] ?? widget.match['club'] ?? 'Mi Equipo')
                        : rival,
                    isLocal: local,
                    isMyTeam: local,
                    escudoUrl: local
                        ? widget.match['escudo']?.toString()
                        : widget.match['escudorival']?.toString(),
                  ),
                ),

                // Countdown o VS
                _buildCountdown(),

                // Equipo visitante
                Expanded(
                  child: _TeamInfo(
                    name: local
                        ? rival
                        : (widget.match['ncortoclub'] ?? widget.match['club'] ?? 'Mi Equipo'),
                    isLocal: !local,
                    isMyTeam: !local,
                    escudoUrl: local
                        ? widget.match['escudorival']?.toString()
                        : widget.match['escudo']?.toString(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Info del partido: Fecha (flex 2) | Campo (flex 6) | Hora (flex 2)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              child: Row(
                children: [
                  // Fecha - flex 2
                  Expanded(
                    flex: 2,
                    child: _InfoItem(
                      icon: Icons.calendar_today,
                      label: 'Fecha',
                      value: fecha != null ? DateFormat('dd/MM/yyyy').format(fecha) : 'Por definir',
                    ),
                  ),
                  Container(
                    height: 32,
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  // Campo - flex 6
                  if (campo != null && campo.isNotEmpty)
                    Expanded(
                      flex: 6,
                      child: _InfoItem(
                        icon: Icons.location_on,
                        label: 'Campo',
                        value: campo,
                      ),
                    ),
                  if (hora != null && hora.isNotEmpty) ...[
                    Container(
                      height: 32,
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    // Hora - flex 2
                    Expanded(
                      flex: 2,
                      child: _InfoItem(
                        icon: Icons.access_time,
                        label: 'Hora',
                        value: hora,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Botones de acción: Convocatoria, Alineación, Editar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onConvocatoria,
                    icon: const Icon(Icons.people_alt, size: 18),
                    label: const Text('Convocatoria'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.borderRadiusMd,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onLineup,
                    icon: const Icon(Icons.group, size: 18),
                    label: const Text('Alineación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.borderRadiusMd,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.borderRadiusMd,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    if (_remaining.isNegative) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            Text(
              'VS',
              style: AppTypography.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'En curso',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CountdownUnit(value: days, label: 'D'),
          _CountdownSeparator(),
          _CountdownUnit(value: hours, label: 'H'),
          _CountdownSeparator(),
          _CountdownUnit(value: minutes, label: 'M'),
          _CountdownSeparator(),
          _CountdownUnit(value: seconds, label: 'S'),
        ],
      ),
    );
  }
}

class _TeamInfo extends StatelessWidget {
  const _TeamInfo({
    required this.name,
    required this.isLocal,
    required this.isMyTeam,
    this.escudoUrl,
  });

  final String name;
  final bool isLocal;
  final bool isMyTeam;
  final String? escudoUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: escudoUrl != null && escudoUrl!.isNotEmpty
              ? Image.network(
                  escudoUrl!,
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: isMyTeam
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: Icon(
                      isMyTeam ? Icons.shield : Icons.shield_outlined,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isMyTeam ? Icons.shield : Icons.shield_outlined,
                        size: 32,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    );
                  },
                )
              : Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: isMyTeam
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                  child: Icon(
                    isMyTeam ? Icons.shield : Icons.shield_outlined,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: isMyTeam ? FontWeight.w700 : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  const _CountdownUnit({
    required this.value,
    required this.label,
  });

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: AppTypography.h5.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _CountdownSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        ':',
        style: AppTypography.h5.copyWith(
          color: Colors.white60,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.white70,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
