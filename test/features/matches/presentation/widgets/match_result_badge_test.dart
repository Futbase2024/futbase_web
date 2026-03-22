import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:futbase_web_3/core/theme/app_colors.dart';
import 'package:futbase_web_3/features/matches/presentation/widgets/match_result_badge.dart';
import 'package:futbase_web_3/features/matches/presentation/widgets/result_style.dart';

/// Tests para MatchResultBadge y ResultStyle
void main() {
  group('ResultStyle', () {
    test('fromScore returns victory style for win', () {
      final style = ResultStyle.fromScore(goles: 3, golesrival: 1);

      expect(style.color, AppColors.primary);
      expect(style.icon, Icons.emoji_events_outlined);
      expect(style.text, 'Victoria');
      expect(style.type, MatchResultType.victory);
    });

    test('fromScore returns defeat style for loss', () {
      final style = ResultStyle.fromScore(goles: 1, golesrival: 3);

      expect(style.color, AppColors.error);
      expect(style.icon, Icons.close);
      expect(style.text, 'Derrota');
      expect(style.type, MatchResultType.defeat);
    });

    test('fromScore returns draw style for tie', () {
      final style = ResultStyle.fromScore(goles: 2, golesrival: 2);

      expect(style.color, AppColors.gray800);
      expect(style.icon, Icons.handshake_outlined);
      expect(style.text, 'Empate');
      expect(style.type, MatchResultType.draw);
    });

    test('backgroundColor returns color with alpha 0.1', () {
      final style = ResultStyle.fromScore(goles: 3, golesrival: 1);
      expect(style.backgroundColor, AppColors.primary.withValues(alpha: 0.1));
    });

    test('backgroundStrong returns color with alpha 0.15', () {
      final style = ResultStyle.fromScore(goles: 3, golesrival: 1);
      expect(style.backgroundStrong, AppColors.primary.withValues(alpha: 0.15));
    });
  });

  group('MatchResultBadge', () {
    testWidgets('renders victory badge with score', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchResultBadge(
              goles: 3,
              golesrival: 1,
            ),
          ),
        ),
      );

      expect(find.text('3-1'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
    });

    testWidgets('renders defeat badge with score', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchResultBadge(
              goles: 1,
              golesrival: 3,
            ),
          ),
        ),
      );

      expect(find.text('1-3'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders draw badge with score', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchResultBadge(
              goles: 2,
              golesrival: 2,
            ),
          ),
        ),
      );

      expect(find.text('2-2'), findsOneWidget);
      expect(find.byIcon(Icons.handshake_outlined), findsOneWidget);
    });

    testWidgets('shows text when showText is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchResultBadge(
              goles: 3,
              golesrival: 1,
              showText: true,
            ),
          ),
        ),
      );

      expect(find.text('Victoria'), findsOneWidget);
    });

    testWidgets('hides icon when showIcon is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchResultBadge(
              goles: 3,
              golesrival: 1,
              showIcon: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.emoji_events_outlined), findsNothing);
    });

    testWidgets('small size has correct padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchResultBadge(
              goles: 3,
              golesrival: 1,
              size: MatchResultBadgeSize.small,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(
        (container.decoration as BoxDecoration).color,
        AppColors.primary.withValues(alpha: 0.1),
      );
    });

    testWidgets('medium size has correct padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchResultBadge(
              goles: 3,
              golesrival: 1,
              size: MatchResultBadgeSize.medium,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(
        (container.decoration as BoxDecoration).color,
        AppColors.primary.withValues(alpha: 0.1),
      );
    });
  });
}
