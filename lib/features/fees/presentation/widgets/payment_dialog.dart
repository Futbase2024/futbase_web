import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

/// Diálogo para registrar un pago de cuota
class PaymentDialog extends StatefulWidget {
  const PaymentDialog({
    super.key,
    required this.fee,
  });

  final Map<String, dynamic> fee;

  static Future<bool?> show(BuildContext context, {required Map<String, dynamic> fee}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentDialog(fee: fee),
    );
  }

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadController = TextEditingController();
  final _conceptoController = TextEditingController();

  String _metodoPago = 'Efectivo';
  bool _isProcessing = false;

  static const List<String> _metodosPago = [
    'Efectivo',
    'Transferencia',
    'Tarjeta',
    'Bizum',
    'Cheque',
  ];

  @override
  void initState() {
    super.initState();
    final cantidadRaw = widget.fee['cantidad'];
    final cantidad = cantidadRaw is int
        ? cantidadRaw.toDouble()
        : (cantidadRaw as num?)?.toDouble() ?? 0.0;
    _cantidadController.text = cantidad.toStringAsFixed(0);
    _conceptoController.text = 'Pago de cuota';
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _conceptoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jugadorNombre = widget.fee['jugador_nombre'] as String? ?? '-';
    final equipoNombre = widget.fee['equipo_nombre'] as String? ?? '-';
    final mes = widget.fee['mes'] as int?;
    final year = widget.fee['year'] as int?;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.payment,
                      color: AppColors.success,
                      size: 24,
                    ),
                  ),
                  AppSpacing.hSpaceMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registrar Pago',
                          style: AppTypography.h6.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900,
                          ),
                        ),
                        Text(
                          '$jugadorNombre - $equipoNombre',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.gray500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isProcessing ? null : () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                    color: AppColors.gray400,
                  ),
                ],
              ),
              AppSpacing.vSpaceLg,
              // Info de la cuota
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Período:',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.gray600),
                    ),
                    Text(
                      _getPeriodLabel(mes, year),
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.vSpaceMd,
              // Campo de cantidad
              TextFormField(
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                enabled: !_isProcessing,
                decoration: InputDecoration(
                  labelText: 'Cantidad (€)',
                  prefixIcon: const Icon(Icons.euro, color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La cantidad es obligatoria';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num <= 0) {
                    return 'Introduce una cantidad válida';
                  }
                  return null;
                },
              ),
              AppSpacing.vSpaceMd,
              // Dropdown de método de pago
              DropdownButtonFormField<String>(
                initialValue: _metodoPago,
                decoration: InputDecoration(
                  labelText: 'Método de pago',
                  prefixIcon: const Icon(Icons.account_balance_wallet, color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _metodosPago.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text(m),
                  );
                }).toList(),
                onChanged: _isProcessing
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _metodoPago = value);
                        }
                      },
              ),
              AppSpacing.vSpaceMd,
              // Campo de concepto
              TextFormField(
                controller: _conceptoController,
                enabled: !_isProcessing,
                decoration: InputDecoration(
                  labelText: 'Concepto (opcional)',
                  prefixIcon: const Icon(Icons.description_outlined, color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              AppSpacing.vSpaceLg,
              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isProcessing
                          ? null
                          : () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.gray300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  AppSpacing.hSpaceMd,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text(
                              'Confirmar Pago',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onConfirm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    // Simular procesamiento
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  String _getPeriodLabel(int? mes, int? year) {
    if (mes == null || year == null) return '-';
    const monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    final monthName = mes >= 1 && mes <= 12 ? monthNames[mes - 1] : '-';
    return '$monthName $year';
  }
}
