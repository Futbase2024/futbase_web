import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:futbase_web_3/core/theme/app_colors.dart';
import 'package:futbase_web_3/features/matches/presentation/widgets/home_away_indicator.dart';

void main() {
  group('HomeAwayIndicator', () {
    testWidgets('shows home icon when isAway is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeAwayIndicator(isAway: false),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.flight_takeoff), findsNothing);
    });

    testWidgets('shows away icon when isAway is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeAwayIndicator(isAway: true),
          ),
        ),
      );

      expect(find.byIcon(Icons.flight_takeoff), findsOneWidget);
      expect(find.byIcon(Icons.home), findsNothing);
    });

    testWidgets('home icon uses primary color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeAwayIndicator(isAway: false),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, AppColors.primary);
    });

    testWidgets('away icon uses error color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeAwayIndicator(isAway: true),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, AppColors.error);
    });

    testWidgets('shows label when showLabel is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeAwayIndicator(
              isAway: false,
              showLabel: true,
            ),
          ),
        ),
      );

      expect(find.text('Casa'), findsOneWidget);
    });

    testWidgets('shows away label when isAway and showLabel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeAwayIndicator(
              isAway: true,
              showLabel: true,
            ),
          ),
        ),
      );

      expect(find.text('Fuera'), findsOneWidget);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeAwayIndicator(
              isAway: false,
              size: 32.0,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 32.0);
    });

    testWidgets('fromMatch creates indicator from match data - Home', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeAwayIndicator.fromMatch(
              match: {'casafuera': 0},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('fromMatch creates indicator from match data - Away', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeAwayIndicator.fromMatch(
              match: {'casafuera': 1},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.flight_takeoff), findsOneWidget);
    });

    testWidgets('fromMatch handles boolean casafuera', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeAwayIndicator.fromMatch(
              match: {'casafuera': true},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.flight_takeoff), findsOneWidget);
    });
  });
}
