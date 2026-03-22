import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Header del perfil de jugador con foto, 3 cards de información y notas
///
/// Diseño adaptado del proyecto antiguo (FutbaseWeb/futbaseweb2025):
/// - Foto del jugador con altura igual a las cards
/// - 3 cards: Personal, Deportiva, Físico/Médico
/// - Sección de notas a la derecha (layout completo)
class PlayerProfileHeader extends StatelessWidget {
  const PlayerProfileHeader({
    super.key,
    required this.player,
    required this.position,
    this.onBack,
    this.onNoteChanged,
  });

  final Map<String, dynamic> player;
  final String position;
  final VoidCallback? onBack;
  final ValueChanged<String>? onNoteChanged;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenWidth < 1200;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isSmallScreen
          ? _buildCompactLayout(context)
          : _buildFullLayout(context),
    );
  }

  Widget _buildFullLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Foto del jugador
        _buildPlayerAvatar(context),
        const SizedBox(width: 24),
        // 3 Cards de información
        Expanded(
          flex: 3,
          child: _buildPlayerInfo(),
        ),
        const SizedBox(width: 24),
        // Sección de notas
        SizedBox(
          width: 300,
          child: _buildNotesSection(),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Column(
      children: [
        // Botón volver si existe
        if (onBack != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.gray600,
                  onPressed: onBack,
                  tooltip: 'Volver a la lista',
                ),
              ],
            ),
          ),
        // Foto y nombre
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlayerAvatar(context),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlayerName(),
                  const SizedBox(height: 8),
                  _buildPositionBadge(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Cards apiladas
        _buildPersonalCard(),
        const SizedBox(height: 8),
        _buildSportCard(),
        const SizedBox(height: 8),
        _buildPhysicalCard(),
        const SizedBox(height: 20),
        // Notas
        _buildNotesSection(),
      ],
    );
  }

  /// Avatar del jugador con botón de zoom
  Widget _buildPlayerAvatar(BuildContext context) {
    final foto = player['foto']?.toString();
    final nombre = player['nombre']?.toString() ?? '';
    final apellidos = player['apellidos']?.toString() ?? '';
    final dorsal = player['dorsal']?.toString() ?? '-';
    final idposicion = player['idposicion'];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular la altura disponible para los info cards
        final availableHeight = constraints.maxHeight > 0
            ? constraints.maxHeight - 32
            : 150.0;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 120,
              height: availableHeight,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: foto != null && foto.isNotEmpty
                        ? Image.network(
                            foto,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderAvatar(idposicion);
                            },
                          )
                        : _buildPlaceholderAvatar(idposicion),
                  ),
                  // Botón de zoom
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _showFullScreenImage(context, foto, '$nombre $apellidos'),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  // Badge dorsal
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          dorsal,
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderAvatar(dynamic idposicion) {
    return Container(
      color: AppColors.gray100,
      child: Center(
        child: Icon(
          idposicion == 1 ? Icons.sports_soccer : Icons.person_rounded,
          size: 50,
          color: AppColors.gray400,
        ),
      ),
    );
  }

  /// Nombre del jugador
  Widget _buildPlayerName() {
    final nombre = player['nombre']?.toString() ?? '';
    final apellidos = player['apellidos']?.toString() ?? '';
    final nombreCompleto = '$nombre $apellidos'.trim();

    return Text(
      nombreCompleto,
      style: AppTypography.h5.copyWith(
        color: AppColors.gray900,
        fontWeight: FontWeight.w700,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Badge de posición
  Widget _buildPositionBadge() {
    if (position.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        position,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 3 Cards de información del jugador
  Widget _buildPlayerInfo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 24) / 3;
        final isCompact = cardWidth < 200;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildPersonalCard(isCompact: isCompact),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSportCard(isCompact: isCompact),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPhysicalCard(isCompact: isCompact),
            ),
          ],
        );
      },
    );
  }

  /// Card de información personal
  Widget _buildPersonalCard({bool isCompact = false}) {
    final edad = _calcularEdad();
    final fechaNacimiento = _formatFecha(player['fechanacimiento']);
    final lateralidad = player['pie']?.toString() ?? 'N/A';

    return _InfoCard(
      title: 'Información Personal',
      icon: Icons.person_outline,
      isCompact: isCompact,
      items: [
        InfoItem(label: 'Edad', value: '$edad años'),
        InfoItem(label: 'F. Nacimiento', value: fechaNacimiento),
        InfoItem(label: 'Lateralidad', value: lateralidad),
      ],
    );
  }

  /// Card de información deportiva
  Widget _buildSportCard({bool isCompact = false}) {
    final equipo = player['equipo']?.toString() ?? 'N/A';
    final categoria = player['categoria']?.toString() ?? 'N/A';
    final posicionDisplay = position.isNotEmpty ? position : 'N/A';

    return _InfoCard(
      title: 'Información Deportiva',
      icon: Icons.sports_soccer_outlined,
      isCompact: isCompact,
      items: [
        InfoItem(label: 'Equipo', value: equipo),
        InfoItem(label: 'Categoría', value: categoria),
        InfoItem(label: 'Posición', value: posicionDisplay),
      ],
    );
  }

  /// Card de información física/médica
  Widget _buildPhysicalCard({bool isCompact = false}) {
    final peso = player['peso'] != null ? '${player['peso']} kg' : 'N/A';
    final altura = player['altura'] != null ? '${player['altura']} cm' : 'N/A';
    final fechaRecMedico = _formatFecha(player['fecharecmedico']);

    return _InfoCard(
      title: 'Físico & Médico',
      icon: Icons.healing_outlined,
      isCompact: isCompact,
      items: [
        InfoItem(label: 'Peso', value: peso),
        InfoItem(label: 'Altura', value: altura),
        InfoItem(label: 'F. Rec. Médico', value: fechaRecMedico),
      ],
    );
  }

  /// Sección de notas
  Widget _buildNotesSection() {
    final nota = player['nota']?.toString() ?? '';
    final hasNote = nota.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasNote
            ? AppColors.warning.withValues(alpha: 0.1)
            : AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasNote
              ? AppColors.warning.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_alt_outlined,
                size: 14,
                color: hasNote ? AppColors.warning : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Notas',
                style: AppTypography.labelMedium.copyWith(
                  color: hasNote ? AppColors.warning : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Campo de notas
          Expanded(
            child: TextFormField(
              initialValue: nota,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'Agregar nota sobre el jugador...',
                hintStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.gray400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.gray50,
                contentPadding: const EdgeInsets.all(6),
              ),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gray700,
              ),
              onChanged: onNoteChanged,
            ),
          ),
        ],
      ),
    );
  }

  /// Calcular edad desde fecha de nacimiento
  int _calcularEdad() {
    final fechaNac = player['fechanacimiento']?.toString();
    if (fechaNac == null || fechaNac.isEmpty || fechaNac == 'null') {
      return 0;
    }

    try {
      DateTime birthDate;
      if (fechaNac.contains('-')) {
        birthDate = DateTime.parse(fechaNac);
      } else if (fechaNac.contains('/')) {
        final parts = fechaNac.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          birthDate = DateTime(year, month, day);
        } else {
          return 0;
        }
      } else {
        return 0;
      }

      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  /// Formatear fecha
  String _formatFecha(dynamic fecha) {
    if (fecha == null || fecha.toString().isEmpty || fecha.toString() == 'null') {
      return 'N/A';
    }
    final fechaStr = fecha.toString();
    // Si ya está en formato dd/MM/yyyy, devolverla tal cual
    if (fechaStr.contains('/')) {
      return fechaStr;
    }
    // Si está en formato yyyy-MM-dd, convertirla
    if (fechaStr.contains('-')) {
      try {
        final parts = fechaStr.split('-');
        if (parts.length == 3) {
          return '${parts[2]}/${parts[1]}/${parts[0]}';
        }
      } catch (e) {
        // Ignorar errores de formato
      }
    }
    return fechaStr;
  }

  /// Mostrar imagen a pantalla completa
  void _showFullScreenImage(BuildContext context, String? foto, String nombre) {
    if (foto == null || foto.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: MediaQuery.of(context).size.width - 40,
          height: MediaQuery.of(context).size.height - 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header del modal
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white),
                    AppSpacing.hSpaceMd,
                    Expanded(
                      child: Text(
                        nombre,
                        style: AppTypography.h6.copyWith(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Imagen a pantalla completa
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      foto,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                size: 64,
                                color: AppColors.gray400,
                              ),
                              AppSpacing.vSpaceMd,
                              Text(
                                'No se pudo cargar la imagen',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.gray500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modelo para items de información
class InfoItem {
  final String label;
  final String value;

  const InfoItem({required this.label, required this.value});
}

/// Card de información reutilizable
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.items,
    this.isCompact = false,
  });

  final String title;
  final IconData icon;
  final List<InfoItem> items;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: isCompact ? 20 : 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: isCompact ? 14 : 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            // Items de información en formato tabla
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              children: items.map((item) {
                return TableRow(
                  children: [
                    // Label
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Text(
                          '${item.label}:',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.gray600,
                            fontSize: isCompact ? 10 : 12,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    // Value
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        item.value,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: isCompact ? 11 : 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
