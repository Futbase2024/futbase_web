# FutBase 3.0 🚀

**La Plataforma de Gestión Deportiva Más Completa y Profesional**

---

## 📋 Descripción

FutBase 3.0 es una plataforma web moderna y profesional diseñada para la gestión integral de clubes deportivos. Construida desde cero con Flutter Web, ofrece una experiencia de usuario excepcional y un sistema de diseño robusto.

## ✨ Características Principales

### 🎨 Sistema de Diseño Profesional

- **Paleta de Colores Moderna**: Basada en Teal/Cyan con gradientes profesionales
- **Tipografía Escalable**: Sistema tipográfico completo usando Google Fonts (Inter)
- **Espaciado Consistente**: Sistema de espaciado basado en múltiplos de 4px
- **Componentes Reutilizables**: Biblioteca completa de componentes UI

### 📱 Responsive Design

- **Mobile First**: Optimizado para dispositivos móviles
- **Breakpoints Definidos**:
  - Mobile: < 640px
  - Tablet: 640px - 1024px
  - Desktop: > 1024px
  - Ultra-wide: > 1536px

### 🏠 Landing Page Moderna

- Hero Section impactante con gradientes
- Sección de características con iconos animados
- Estadísticas en tiempo real
- Call to Action persuasivo
- Footer completo con redes sociales

### 📊 Módulos Principales (Planificados)

- ✅ **Landing Page** - Implementado
- 🚧 **Sistema de Autenticación** - En desarrollo
- 🚧 **Dashboard** - En desarrollo
- 📋 **Gestión de Jugadores**
- 👥 **Equipos y Categorías**
- 📅 **Entrenamientos**
- ⚽ **Partidos y Resultados**
- 💰 **Gestión de Cuotas**
- 📊 **Estadísticas Avanzadas**

---

## 🛠️ Stack Tecnológico

### Frontend
- **Flutter Web** 3.35.3
- **Dart** 3.9.2
- **Material Design 3**

### Paquetes Principales
```yaml
google_fonts: ^6.3.3         # Tipografía profesional
go_router: ^14.8.1           # Navegación declarativa
flutter_bloc: ^9.1.1         # State Management
get_it: ^8.3.0               # Dependency Injection
animate_do: ^3.3.9           # Animaciones
fl_chart: ^0.70.2            # Gráficos interactivos
flutter_screenutil: ^5.9.3   # Responsive design
```

---

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart         # Sistema de colores
│   │   ├── app_typography.dart     # Tipografía
│   │   ├── app_spacing.dart        # Espaciado
│   │   └── app_theme.dart          # Tema principal
│   ├── routing/
│   │   └── app_router.dart         # Configuración de rutas
│   ├── constants/
│   │   └── app_constants.dart      # Constantes globales
│   └── utils/
│       └── responsive.dart         # Utilidades responsive
├── features/
│   ├── landing/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── widgets/
│   ├── auth/              # Sistema de autenticación
│   └── dashboard/         # Dashboard principal
└── main.dart
```

---

## 🚀 Inicio Rápido

### Prerrequisitos

```bash
Flutter SDK: ^3.9.2
Dart SDK: ^3.9.2
```

### Instalación

1. **Navegar al proyecto**
```bash
cd /Users/lokisoft1/Desktop/Desarrollo/WebFutbase3.0
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar en desarrollo**
```bash
flutter run -d chrome
```

4. **Compilar para producción**
```bash
flutter build web --release
```

---

## 🎨 Guía de Estilo

### Colores

```dart
// Principales
AppColors.primary        // #0F766E (Teal)
AppColors.secondary      // #0891B2 (Cyan)
AppColors.accent         // #F59E0B (Amber)

// Semánticos
AppColors.success        // #10B981 (Verde)
AppColors.warning        // #F59E0B (Amber)
AppColors.error          // #EF4444 (Rojo)
AppColors.info           // #3B82F6 (Azul)
```

### Tipografía

```dart
AppTypography.h1         // 56px, Bold
AppTypography.h2         // 48px, Bold
AppTypography.bodyLarge  // 18px, Regular
AppTypography.bodyMedium // 16px, Regular
```

### Espaciado

```dart
AppSpacing.xs            // 4px
AppSpacing.sm            // 8px
AppSpacing.md            // 12px
AppSpacing.lg            // 16px (base)
AppSpacing.xl            // 24px
AppSpacing.xxl           // 32px
```

---

## 🎯 Roadmap

### Fase 1: Fundamentos ✅
- [x] Sistema de diseño profesional
- [x] Landing page moderna
- [x] Estructura base del proyecto
- [x] Routing configurado

### Fase 2: Autenticación 🚧
- [ ] Login page completa
- [ ] Registro de usuarios
- [ ] Recuperación de contraseña
- [ ] Integración con Firebase Auth

### Fase 3: Dashboard 📋
- [ ] Panel de control con estadísticas
- [ ] Gráficos interactivos
- [ ] Navegación lateral
- [ ] Perfil de usuario

### Fase 4: Módulos de Gestión 📋
- [ ] Gestión de Jugadores
- [ ] Gestión de Equipos
- [ ] Gestión de Entrenamientos
- [ ] Gestión de Partidos
- [ ] Gestión de Cuotas

---

## 🔧 Desarrollo

### Comandos Útiles

```bash
# Ejecutar en modo debug
flutter run -d chrome

# Build para web (producción)
flutter build web --release --no-tree-shake-icons

# Analizar código
flutter analyze

# Formatear código
flutter format .

# Limpiar build
flutter clean
```

---

## 📝 Comparación con FutBase 2.0

| Característica | FutBase 2.0 | FutBase 3.0 |
|---|---|---|
| **Diseño** | Básico | Moderno y profesional |
| **Responsive** | Limitado | Completo (mobile-first) |
| **Sistema de diseño** | Inconsistente | Design System robusto |
| **Performance** | Media | Optimizada |
| **Arquitectura** | Monolítica | Clean Architecture |
| **Navegación** | Manual | Declarativa (GoRouter) |
| **Animaciones** | Básicas | Fluidas y profesionales |

---

## 📄 Licencia

© 2026 FutBase. Todos los derechos reservados.

---

## 📧 Contacto

- Email: contacto@futbase.com
- Soporte: soporte@futbase.com

---

**Desarrollado con ❤️ usando Flutter Web**
