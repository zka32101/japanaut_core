import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showglobe_core/showglobe_core.dart';

VisitRecord _v(String place, DateTime at, {String? region, String? image}) =>
    VisitRecord(
      placeId: place,
      title: place,
      visitedAt: at,
      regionId: region,
      imageUrl: image,
    );

void main() {
  group('summarizeYear', () {
    final visits = [
      _v('a', DateTime(2026, 3, 1), region: 'tokyo', image: 'a.jpg'),
      _v('a', DateTime(2026, 3, 20), region: 'tokyo'), // same place again
      _v('b', DateTime(2026, 5, 2), region: 'kyoto', image: 'b.jpg'),
      _v('c', DateTime(2026, 5, 9), region: 'kyoto'),
      _v('d', DateTime(2025, 12, 31), region: 'osaka', image: 'd.jpg'),
    ];

    test('counts places once, regions once, and ignores other years', () {
      final s = summarizeYear(visits, 2026);
      expect(s.spotCount, 3);
      expect(s.visitCount, 4);
      expect(s.regionCount, 2);
      expect(s.firstVisit, DateTime(2026, 3, 1));
      expect(s.lastVisit, DateTime(2026, 5, 9));
      expect(s.isEmpty, isFalse);
    });

    test('busiest month: most visits, earlier month wins a tie', () {
      // March has 2 visits, May has 2 → March.
      expect(summarizeYear(visits, 2026).busiestMonth, 3);
      final may = [...visits, _v('e', DateTime(2026, 5, 20))];
      expect(summarizeYear(may, 2026).busiestMonth, 5);
    });

    test('photos are newest first and capped', () {
      expect(summarizeYear(visits, 2026).photos, ['b.jpg', 'a.jpg']);
      expect(summarizeYear(visits, 2026, maxPhotos: 1).photos, ['b.jpg']);
    });

    test('an empty year is empty', () {
      final s = summarizeYear(visits, 2024);
      expect(s.isEmpty, isTrue);
      expect(s.busiestMonth, isNull);
      expect(s.firstVisit, isNull);
    });
  });

  test('visitedRegionIds and firstVisitByRegion', () {
    final visits = [
      _v('a', DateTime(2026, 4, 1), region: 'tokyo'),
      _v('b', DateTime(2026, 2, 1), region: 'tokyo'),
      _v('c', DateTime(2026, 3, 1)), // no region
    ];
    expect(visitedRegionIds(visits), {'tokyo'});
    expect(firstVisitByRegion(visits)['tokyo'], DateTime(2026, 2, 1));
  });

  test('StampBadge angle is stable and small', () {
    expect(StampBadge.angleFor('東京'), StampBadge.angleFor('東京'));
    for (final l in ['東京', '京都', 'Osaka', '']) {
      expect(StampBadge.angleFor(l).abs(), lessThanOrEqualTo(0.2));
    }
  });

  testWidgets('RegionTileMap paints a tile per region', (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          child: RegionTileMap(
            regions: [
              Region(id: 'a', label: 'A', col: 0, row: 0),
              Region(id: 'b', label: 'B', col: 1, row: 0),
              Region(id: 'c', label: 'C', col: 0, row: 1),
            ],
            visitedIds: {'a'},
            color: Colors.red,
          ),
        ),
      ),
    ));
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });
}
