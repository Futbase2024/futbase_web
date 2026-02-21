#!/usr/bin/env dart
// Generador de scripts SQL INSERT a partir de archivos JSON
// Uso: dart run generate_sql.dart

import 'dart:convert';
import 'dart:io';

void main() async {
  final baseDir = Directory.current.path.endsWith('migration')
      ? Directory.current.path
      : '${Directory.current.path}/doc/migration';

  final tablasDir = Directory('$baseDir/tablas');

  if (!await tablasDir.exists()) {
    print('Error: No se encuentra el directorio $tablasDir');
    exit(1);
  }

  // Procesar cada archivo JSON
  await for (final file in tablasDir.list()) {
    if (file is File && file.path.endsWith('.json')) {
      final tableName = file.uri.pathSegments.last.replaceAll('.json', '');
      await _processJsonFile(file, tableName, baseDir);
    }
  }

  print('\nGeneración completada.');
}

Future<void> _processJsonFile(File file, String tableName, String outputDir) async {
  print('Procesando: ${file.path}');

  final content = await file.readAsString();
  final List<dynamic> data = jsonDecode(content);

  if (data.isEmpty) {
    print('  - Sin datos, omitiendo...');
    return;
  }

  // Obtener columnas del primer registro
  final columns = (data.first as Map<String, dynamic>).keys.toList();

  // Generar INSERT statements
  final buffer = StringBuffer();
  buffer.writeln('-- ============================================================================');
  buffer.writeln('-- DATOS: $tableName');
  buffer.writeln('-- Registros: ${data.length}');
  buffer.writeln('-- ============================================================================');
  buffer.writeln('');
  buffer.writeln('INSERT INTO public.$tableName (${columns.join(', ')}) VALUES');

  final values = <String>[];
  for (int i = 0; i < data.length; i++) {
    final row = data[i] as Map<String, dynamic>;
    final rowValues = columns.map((col) {
      final value = row[col];
      return _formatValue(value);
    }).join(', ');
    values.add('($rowValues)');
  }

  buffer.write(values.join(',\n'));
  buffer.writeln('');
  buffer.writeln('ON CONFLICT (id) DO NOTHING;');
  buffer.writeln('');

  // Escribir archivo
  final outputFile = File('$outputDir/data_$tableName.sql');
  await outputFile.writeAsString(buffer.toString());
  print('  -> Generado: ${outputFile.path}');
}

String _formatValue(dynamic value) {
  if (value == null) {
    return 'NULL';
  }
  if (value is bool) {
    return value ? 'TRUE' : 'FALSE';
  }
  if (value is num) {
    return value.toString();
  }
  if (value is String) {
    // Escapar comillas simples
    final escaped = value.replaceAll("'", "''");
    return "'$escaped'";
  }
  // Para otros tipos, convertir a string y escapar
  final escaped = value.toString().replaceAll("'", "''");
  return "'$escaped'";
}
