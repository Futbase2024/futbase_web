/// Stub para plataformas que no son web
/// Este archivo se usa cuando la app no se ejecuta en web
library;

import 'package:flutter/material.dart';

/// Registra el visor de PDF (no hace nada en plataformas no-web)
String registerPdfViewer(int reportId, String pdfUrl) {
  return 'pdf-viewer-$reportId';
}

/// Widget para mostrar el iframe del PDF (no disponible en plataformas no-web)
class PdfIframe extends StatelessWidget {
  const PdfIframe({super.key, required this.viewType});

  final String viewType;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Visor de PDF no disponible en esta plataforma'),
    );
  }
}
