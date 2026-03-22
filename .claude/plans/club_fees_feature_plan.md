# Plan: Feature de Cuotas para Perfil Clubes

## 📋 Resumen
Implementar una sección de gestión de cuotas para el perfil de administradores de club, permitiendo:
- Visualizar estado de pagos de todos los jugadores del club
- Ver resumen financiero (cobrado vs pendiente)
- Gestionar cuotas por jugador/equipo
- Registrar pagos

## 🗄️ Base de Datos (Ya Existe)

### Tablas Identificadas
| Tabla | Descripción |
|-------|-------------|
| `tcuotas` | Cuotas mensuales de jugadores |
| `tconfigcuotas` | Configuración de tipos de cuota por club |
| `trecibos_pagos` | Registro de pagos realizados |
| `tpagopersonal` | Pagos personales adicionales |

### Estructura `tcuotas`
```sql
- id: integer (PK)
- idclub: integer
- idequipo: integer
- idjugador: integer
- mes: integer (1-12)
- year: integer
- idestado: integer (1-5, estado del pago)
- cantidad: double precision
- idtipocuota: integer
- idtemporada: integer
- timestamp: timestamp
```

### Estructura `trecibos_pagos`
```sql
- id: integer (PK)
- idclub: integer
- idjugador: integer
- idtemporada: integer
- cantidad: numeric
- fecha_pago: timestamp
- concepto: varchar
- metodo_pago: varchar
- timestamp: timestamp
```

## 🏗️ Arquitectura

### Estructura de Archivos
```
lib/features/fees/
├── bloc/
│   ├── fees_event.dart
│   ├── fees_state.dart
│   └── fees_bloc.dart
├── presentation/
│   ├── pages/
│   │   └── fees_page.dart          # Página principal de cuotas
│   └── widgets/
│       ├── fees_summary_card.dart   # Card con resumen financiero
│       ├── fees_chart_card.dart     # Gráfico circular de estado
│       ├── fees_player_list.dart    # Lista de jugadores con su estado
│       ├── fees_player_card.dart    # Card individual de jugador
│       ├── fees_filter_bar.dart     # Filtros (mes, equipo, estado)
│       ├── fees_empty_state.dart    # Estado vacío
│       └── payment_dialog.dart      # Diálogo para registrar pago
└── routes/
    └── fees_route.dart
```

## 📐 Diseño UI

### Layout Principal
```
┌─────────────────────────────────────────────────────────┐
│ KPIs Row (4 cards iguales)                              │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐        │
│ │Total    │ │Pagado   │ │Pendiente│ │Vencido  │        │
│ │ 3.450€  │ │ 2.932€  │ │  518€   │ │   0€    │        │
│ └─────────┘ └─────────┘ └─────────┘ └─────────┘        │
├─────────────────────────────────────────────────────────┤
│ Fila de Gráficos (misma altura)                         │
│ ┌───────────────────┐ ┌───────────────────────────────┐│
│ │ Estado de Cuotas  │ │ Lista de Jugadores con Filtros ││
│ │ (Pie Chart)       │ │ - Filtro por equipo            ││
│ │ 85% cobrado       │ │ - Filtro por mes               ││
│ │                   │ │ - Filtro por estado            ││
│ └───────────────────┘ └───────────────────────────────┘│
├─────────────────────────────────────────────────────────┤
│ Tabla/Lista de Jugadores (expandible)                   │
│ ┌─────────────────────────────────────────────────────┐│
│ │ Jugador    │ Equipo   │ Mes   │ Cantidad │ Estado  ││
│ ├────────────┼──────────┼───────┼──────────┼─────────┤│
│ │ Juan Pérez │ Senior A │ Ene   │ 21€      │ ✅ Pagado││
│ │ María López│ Cadete   │ Ene   │ 21€      │ ⏳ Pend. ││
│ └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

### Estados de Cuota (idestado)
| ID | Estado | Color | Badge |
|----|--------|-------|-------|
| 1 | Pagado | `AppColors.success` | ✅ Verde |
| 2 | Pendiente | `AppColors.warning` | ⏳ Naranja |
| 3 | Vencido | `AppColors.error` | ❌ Rojo |
| 4 | Parcial | `AppColors.info` | 🔵 Azul |
| 5 | Exento | `AppColors.gray400` | ⚪ Gris |

## 🔄 BLoC

### Events
```dart
abstract class FeesEvent extends Equatable {
  const FeesEvent();
}

class FeesLoadRequested extends FeesEvent {
  final int idclub;
  final int activeSeasonId;
}

class FeesRefreshRequested extends FeesEvent {
  final int idclub;
  final int activeSeasonId;
}

class FeesFilterByMonth extends FeesEvent {
  final int? month;
  final int? year;
}

class FeesFilterByTeam extends FeesEvent {
  final int? idEquipo;
}

class FeesFilterByStatus extends FeesEvent {
  final int? idEstado;
}

class FeesSearchRequested extends FeesEvent {
  final String query;
}

class FeesClearFilters extends FeesEvent {}

class PaymentRegisterRequested extends FeesEvent {
  final int idCuota;
  final double cantidad;
  final String metodoPago;
  final String? concepto;
}
```

### State
```dart
abstract class FeesState extends Equatable {
  const FeesState();
}

class FeesInitial extends FeesState {}

class FeesLoading extends FeesState {}

class FeesLoaded extends FeesState {
  final List<Map<String, dynamic>> fees;        // Todas las cuotas
  final List<Map<String, dynamic>> filteredFees; // Cuotas filtradas
  final Map<int, String> teams;                  // Equipos del club
  final Map<int, String> players;                // Jugadores

  // Filtros activos
  final String searchQuery;
  final int? filterByMonth;
  final int? filterByYear;
  final int? filterByTeam;
  final int? filterByStatus;

  // Resumen financiero
  final double totalEsperado;
  final double totalPagado;
  final double totalPendiente;
  final double totalVencido;

  // Contadores
  final int countPagado;
  final int countPendiente;
  final int countVencido;

  final int idclub;
  final int activeSeasonId;
}

class FeesError extends FeesState {
  final String message;
}
```

## 📊 Queries SQL

### Obtener cuotas del club
```sql
SELECT
  c.id,
  c.idclub,
  c.idequipo,
  c.idjugador,
  c.mes,
  c.year,
  c.idestado,
  c.cantidad,
  c.idtipocuota,
  c.idtemporada,
  j.nombre || ' ' || j.apellidos as jugador_nombre,
  e.equipo as equipo_nombre,
  cat.categoria
FROM tcuotas c
LEFT JOIN tjugadores j ON c.idjugador = j.id
LEFT JOIN vequipos e ON c.idequipo = e.id
LEFT JOIN tcategorias cat ON e.idcategoria = cat.id
WHERE c.idclub = ? AND c.idtemporada = ?
ORDER BY c.year DESC, c.mes DESC, j.nombre;
```

### Resumen financiero
```sql
SELECT
  SUM(cantidad) as total,
  SUM(CASE WHEN idestado = 1 THEN cantidad ELSE 0 END) as pagado,
  SUM(CASE WHEN idestado = 2 THEN cantidad ELSE 0 END) as pendiente,
  SUM(CASE WHEN idestado = 3 THEN cantidad ELSE 0 END) as vencido,
  COUNT(CASE WHEN idestado = 1 THEN 1 END) as count_pagado,
  COUNT(CASE WHEN idestado = 2 THEN 1 END) as count_pendiente,
  COUNT(CASE WHEN idestado = 3 THEN 1 END) as count_vencido
FROM tcuotas
WHERE idclub = ? AND idtemporada = ?;
```

## ✅ Checklist de Implementación

### Fase 1: BLoC y Estado
- [ ] Crear `fees_event.dart`
- [ ] Crear `fees_state.dart`
- [ ] Crear `fees_bloc.dart` con lógica de carga y filtros

### Fase 2: Widgets de Presentación
- [ ] Crear `fees_summary_card.dart` (4 KPIs)
- [ ] Actualizar `fees_status_chart.dart` para usar datos reales
- [ ] Crear `fees_filter_bar.dart`
- [ ] Crear `fees_player_list.dart`
- [ ] Crear `fees_player_card.dart`
- [ ] Crear `fees_empty_state.dart`

### Fase 3: Página Principal
- [ ] Crear `fees_page.dart`
- [ ] Crear `fees_route.dart`
- [ ] Integrar con navegación del club

### Fase 4: Funcionalidad de Pagos
- [ ] Crear `payment_dialog.dart`
- [ ] Implementar registro de pagos
- [ ] Conectar con `trecibos_pagos`

### Fase 5: Integración
- [ ] Añadir botón en `ClubDashboard` para acceder a cuotas
- [ ] Registrar ruta en router principal
- [ ] Tests básicos

## 🎨 Colores a Usar
- Primario: `AppColors.primary`
- Éxito (Pagado): `AppColors.success`
- Advertencia (Pendiente): `AppColors.warning`
- Error (Vencido): `AppColors.error`
- Información (Parcial): `AppColors.info`
- Neutro (Exento): `AppColors.gray400`

## 📱 Responsive
- Desktop: Grid de 4 KPIs, tabla de jugadores
- Tablet: Grid de 2x2 KPIs, lista de jugadores
- Mobile: Columna de KPIs, lista compacta
