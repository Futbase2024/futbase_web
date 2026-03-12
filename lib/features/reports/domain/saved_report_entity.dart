import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Tipos de informe guardado según la base de datos
enum SavedReportType {
  partidos(1, 'Partidos', Icons.sports_soccer),
  entrenamientos(2, 'Entrenamientos', Icons.fitness_center),
  jugadores(3, 'Jugadores', Icons.person),
  convocatorias(4, 'Convocatorias', Icons.groups);

  const SavedReportType(this.id, this.label, this.icon);

  final int id;
  final String label;
  final IconData icon;

  static SavedReportType? fromId(int? id) {
    if (id == null) return null;
    return SavedReportType.values.firstWhere(
      (t) => t.id == id,
      orElse: () => SavedReportType.partidos,
    );
  }
}

/// Entity que representa un informe guardado en la base de datos
class SavedReportEntity extends Equatable {
  const SavedReportEntity({
    required this.id,
    this.usuarioId,
    this.equipoId,
    this.clubId,
    this.tipo,
    required this.informe,
    this.urlDocumento,
    required this.fechaSubida,
    this.temporadaId,
  });

  final int id;
  final int? usuarioId;
  final int? equipoId;
  final int? clubId;
  final int? tipo;
  final String informe;
  final String? urlDocumento;
  final DateTime fechaSubida;
  final int? temporadaId;

  SavedReportType get reportType => SavedReportType.fromId(tipo) ?? SavedReportType.partidos;

  factory SavedReportEntity.fromJson(Map<String, dynamic> json) {
    return SavedReportEntity(
      id: json['id'] as int,
      usuarioId: json['idusuario'] as int?,
      equipoId: json['idequipo'] as int?,
      clubId: json['idclub'] as int?,
      tipo: json['tipo'] as int?,
      informe: json['informe'] as String? ?? '',
      urlDocumento: json['urldocumento'] as String?,
      fechaSubida: json['fechasubida'] != null
          ? DateTime.parse(json['fechasubida'].toString())
          : DateTime.now(),
      temporadaId: json['idtemporada'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idusuario': usuarioId,
      'idequipo': equipoId,
      'idclub': clubId,
      'tipo': tipo,
      'informe': informe,
      'urldocumento': urlDocumento,
      'fechasubida': fechaSubida.toIso8601String(),
      'idtemporada': temporadaId,
    };
  }

  @override
  List<Object?> get props => [
        id,
        usuarioId,
        equipoId,
        clubId,
        tipo,
        informe,
        urlDocumento,
        fechaSubida,
        temporadaId,
      ];
}
