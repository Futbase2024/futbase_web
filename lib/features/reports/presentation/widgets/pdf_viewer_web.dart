/// Implementación web del visor de PDF
/// Este archivo solo se usa cuando la app se ejecuta en web
library;

import 'package:flutter/material.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: unused_import
import 'dart:ui_web' as ui_web;

/// Registra el visor de PDF para web usando un iframe
String registerPdfViewer(int reportId, String pdfUrl) {
  final viewType = 'pdf-viewer-$reportId';
  final viewerUrl = 'https://docs.google.com/gview?url=${Uri.encodeComponent(pdfUrl)}&embedded=true';

  // Registrar el iframe solo una vez
  try {
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final iframe = html.IFrameElement();
        iframe.src = viewerUrl;
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        iframe.style.border = 'none';
        return iframe;
      },
    );
  } catch (e) {
    // Ya registrado, ignorar error
    debugPrint('PDF viewer ya registrado: $e');
  }

  return viewType;
}

/// Widget para mostrar el iframe del PDF en web
class PdfIframe extends StatelessWidget {
  const PdfIframe({super.key, required this.viewType});

  final String viewType;

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: viewType,
    );
  }
}
