import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../domain/saved_report_entity.dart';

// Conditional import for web-specific functionality
import 'pdf_viewer_web_stub.dart'
    if (dart.library.html) 'pdf_viewer_web.dart' as web;

/// Visor de PDF con acciones de enviar, descargar e imprimir
class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({
    super.key,
    required this.report,
  });

  final SavedReportEntity report;

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool _isLoading = true;
  String? _error;
  String? _viewType;

  String get _pdfUrl => widget.report.urlDocumento ?? '';

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  void _loadPdf() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Registrar el visor de PDF para web
    if (kIsWeb && _pdfUrl.isNotEmpty) {
      _viewType = web.registerPdfViewer(widget.report.id, _pdfUrl);
    }

    // Simular carga del PDF
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_pdfUrl.isEmpty) {
            _error = 'No hay documento disponible';
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Column(
        children: [
          // Header con acciones
          _buildHeader(),

          // Contenido del PDF
          Expanded(
            child: _buildPdfContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
          // Botón volver
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.gray700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Información del documento
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.report.informe,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.report.reportType.label,
                        style: AppTypography.bodySmall.copyWith(
                          color: _getTypeColor(),
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Acciones
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: Icons.send_outlined,
                label: 'Enviar',
                onTap: _sharePdf,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.download_outlined,
                label: 'Descargar',
                onTap: _downloadPdf,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.print_outlined,
                label: 'Imprimir',
                onTap: _printPdf,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPdfContent() {
    if (_isLoading) {
      return const Center(
        child: CELoading.inline(message: 'Cargando documento...'),
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
              color: AppColors.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      );
    }

    // Para web, mostrar iframe con el visor de PDF
    if (kIsWeb && _viewType != null) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: web.PdfIframe(viewType: _viewType!),
        ),
      );
    }

    // Para otras plataformas, mostrar botón para abrir
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf_outlined,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Documento listo para ver',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _downloadPdf,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Abrir documento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sharePdf() async {
    // Para web, mostrar diálogo con el enlace para compartir
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => _ShareDialog(
          title: widget.report.informe,
          url: _pdfUrl,
        ),
      );
    }
  }

  Future<void> _downloadPdf() async {
    if (_pdfUrl.isEmpty) return;

    final uri = Uri.parse(_pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  Future<void> _printPdf() async {
    if (_pdfUrl.isEmpty) return;

    try {
      // Para web, abrir el PDF con el diálogo de impresión
      if (kIsWeb) {
        // Abrir el PDF directamente con parámetro de impresión
        final printUrl = '$_pdfUrl#toolbar=0&navpanes=0&scrollbar=0';
        final uri = Uri.parse(printUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, webOnlyWindowName: '_blank');
        }
      }
    } catch (e) {
      debugPrint('Error al imprimir: $e');
      // Fallback: abrir en nueva ventana
      await _downloadPdf();
    }
  }

  Color _getTypeColor() {
    return switch (widget.report.reportType) {
      SavedReportType.partidos => AppColors.primary,
      SavedReportType.entrenamientos => AppColors.success,
      SavedReportType.jugadores => AppColors.info,
      SavedReportType.convocatorias => AppColors.warning,
    };
  }
}

/// Botón de acción del header
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.gray700,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.gray700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Diálogo para compartir
class _ShareDialog extends StatelessWidget {
  const _ShareDialog({
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.send,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Compartir documento',
                  style: AppTypography.h6.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Comparte este enlace para que otros puedan ver el documento:',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gray200),
              ),
              child: SelectableText(
                url,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enlace copiado al portapapeles'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copiar enlace'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
