import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Estado de configuración de la aplicación
class AppConfigState {
  final int activeSeasonId;
  final String activeSeasonName;
  final bool isLoading;
  final String? error;

  const AppConfigState({
    required this.activeSeasonId,
    required this.activeSeasonName,
    this.isLoading = false,
    this.error,
  });

  factory AppConfigState.initial() => const AppConfigState(
        activeSeasonId: 6, // Valor por defecto
        activeSeasonName: '2025/2026',
      );

  AppConfigState copyWith({
    int? activeSeasonId,
    String? activeSeasonName,
    bool? isLoading,
    String? error,
  }) {
    return AppConfigState(
      activeSeasonId: activeSeasonId ?? this.activeSeasonId,
      activeSeasonName: activeSeasonName ?? this.activeSeasonName,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Cubit para gestionar la configuración global de la aplicación
///
/// Centraliza el acceso a configuraciones como:
/// - Temporada activa
/// - Otras configuraciones de tconfig
class AppConfigCubit extends Cubit<AppConfigState> {
  AppConfigCubit() : super(AppConfigState.initial());

  /// Carga la configuración desde la base de datos
  Future<void> loadConfig() async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await Supabase.instance.client
          .from('tconfig')
          .select('idtemporada, temporada')
          .limit(1)
          .maybeSingle();

      if (response != null) {
        emit(state.copyWith(
          activeSeasonId: response['idtemporada'] as int,
          activeSeasonName: response['temporada'] as String,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Cambia la temporada activa
  Future<void> setActiveSeason(int seasonId, String seasonName) async {
    try {
      await Supabase.instance.client
          .from('tconfig')
          .update({
            'idtemporada': seasonId,
            'temporada': seasonName,
          })
          .eq('id', 1);

      emit(state.copyWith(
        activeSeasonId: seasonId,
        activeSeasonName: seasonName,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Obtiene el ID de la temporada activa
  int get activeSeasonId => state.activeSeasonId;

  /// Obtiene el nombre de la temporada activa
  String get activeSeasonName => state.activeSeasonName;
}
