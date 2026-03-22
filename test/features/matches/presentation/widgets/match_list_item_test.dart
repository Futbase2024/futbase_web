import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:futbase_web_3/features/matches/presentation/widgets/match_list_item.dart';
import 'package:futbase_web_3/features/matches/presentation/widgets/home_away_indicator.dart';
import 'package:futbase_web_3/features/matches/presentation/widgets/competition_badge.dart';
import 'package:futbase_web_3/features/matches/presentation/widgets/match_result_badge.dart';

void main() {
  group('MatchListItem', () {
    late Map<String, dynamic> testMatch;

    setUp(() {
      testMatch = {
        'rival': 'Real Madrid',
        'casafuera': 0,
        'fecha': '2024-03-15T20:00:00Z',
        'campo': 'Camp Nou',
        'goles': 3,
        'golesrival': 1,
        'finalizado': 1,
        'idjornada': 5,
        'jcorta': 'LALIGA',
      };
    });

    testWidgets('renders rival name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItem(match: testMatch),
          ),
        ),
      );

      expect(find.text('Real Madrid'), findsOneWidget);
    });

    testWidgets('renders HomeAwayIndicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItem(match: testMatch),
          ),
        ),
      );

      expect(find.byType(HomeAwayIndicator), findsOneWidget);
    });

    testWidgets('renders CompetitionBadge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItem(match: testMatch),
          ),
        ),
      );

      expect(find.byType(CompetitionBadge), findsOneWidget);
    });

    testWidgets('renders MatchResultBadge when match is finished', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItem(match: testMatch),
          ),
        ),
      );

      expect(find.byType(MatchResultBadge), findsOneWidget);
    });

    testWidgets('does not render MatchResultBadge when match is not finished', (tester) async {
      testMatch['finalizado'] = 0;
      testMatch['goles'] = null;
      testMatch['golesrival'] = null;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItem(match: testMatch),
          ),
        ),
      );

      expect(find.byType(MatchResultBadge), findsNothing);
      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('shows date in correct format', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItem(match: testMatch),
          ),
        ),
      );

      expect(find.textContaining('15/03/2024'), findsOneWidget);
    });

    testWidgets('shows campo when available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItem(match: testMatch),
          ),
        ),
      );

      expect(find.text('Camp Nou'), findsOneWidget);
    });

    testWidgets('hides campo in compact mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItem(match: testMatch, compact: true),
          ),
        ),
      );

      expect(find.text('Camp Nou'), findsNothing);
    });

    testWidgets('shows actions when showActions is true and callbacks provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItem(
              match: testMatch,
              showActions: true,
              onLineup: () {},
              onEdit: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.group_outlined), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('hides actions when showActions is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItem(
              match: testMatch,
              showActions: false,
              onLineup: () {},
              onEdit: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.group_outlined), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    });

    testWidgets('hides result when showResult is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItem(
              match: testMatch,
              showResult: false,
            ),
          ),
        ),
      );

      expect(find.byType(MatchResultBadge), findsNothing);
    });

    testWidgets('onTap callback works', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItem(
              match: testMatch,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MatchListItem));
      expect(tapped, true);
    });

    testWidgets('handles away match correctly', (tester) async {
      testMatch['casafuera'] = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItem(match: testMatch),
          ),
        ),
      );

      final indicator = tester.widget<HomeAwayIndicator>(find.byType(HomeAwayIndicator));
      expect(indicator.isAway, true);
    });

    testWidgets('handles amistoso match correctly', (tester) async {
      testMatch['idjornada'] = null;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItem(match: testMatch),
          ),
        ),
      );

      expect(find.text('AMISTOSO'), findsOneWidget);
    });

    testWidgets('handles null rival gracefully', (tester) async {
      testMatch['rival'] = null;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItem(match: testMatch),
          ),
        ),
      );

      expect(find.text('Sin rival'), findsOneWidget);
    });

    testWidgets('handles null fecha gracefully', (tester) async {
      testMatch['fecha'] = null;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItem(match: testMatch),
          ),
        ),
      );

      expect(find.text('Por definir'), findsOneWidget);
    });
  });

  group('MatchListItemCompact', () {
    testWidgets('renders in compact mode', (tester) async {
      final testMatch = {
        'rival': 'Barcelona',
        'casafuera': 0,
        'goles': 2,
        'golesrival': 2,
        'finalizado': 1,
        'idjornada': 1,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItemCompact(
              match: testMatch,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Barcelona'), findsOneWidget);
      expect(find.byType(MatchResultBadge), findsOneWidget);
    });

    testWidgets('does not show actions', (tester) async {
      final testMatch = {
        'rival': 'Barcelona',
        'casafuera': 0,
        'goles': 2,
        'golesrival': 2,
        'finalizado': 1,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchListItemCompact(match: testMatch),
          ),
        ),
      );

      expect(find.byIcon(Icons.group_outlined), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    });
  });
}
