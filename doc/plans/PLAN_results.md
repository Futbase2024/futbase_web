# Plan Tecnico: Feature Resultados (Live Scores)

> **Proyecto**: FutBase 3.0
> **Feature**: Resultados - Live Scores Global
> **Fecha**: 2026-02-20
> **Estado**: Planificacion

---

## 1. Resumen Ejecutivo

### 1.1 Descripcion
Nueva pagina de **Resultados** que muestra todos los partidos del club organizados por fecha, con:
- **Live Scores**: Partidos en vivo con actualizacion en tiempo real (minuto a minuto)
- **Vista Global**: Resultados de TODOS los equipos del club (no solo el equipo seleccionado)

### 1.2 Diferencias con Feature `matches`
| Aspecto | `matches` | `results` (nueva) |
|---------|-----------|-------------------|
| Alcance | Un solo equipo | Todos los equipos del club |
| Foco | Gestion (CRUD) | Visualizacion |
| Tiempo real | No | Si (live scores) |
| Organizacion | Por filtros | Por fecha |

### 1.3 User Stories
1. **US-001**: Como entrenador, quiero ver todos los resultados del club en una sola pantalla
2. **US-002**: Como usuario, quiero ver los partidos que se estan jugando AHORA con el minuto actual
3. **US-003**: Como coordinador, quiero filtrar resultados por fecha y equipo
4. **US-004**: Como usuario, quiero ver el estado del partido (finalizado, en juego, programado)

---

## 2. Arquitectura Tecnica

### 2.1 Estructura de Carpetas

```
lib/features/results/
├── bloc/
│   ├── results_bloc.dart          # @injectable
│   ├── results_event.dart         # Eventos
│   └── results_state.dart         # Estados
│
├── domain/
│   └── results_repository.dart    # Clase concreta con @LazySingleton
│
└── presentation/
    ├── pages/
    │   └── results_page.dart      # Pagina principal
    │
    └── widgets/
        ├── results_date_group.dart      # Agrupador por fecha
        ├── results_live_match_card.dart # Tarjeta partido en vivo
        ├── results_match_card.dart      # Tarjeta partido normal
        ├── results_filter_bar.dart      # Barra de filtros
        ├── results_live_indicator.dart  # Indicador "EN VIVO"
        └── results_empty_state.dart     # Estado vacio
```

### 2.2 Dependencias con Otros Modulos
- `auth/bloc` - Para obtener idclub y idtemporada
- `core/theme` - AppColors, AppTypography, AppSpacing
- `shared/widgets` - CELoading, CeInfoDialog, CEButton

---

## 3. Modelo de Datos

### 3.1 Fuente de Datos: Vista `vpartido`

La vista `vpartido` ya existe y contiene todos los campos necesarios:

```sql
-- Campos relevantes para Results
SELECT
    id,
    idequipo,
    idclub,
    equipo,           -- Nombre del equipo
    ncortoequipo,     -- Nombre corto del equipo
    rival,            -- Nombre del rival
    ncortorival,      -- Nombre corto del rival
    fecha,            -- Fecha del partido
    hora,             -- Hora del partido
    casafuera,        -- 0=local, 1=visitante
    goles,            -- Goles del equipo
    golesrival,       -- Goles del rival
    finalizado,       -- 0=no finalizado, 1=finalizado
    minuto,           -- Minuto actual (para live scores)
    jornada,          -- Nombre de la jornada/competicion
    escudo,           -- URL escudo del club
    escudorival,      -- URL escudo del rival
    campo,            -- Nombre del campo
    categoria         -- Categoria del equipo
FROM vpartido
WHERE idclub = :idclub
  AND idtemporada = :idtemporada
ORDER BY fecha DESC, hora ASC
```

### 3.2 Clasificacion de Partidos por Estado

```dart
enum MatchStatus {
  live,       // En juego (finalizado=0 y fecha=hoy y hora <= ahora)
  scheduled,  // Programado (finalizado=0 y fecha >= hoy)
  finished,   // Finalizado (finalizado=1 o fecha < hoy)
}

MatchStatus getMatchStatus(Map<String, dynamic> match) {
  final finalizado = match['finalizado'] == 1 || match['finalizado'] == true;
  if (finalizado) return MatchStatus.finished;

  final fechaStr = match['fecha']?.toString();
  final horaStr = match['hora']?.toString();
  if (fechaStr == null) return MatchStatus.scheduled;

  final fecha = DateTime.tryParse(fechaStr);
  if (fecha == null) return MatchStatus.scheduled;

  final now = DateTime.now();
  final fechaSolo = DateTime(now.year, now.month, now.day);
  final fechaPartido = DateTime(fecha.year, fecha.month, fecha.day);

  // Es hoy?
  if (fechaPartido.isAtSameMomentAs(fechaSolo)) {
    // Verificar si ya empezo
    if (horaStr != null) {
      final horaParts = horaStr.split(':');
      if (horaParts.length >= 2) {
        final horaPartido = DateTime(
          fecha.year, fecha.month, fecha.day,
          int.tryParse(horaParts[0]) ?? 0,
          int.tryParse(horaParts[1]) ?? 0,
        );
        if (horaPartido.isBefore(now) || horaPartido.isAtSameMomentAs(now)) {
          return MatchStatus.live;
        }
      }
    }
    return MatchStatus.scheduled;
  }

  if (fechaPartido.isBefore(fechaSolo)) {
    return MatchStatus.finished;
  }

  return MatchStatus.scheduled;
}
```

### 3.3 Estructura de Datos Agrupados

```dart
class ResultsGroupedByDate {
  final DateTime date;
  final List<MatchWithStatus> matches;

  String get dateLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    if (date.isAtSameMomentAs(today)) return 'Hoy';
    if (date.isAtSameMomentAs(yesterday)) return 'Ayer';
    if (date.isAtSameMomentAs(tomorrow)) return 'Manana';

    return DateFormat('EEEE, d MMMM', 'es').format(date);
  }
}

class MatchWithStatus {
  final Map<String, dynamic> match;
  final MatchStatus status;
  final String equipoNombre;
  final String rivalNombre;
  final bool isLocal;
}
```

---

## 4. BLoC Pattern

### 4.1 Events

```dart
// results_event.dart
abstract class ResultsEvent extends Equatable {
  const ResultsEvent();
  @override
  List<Object?> get props => [];
}

/// Cargar todos los resultados del club
class ResultsLoadRequested extends ResultsEvent {
  final int idclub;
  final int idtemporada;

  const ResultsLoadRequested({
    required this.idclub,
    required this.idtemporada,
  });

  @override
  List<Object?> get props => [idclub, idtemporada];
}

/// Refrescar datos (pull-to-refresh)
class ResultsRefreshRequested extends ResultsEvent {
  final int idclub;
  final int idtemporada;

  const ResultsRefreshRequested({
    required this.idclub,
    required this.idtemporada,
  });
}

/// Filtrar por equipo
class ResultsFilterByTeam extends ResultsEvent {
  final int? idequipo;

  const ResultsFilterByTeam({this.idequipo});
}

/// Filtrar por rango de fechas
class ResultsFilterByDateRange extends ResultsEvent {
  final DateTime? fromDate;
  final DateTime? toDate;

  const ResultsFilterByDateRange({this.fromDate, this.toDate});
}

/// Filtrar por estado (live, scheduled, finished)
class ResultsFilterByStatus extends ResultsEvent {
  final MatchStatus? status;

  const ResultsFilterByStatus({this.status});
}

/// Limpiar filtros
class ResultsClearFilters extends ResultsEvent {
  const ResultsClearFilters();
}

/// Toggle live mode (activa actualizacion automatica)
class ResultsToggleLiveMode extends ResultsEvent {
  const ResultsToggleLiveMode();
}
```

### 4.2 States

```dart
// results_state.dart
abstract class ResultsState extends Equatable {
  const ResultsState();
  @override
  List<Object?> get props => [];
}

class ResultsInitial extends ResultsState {
  const ResultsInitial();
}

class ResultsLoading extends ResultsState {
  final String message;
  const ResultsLoading({this.message = 'Cargando resultados...'});
  @override
  List<Object?> get props => [message];
}

class ResultsLoaded extends ResultsState {
  final List<Map<String, dynamic>> allMatches;
  final List<ResultsGroupedByDate> groupedMatches;
  final Map<int, String> equipos;  // idEquipo -> nombre
  final int? filterByTeam;
  final DateTime? filterFromDate;
  final DateTime? filterToDate;
  final MatchStatus? filterByStatus;
  final bool isLiveMode;  // Actualizacion automatica activada

  const ResultsLoaded({
    required this.allMatches,
    required this.groupedMatches,
    required this.equipos,
    this.filterByTeam,
    this.filterFromDate,
    this.filterToDate,
    this.filterByStatus,
    this.isLiveMode = false,
  });

  // Getters utiles
  int get totalMatches => allMatches.length;
  int get liveMatchesCount =>
    allMatches.where((m) => getMatchStatus(m) == MatchStatus.live).length;
  int get finishedCount =>
    allMatches.where((m) => getMatchStatus(m) == MatchStatus.finished).length;
  int get scheduledCount =>
    allMatches.where((m) => getMatchStatus(m) == MatchStatus.scheduled).length;

  bool get hasActiveFilters =>
    filterByTeam != null ||
    filterFromDate != null ||
    filterToDate != null ||
    filterByStatus != null;

  @override
  List<Object?> get props => [
    allMatches, groupedMatches, equipos,
    filterByTeam, filterFromDate, filterToDate, filterByStatus, isLiveMode
  ];

  ResultsLoaded copyWith({...});
}

class ResultsError extends ResultsState {
  final String message;
  const ResultsError({required this.message});
  @override
  List<Object?> get props => [message];
}
```

### 4.3 BLoC Implementation

```dart
// results_bloc.dart
class ResultsBloc extends Bloc<ResultsEvent, ResultsState> {
  final SupabaseClient _supabase;
  Timer? _liveUpdateTimer;

  ResultsBloc({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client,
        super(const ResultsInitial()) {

    on<ResultsLoadRequested>(_onLoadRequested);
    on<ResultsRefreshRequested>(_onRefreshRequested);
    on<ResultsFilterByTeam>(_onFilterByTeam);
    on<ResultsFilterByDateRange>(_onFilterByDateRange);
    on<ResultsFilterByStatus>(_onFilterByStatus);
    on<ResultsClearFilters>(_onClearFilters);
    on<ResultsToggleLiveMode>(_onToggleLiveMode);
  }

  @override
  Future<void> close() {
    _liveUpdateTimer?.cancel();
    return super.close();
  }

  Future<void> _onLoadRequested(
    ResultsLoadRequested event,
    Emitter<ResultsState> emit,
  ) async {
    emit(const ResultsLoading());

    try {
      // Cargar TODOS los partidos del club (todos los equipos)
      final matchesData = await _supabase
          .from('vpartido')
          .select('''
            id, idequipo, idclub, equipo, ncortoequipo,
            rival, ncortorival, fecha, hora, casafuera,
            goles, golesrival, finalizado, minuto,
            jornada, escudo, escudorival, campo, categoria
          ''')
          .eq('idclub', event.idclub)
          .eq('idtemporada', event.idtemporada)
          .order('fecha', ascending: false)
          .order('hora', ascending: true);

      final matches = (matchesData as List).cast<Map<String, dynamic>>();

      // Extraer equipos unicos
      final equipos = <int, String>{};
      for (final match in matches) {
        final idequipo = match['idequipo'] as int?;
        final equipo = match['ncortoequipo']?.toString() ??
                       match['equipo']?.toString();
        if (idequipo != null && equipo != null) {
          equipos[idequipo] = equipo;
        }
      }

      // Agrupar por fecha
      final grouped = _groupByDate(matches);

      emit(ResultsLoaded(
        allMatches: matches,
        groupedMatches: grouped,
        equipos: equipos,
      ));
    } catch (e) {
      emit(ResultsError(message: 'Error al cargar resultados: $e'));
    }
  }

  void _onToggleLiveMode(
    ResultsToggleLiveMode event,
    Emitter<ResultsState> emit,
  ) {
    final currentState = state;
    if (currentState is! ResultsLoaded) return;

    final newLiveMode = !currentState.isLiveMode;

    if (newLiveMode) {
      // Iniciar actualizacion automatica cada 30 segundos
      _liveUpdateTimer?.cancel();
      _liveUpdateTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => add(ResultsRefreshRequested(
          idclub: currentState.allMatches.first['idclub'],
          idtemporada: currentState.allMatches.first['idtemporada'],
        )),
      );
    } else {
      _liveUpdateTimer?.cancel();
    }

    emit(currentState.copyWith(isLiveMode: newLiveMode));
  }

  List<ResultsGroupedByDate> _groupByDate(List<Map<String, dynamic>> matches) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final match in matches) {
      final fechaStr = match['fecha']?.toString();
      if (fechaStr == null) continue;

      final fecha = DateTime.tryParse(fechaStr);
      if (fecha == null) continue;

      final key = '${fecha.year}-${fecha.month}-${fecha.day}';
      grouped.putIfAbsent(key, () => []).add(match);
    }

    return grouped.entries.map((entry) {
      final parts = entry.key.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      final matchesWithStatus = entry.value.map((m) => MatchWithStatus(
        match: m,
        status: getMatchStatus(m),
        equipoNombre: m['ncortoequipo']?.toString() ?? m['equipo']?.toString() ?? 'Equipo',
        rivalNombre: m['ncortorival']?.toString() ?? m['rival']?.toString() ?? 'Rival',
        isLocal: !(m['casafuera'] == 1 || m['casafuera'] == true),
      )).toList();

      // Ordenar: live primero, luego por hora
      matchesWithStatus.sort((a, b) {
        if (a.status == MatchStatus.live && b.status != MatchStatus.live) return -1;
        if (a.status != MatchStatus.live && b.status == MatchStatus.live) return 1;
        final horaA = a.match['hora']?.toString() ?? '';
        final horaB = b.match['hora']?.toString() ?? '';
        return horaA.compareTo(horaB);
      });

      return ResultsGroupedByDate(date: date, matches: matchesWithStatus);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));  // Mas reciente primero
  }

  // ... resto de handlers de filtros
}
```

---

## 5. UI Components

### 5.1 ResultsPage (Pagina Principal)

```dart
// results_page.dart
class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResultsBloc()..add(ResultsLoadRequested(
        idclub: context.read<AuthBloc>().state.user!.idclub,
        idtemporada: context.read<AuthBloc>().state.selectedTemporada,
      )),
      child: const ResultsView(),
    );
  }
}

class ResultsView extends StatelessWidget {
  const ResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        actions: [
          // Boton Live Mode
          BlocBuilder<ResultsBloc, ResultsState>(
            buildWhen: (prev, curr) => curr is ResultsLoaded,
            builder: (context, state) {
              if (state is! ResultsLoaded) return const SizedBox.shrink();
              return _LiveModeButton(
                isLiveMode: state.isLiveMode,
                liveCount: state.liveMatchesCount,
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ResultsBloc, ResultsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const CELoading.fullscreen(),
            loading: (message) => CELoading.fullscreen(message: message),
            loaded: (matches, grouped, equipos, ...) =>
              ResultsLoadedView(groupedMatches: grouped),
            error: (message) => ErrorView(message: message),
          );
        },
      ),
    );
  }
}
```

### 5.2 Widgets Principales

#### ResultsDateGroup - Agrupa partidos por fecha
```dart
class ResultsDateGroup extends StatelessWidget {
  final ResultsGroupedByDate group;

  const ResultsDateGroup({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de fecha
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            group.dateLabel,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.gray600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Lista de partidos
        ...group.matches.map((match) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: match.status == MatchStatus.live
            ? ResultsLiveMatchCard(match: match)
            : ResultsMatchCard(match: match),
        )),
      ],
    );
  }
}
```

#### ResultsLiveMatchCard - Partido en vivo
```dart
class ResultsLiveMatchCard extends StatelessWidget {
  final MatchWithStatus match;

  const ResultsLiveMatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent,  // Verde neon para live
          width: 2,
        ),
        boxShadow: AppColors.cardShadowLight,
      ),
      child: Column(
        children: [
          // Badge EN VIVO con minuto
          ResultsLiveIndicator(minuto: match.match['minuto']),

          const SizedBox(height: 12),

          // Equipos y marcador
          _MatchScoreRow(match: match),

          // Info adicional
          const SizedBox(height: 8),
          Text(
            '${match.match['campo'] ?? ''} - ${match.match['jornada'] ?? ''}',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### ResultsLiveIndicator - Indicador "EN VIVO"
```dart
class ResultsLiveIndicator extends StatefulWidget {
  final int? minuto;

  const ResultsLiveIndicator({super.key, this.minuto});

  @override
  State<ResultsLiveIndicator> createState() => _ResultsLiveIndicatorState();
}

class _ResultsLiveIndicatorState extends State<ResultsLiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Punto parpadeante
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                // Pulse effect
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(
                      alpha: _controller.value,
                    ),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "EN VIVO",
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          if (widget.minuto != null) ...[
            const SizedBox(width: 8),
            Text(
              "${widget.minuto}'",
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## 6. Rutas

### 6.1 Registro en AppRouter

```dart
// app_router.dart - agregar
static const String results = '/results';

// En routes:
GoRoute(
  path: results,
  name: 'results',
  pageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: const ResultsPage(),
  ),
),
```

### 6.2 NavigationItem en Sidebar

```dart
// Agregar al menu de navegacion
NavigationItem(
  icon: Icons.sports_soccer,
  label: 'Resultados',
  route: AppRouter.results,
),
```

---

## 7. Fases de Implementacion

### Fase 1: Infraestructura Basica (2-3h)
- [ ] Crear estructura de carpetas `lib/features/results/`
- [ ] Crear `results_event.dart` con todos los eventos
- [ ] Crear `results_state.dart` con todos los estados
- [ ] Crear `results_bloc.dart` con logica basica de carga
- [ ] Registrar ruta `/results` en `app_router.dart`

### Fase 2: UI Principal (2-3h)
- [ ] Crear `results_page.dart` con Scaffold basico
- [ ] Crear `results_match_card.dart` para partidos normales
- [ ] Crear `results_date_group.dart` para agrupar por fecha
- [ ] Crear `results_empty_state.dart`
- [ ] Integrar con AuthBloc para obtener idclub e idtemporada

### Fase 3: Live Scores (2-3h)
- [ ] Crear `results_live_match_card.dart` con diseno especial
- [ ] Crear `results_live_indicator.dart` con animacion pulsante
- [ ] Implementar `ResultsToggleLiveMode` con Timer
- [ ] Actualizacion automatica cada 30 segundos en modo live

### Fase 4: Filtros (1-2h)
- [ ] Crear `results_filter_bar.dart`
- [ ] Implementar filtro por equipo
- [ ] Implementar filtro por fecha
- [ ] Implementar filtro por estado (live/scheduled/finished)

### Fase 5: Testing y Polish (1-2h)
- [ ] Tests unitarios del BLoC
- [ ] Verificar responsive design
- [ ] Verificar dart analyze sin warnings
- [ ] Probar en diferentes dispositivos

---

## 8. Criterios de Aceptacion

### AC-001: Vista Global
- [ ] Muestra partidos de TODOS los equipos del club
- [ ] Agrupa partidos por fecha
- [ ] Muestra nombre del equipo en cada tarjeta

### AC-002: Live Scores
- [ ] Identifica partidos en vivo automaticamente
- [ ] Muestra indicador "EN VIVO" con animacion
- [ ] Muestra minuto actual del partido
- [ ] Toggle para activar actualizacion automatica

### AC-003: Filtros
- [ ] Filtrar por equipo especifico
- [ ] Filtrar por rango de fechas
- [ ] Filtrar por estado (en vivo, programados, finalizados)
- [ ] Limpiar filtros

### AC-004: UX/UI
- [ ] Consistencia con AppColors del proyecto
- [ ] Uso de CELoading para estados de carga
- [ ] Pull-to-refresh funcional
- [ ] Estados vacios informativos

---

## 9. Riesgos y Mitigacion

| Riesgo | Probabilidad | Mitigacion |
|--------|--------------|------------|
| No hay campo `minuto` en BD | Media | Usar calculo estimado basado en hora inicio |
| Muchos partidos = lentitud | Baja | Paginacion o lazy loading |
| Websockets no disponibles | Baja | Polling cada 30 segundos como fallback |

---

## 10. Archivos a Crear/Modificar

### Archivos Nuevos (10)
1. `lib/features/results/bloc/results_event.dart`
2. `lib/features/results/bloc/results_state.dart`
3. `lib/features/results/bloc/results_bloc.dart`
4. `lib/features/results/presentation/pages/results_page.dart`
5. `lib/features/results/presentation/widgets/results_date_group.dart`
6. `lib/features/results/presentation/widgets/results_match_card.dart`
7. `lib/features/results/presentation/widgets/results_live_match_card.dart`
8. `lib/features/results/presentation/widgets/results_live_indicator.dart`
9. `lib/features/results/presentation/widgets/results_filter_bar.dart`
10. `lib/features/results/presentation/widgets/results_empty_state.dart`

### Archivos a Modificar (2)
1. `lib/core/routing/app_router.dart` - Agregar ruta `/results`
2. `lib/features/dashboard/presentation/widgets/sidebar.dart` - Agregar item menu

---

**Proximo paso**: Generar disenos con Stitch y luego implementar codigo.
