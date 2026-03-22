import 'package:flutter/material.dart';
import 'fees_fee_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Lista de cuotas de jugadores
class FeesFeeList extends StatelessWidget {
  const FeesFeeList({
    super.key,
    required this.fees,
    this.onFeeTap,
    this.onPayTap,
  });

  final List<Map<String, dynamic>> fees;
  final ValueChanged<Map<String, dynamic>>? onFeeTap;
  final ValueChanged<Map<String, dynamic>>? onPayTap;

  @override
  Widget build(BuildContext context) {
    if (fees.isEmpty) {
      return const _EmptyFeesState();
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: fees.length,
      itemBuilder: (context, index) {
        final fee = fees[index];
        return FeesFeeCard(
          fee: fee,
          onTap: onFeeTap != null ? () => onFeeTap!(fee) : null,
          onPayTap: onPayTap != null ? () => onPayTap!(fee) : null,
        );
      },
    );
  }
}

/// Estado vacío para la lista de cuotas
class _EmptyFeesState extends StatelessWidget {
  const _EmptyFeesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.gray400,
              ),
            ),
            AppSpacing.vSpaceLg,
            Text(
              'No hay cuotas',
              style: AppTypography.h6.copyWith(
                color: AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.vSpaceSm,
            Text(
              'No se encontraron cuotas con los filtros seleccionados',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
