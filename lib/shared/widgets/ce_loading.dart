import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Widget de loading profesional con temática de fútbol para FutBase 3.0
///
/// Muestra un cronómetro de partido animado por defecto.
/// Opcionalmente puede mostrar otras animaciones de fútbol:
/// - Cronómetro de partido (por defecto)
/// - Balón botando
/// - Pizarra táctica
/// - Campo de fútbol
///
/// Variantes disponibles:
/// - [CELoadingVariant.fullscreen]: Loading a pantalla completa
/// - [CELoadingVariant.inline]: Loading inline para usar dentro de widgets
/// - [CELoadingVariant.button]: Loading compacto para botones
/// - [CELoadingVariant.overlay]: Loading con overlay semitransparente
///
/// Uso:
/// ```dart
/// // Cronómetro (por defecto)
/// const CELoading.inline()
///
/// // Otra animación específica
/// const CELoading.inline(animation: CELoadingAnimation.bouncingBall)
/// ```
enum CELoadingVariant {
  fullscreen,
  inline,
  button,
  overlay,
}

/// Tipos de animación disponibles
enum CELoadingAnimation {
  stopwatch,
  bouncingBall,
  tacticalBoard,
  soccerField,
}

class CELoading extends StatelessWidget {
  const CELoading({
    super.key,
    this.variant = CELoadingVariant.inline,
    this.message,
    this.size,
    this.animation,
  });

  const CELoading.fullscreen({
    super.key,
    this.message,
    this.size,
    this.animation,
  }) : variant = CELoadingVariant.fullscreen;

  const CELoading.inline({
    super.key,
    this.message,
    this.size,
    this.animation,
  }) : variant = CELoadingVariant.inline;

  const CELoading.button({
    super.key,
    this.size,
    this.animation,
  }) : message = null,
       variant = CELoadingVariant.button;

  const CELoading.overlay({
    super.key,
    this.message,
    this.size,
    this.animation,
  }) : variant = CELoadingVariant.overlay;

  final CELoadingVariant variant;
  final String? message;
  final double? size;
  final CELoadingAnimation? animation;

  @override
  Widget build(BuildContext context) {
    // Por defecto usar cronómetro, o aleatorio si se especifica
    final selectedAnimation = animation ?? CELoadingAnimation.stopwatch;

    switch (variant) {
      case CELoadingVariant.fullscreen:
        return _FullscreenLoading(message: message, size: size, animation: selectedAnimation);
      case CELoadingVariant.inline:
        return _InlineLoading(message: message, size: size, animation: selectedAnimation);
      case CELoadingVariant.button:
        return _ButtonLoading(size: size);
      case CELoadingVariant.overlay:
        return _OverlayLoading(message: message, size: size, animation: selectedAnimation);
    }
  }
}

/// Loading a pantalla completa
class _FullscreenLoading extends StatelessWidget {
  const _FullscreenLoading({this.message, this.size, required this.animation});

  final String? message;
  final double? size;
  final CELoadingAnimation animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDark,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnimation(size ?? 100),
            if (message != null) ...[
              AppSpacing.vSpaceLg,
              Text(
                message!,
                style: AppTypography.labelMedium.copyWith(color: AppColors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimation(double size) {
    switch (animation) {
      case CELoadingAnimation.stopwatch:
        return _StopwatchAnimation(size: size);
      case CELoadingAnimation.bouncingBall:
        return _BouncingBallAnimation(size: size);
      case CELoadingAnimation.tacticalBoard:
        return _TacticalBoardAnimation(size: size);
      case CELoadingAnimation.soccerField:
        return _SoccerFieldAnimation(size: size);
    }
  }
}

/// Loading inline
class _InlineLoading extends StatelessWidget {
  const _InlineLoading({this.message, this.size, required this.animation});

  final String? message;
  final double? size;
  final CELoadingAnimation animation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnimation(size ?? 70),
          if (message != null) ...[
            AppSpacing.vSpaceMd,
            Text(
              message!,
              style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimation(double size) {
    switch (animation) {
      case CELoadingAnimation.stopwatch:
        return _StopwatchAnimation(size: size);
      case CELoadingAnimation.bouncingBall:
        return _BouncingBallAnimation(size: size);
      case CELoadingAnimation.tacticalBoard:
        return _TacticalBoardAnimation(size: size);
      case CELoadingAnimation.soccerField:
        return _SoccerFieldAnimation(size: size);
    }
  }
}

/// Loading para botones
class _ButtonLoading extends StatelessWidget {
  const _ButtonLoading({this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    return _SpinningBall(size: size ?? 20);
  }
}

/// Loading con overlay
class _OverlayLoading extends StatelessWidget {
  const _OverlayLoading({this.message, this.size, required this.animation});

  final String? message;
  final double? size;
  final CELoadingAnimation animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDark.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          padding: AppSpacing.paddingXl,
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: AppSpacing.borderRadiusLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnimation(size ?? 80),
              if (message != null) ...[
                AppSpacing.vSpaceMd,
                Text(
                  message!,
                  style: AppTypography.labelMedium.copyWith(color: AppColors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimation(double size) {
    switch (animation) {
      case CELoadingAnimation.stopwatch:
        return _StopwatchAnimation(size: size);
      case CELoadingAnimation.bouncingBall:
        return _BouncingBallAnimation(size: size);
      case CELoadingAnimation.tacticalBoard:
        return _TacticalBoardAnimation(size: size);
      case CELoadingAnimation.soccerField:
        return _SoccerFieldAnimation(size: size);
    }
  }
}

// ============================================================================
// ANIMACIÓN 1: CRONÓMETRO DE PARTIDO
// ============================================================================

class _StopwatchAnimation extends StatefulWidget {
  const _StopwatchAnimation({required this.size});

  final double size;

  @override
  State<_StopwatchAnimation> createState() => _StopwatchAnimationState();
}

class _StopwatchAnimationState extends State<_StopwatchAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _StopwatchPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _StopwatchPainter extends CustomPainter {
  _StopwatchPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.85;

    // Círculo exterior
    final outerPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06;

    canvas.drawCircle(center, radius, outerPaint);

    // Círculo interior
    final innerPaint = Paint()
      ..color = AppColors.cardDark
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.85, innerPaint);

    // Marcas de minutos
    final markPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.015;

    for (var i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final startRadius = radius * 0.7;
      final endRadius = radius * 0.8;
      canvas.drawLine(
        Offset(center.dx + startRadius * math.cos(angle), center.dy + startRadius * math.sin(angle)),
        Offset(center.dx + endRadius * math.cos(angle), center.dy + endRadius * math.sin(angle)),
        markPaint,
      );
    }

    // Aguja que gira
    final needleAngle = progress * 2 * math.pi - math.pi / 2;
    final needlePaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.6 * math.cos(needleAngle), center.dy + radius * 0.6 * math.sin(needleAngle)),
      needlePaint,
    );

    // Centro
    final centerPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size.width * 0.04, centerPaint);

    // Texto del tiempo
    final seconds = (progress * 60).toInt() % 60;
    final textSpan = TextSpan(
      text: '${seconds.toString().padLeft(2, '0')}\'',
      style: TextStyle(
        color: AppColors.white,
        fontSize: size.width * 0.18,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy + radius * 0.15));
  }

  @override
  bool shouldRepaint(covariant _StopwatchPainter oldDelegate) => progress != oldDelegate.progress;
}

// ============================================================================
// ANIMACIÓN 2: BALÓN BOTANDO
// ============================================================================

class _BouncingBallAnimation extends StatefulWidget {
  const _BouncingBallAnimation({required this.size});

  final double size;

  @override
  State<_BouncingBallAnimation> createState() => _BouncingBallAnimationState();
}

class _BouncingBallAnimationState extends State<_BouncingBallAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size * 1.2),
          painter: _BouncingBallPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _BouncingBallPainter extends CustomPainter {
  _BouncingBallPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final ballRadius = size.width * 0.15;
    final bounceHeight = size.height * 0.35;
    final groundY = size.height - size.height * 0.15;

    // Calcular posición del balón (curva de rebote)
    final ballY = groundY - ballRadius - bounceHeight * (1 - (progress * 2 - 1).abs());
    final ballX = size.width / 2;

    // Sombra elástica
    final shadowScale = 0.5 + 0.5 * (progress * 2 - 1).abs();
    final shadowOpacity = 0.1 + 0.15 * (progress * 2 - 1).abs();

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: shadowOpacity);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(ballX, groundY),
        width: ballRadius * 2 * shadowScale,
        height: ballRadius * 0.4 * shadowScale,
      ),
      shadowPaint,
    );

    // Dibujar balón
    _drawBall(canvas, Offset(ballX, ballY), ballRadius);

    // Línea del suelo
    final groundPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(size.width * 0.1, groundY),
      Offset(size.width * 0.9, groundY),
      groundPaint,
    );
  }

  void _drawBall(Canvas canvas, Offset center, double radius) {
    // Balón con gradiente
    final ballPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [AppColors.accent, AppColors.primary],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, ballPaint);

    // Pentágonos
    final patternPaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.fill;

    final path = Path();
    for (var i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * math.pi / 180;
      final x = center.dx + radius * 0.4 * math.cos(angle);
      final y = center.dy + radius * 0.4 * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, patternPaint);

    // Brillo
    final shinePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.5, -0.5),
        colors: [Colors.white.withValues(alpha: 0.6), Colors.white.withValues(alpha: 0)],
        stops: const [0, 0.5],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius * 0.9, shinePaint);
  }

  @override
  bool shouldRepaint(covariant _BouncingBallPainter oldDelegate) => progress != oldDelegate.progress;
}

// ============================================================================
// ANIMACIÓN 3: PIZARRA TÁCTICA
// ============================================================================

class _TacticalBoardAnimation extends StatefulWidget {
  const _TacticalBoardAnimation({required this.size});

  final double size;

  @override
  State<_TacticalBoardAnimation> createState() => _TacticalBoardAnimationState();
}

class _TacticalBoardAnimationState extends State<_TacticalBoardAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size * 0.8),
          painter: _TacticalBoardPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _TacticalBoardPainter extends CustomPainter {
  _TacticalBoardPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo de pizarra
    final bgPaint = Paint()
      ..color = AppColors.primaryDark.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgRRect = RRect.fromRectAndRadius(bgRect, const Radius.circular(8));
    canvas.drawRRect(bgRRect, bgPaint);

    // Borde
    final borderPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(bgRRect, borderPaint);

    // Jugadores (círculos)
    final playerPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    final playerPositions = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.8, size.height * 0.3),
      Offset(size.width * 0.35, size.height * 0.6),
      Offset(size.width * 0.65, size.height * 0.6),
    ];

    // Flechas de movimiento (animadas)
    final arrowPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final arrowProgress = (progress * 2) % 1.0;

    // Dibujar jugadores y flechas
    for (var i = 0; i < playerPositions.length; i++) {
      final pos = playerPositions[i];

      // Jugador
      canvas.drawCircle(pos, size.width * 0.05, playerPaint);

      // Flecha hacia siguiente posición
      if (i < playerPositions.length - 1) {
        final nextPos = playerPositions[i + 1];
        final arrowEnd = Offset(
          pos.dx + (nextPos.dx - pos.dx) * arrowProgress * 0.5,
          pos.dy + (nextPos.dy - pos.dy) * arrowProgress * 0.5,
        );

        canvas.drawLine(pos, arrowEnd, arrowPaint);

        // Punta de flecha
        if (arrowProgress > 0.3) {
          final angle = math.atan2(nextPos.dy - pos.dy, nextPos.dx - pos.dx);
          final arrowSize = size.width * 0.03;

          final arrowPath = Path()
            ..moveTo(arrowEnd.dx, arrowEnd.dy)
            ..lineTo(
              arrowEnd.dx - arrowSize * math.cos(angle - math.pi / 6),
              arrowEnd.dy - arrowSize * math.sin(angle - math.pi / 6),
            )
            ..moveTo(arrowEnd.dx, arrowEnd.dy)
            ..lineTo(
              arrowEnd.dx - arrowSize * math.cos(angle + math.pi / 6),
              arrowEnd.dy - arrowSize * math.sin(angle + math.pi / 6),
            );

          canvas.drawPath(arrowPath, arrowPaint);
        }
      }
    }

    // Balón al final
    final ballPos = Offset(
      size.width * 0.8 + math.sin(progress * math.pi * 4) * size.width * 0.05,
      size.height * 0.7,
    );

    final ballPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(ballPos, size.width * 0.035, ballPaint);
  }

  @override
  bool shouldRepaint(covariant _TacticalBoardPainter oldDelegate) => progress != oldDelegate.progress;
}

// ============================================================================
// ANIMACIÓN 4: CAMPO DE FÚTBOL
// ============================================================================

class _SoccerFieldAnimation extends StatefulWidget {
  const _SoccerFieldAnimation({required this.size});

  final double size;

  @override
  State<_SoccerFieldAnimation> createState() => _SoccerFieldAnimationState();
}

class _SoccerFieldAnimationState extends State<_SoccerFieldAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: math.sin(_controller.value * math.pi * 2) * 0.05,
          child: CustomPaint(
            size: Size(widget.size, widget.size * 0.65),
            painter: _SoccerFieldPainter(progress: _controller.value),
          ),
        );
      },
    );
  }
}

class _SoccerFieldPainter extends CustomPainter {
  _SoccerFieldPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Campo verde
    final fieldPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final fieldRRect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
    canvas.drawRRect(fieldRRect, fieldPaint);

    // Líneas del campo
    final linePaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Borde
    canvas.drawRRect(fieldRRect, linePaint);

    // Línea central
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      linePaint,
    );

    // Círculo central
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.12,
      linePaint,
    );

    // Áreas
    final areaWidth = size.width * 0.15;
    final areaHeight = size.height * 0.5;
    final areaTop = (size.height - areaHeight) / 2;

    // Área izquierda
    canvas.drawRect(
      Rect.fromLTWH(0, areaTop, areaWidth, areaHeight),
      linePaint,
    );

    // Área derecha
    canvas.drawRect(
      Rect.fromLTWH(size.width - areaWidth, areaTop, areaWidth, areaHeight),
      linePaint,
    );

    // Porterías
    final goalWidth = size.width * 0.02;
    final goalHeight = size.height * 0.3;
    final goalTop = (size.height - goalHeight) / 2;

    final goalPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Portería izquierda
    canvas.drawRect(
      Rect.fromLTWH(-goalWidth, goalTop, goalWidth, goalHeight),
      goalPaint,
    );

    // Portería derecha
    canvas.drawRect(
      Rect.fromLTWH(size.width, goalTop, goalWidth, goalHeight),
      goalPaint,
    );

    // Balón moviéndose
    final ballX = size.width * 0.2 + (size.width * 0.6) * progress;
    final ballY = size.height * 0.5 + math.sin(progress * math.pi * 4) * size.height * 0.15;

    final ballPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(ballX, ballY), size.width * 0.03, ballPaint);

    // Estela del balón
    final trailCount = 4;
    for (var i = 1; i <= trailCount; i++) {
      final trailProgress = (progress - i * 0.03).clamp(0.0, 1.0);
      final trailX = size.width * 0.2 + (size.width * 0.6) * trailProgress;
      final trailY = size.height * 0.5 + math.sin(trailProgress * math.pi * 4) * size.height * 0.15;
      final trailOpacity = (1 - i / trailCount) * 0.3;

      final trailPaint = Paint()
        ..color = AppColors.accent.withValues(alpha: trailOpacity);

      canvas.drawCircle(Offset(trailX, trailY), size.width * 0.02 * (1 - i / trailCount), trailPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SoccerFieldPainter oldDelegate) => progress != oldDelegate.progress;
}

// ============================================================================
// BALÓN GIRATORIO PARA BOTONES
// ============================================================================

class _SpinningBall extends StatefulWidget {
  const _SpinningBall({required this.size});

  final double size;

  @override
  State<_SpinningBall> createState() => _SpinningBallState();
}

class _SpinningBallState extends State<_SpinningBall>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _SmallBallPainter(),
          ),
        );
      },
    );
  }
}

class _SmallBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final ballPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [AppColors.white, AppColors.white.withValues(alpha: 0.8)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius * 0.9, ballPaint);

    final patternPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    for (var i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * math.pi / 180;
      final x = center.dx + radius * 0.3 * math.cos(angle);
      final y = center.dy + radius * 0.3 * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, patternPaint);

    final shinePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.5, -0.5),
        colors: [Colors.white.withValues(alpha: 0.7), Colors.white.withValues(alpha: 0)],
        stops: const [0, 0.4],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius * 0.85, shinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
