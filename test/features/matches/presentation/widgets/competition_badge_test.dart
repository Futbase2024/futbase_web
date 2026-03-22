import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:futbase_web_3/core/theme/app_colors.dart';
import 'package:futbase_web_3/features/matches/presentation/widgets/competition_badge.dart';

void main() {
  group('CompetitionBadge', () {
    testWidgets('renders Liga badge with correct colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompetitionBadge(
              text: 'LIGA',
              isLiga: true,
            ),
          ),
        ),
      );

      expect(find.text('LIGA'), findsOneWidget);

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.primary.withValues(alpha: 0.1));
    });

    testWidgets('renders Amistoso badge with correct colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompetitionBadge(
              text: 'AMISTOSO',
              isLiga: false,
            ),
          ),
        ),
      );

      expect(find.text('AMISTOSO'), findsOneWidget);

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.gray100);
    });

    testWidgets('fromMatch creates badge from match data - Liga', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompetitionBadge.fromMatch(
              match: {'idjornada': 5, 'jcorta': 'LALIGA'},
            ),
          ),
        ),
      );

      expect(find.text('LALIGA'), findsOneWidget);
    });

    testWidgets('fromMatch creates badge from match data - Amistoso', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompetitionBadge.fromMatch(
              match: {'idjornada': null},
            ),
          ),
        ),
      );

      expect(find.text('AMISTOSO'), findsOneWidget);
    });

    testWidgets('fromMatch defaults to LIGA when jcorta is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompetitionBadge.fromMatch(
              match: {'idjornada': 1},
            ),
          ),
        ),
      );

      expect(find.text('LIGA'), findsOneWidget);
    });

    testWidgets('small size has correct padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompetitionBadge(
              text: 'LIGA',
              isLiga: true,
              size: CompetitionBadgeSize.small,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.padding, const EdgeInsets.symmetric(horizontal: 6, vertical: 3));
    });

    testWidgets('medium size has correct padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompetitionBadge(
              text: 'LIGA',
              isLiga: true,
              size: CompetitionBadgeSize.medium,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.padding, const EdgeInsets.symmetric(horizontal: 8, vertical: 4));
    });
  });
}
