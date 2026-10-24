import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showglobe_core/showglobe_core.dart';

const _brand = AppBrand(
  series: kGlobalSeriesName,
  suffix: 'Japan',
  slug: 'trip',
  packageName: 'com.example.trip',
  tagline: 'Discover Japan',
  primaryColor: Color(0xFFE63946),
  supportEmail: 'a@example.com',
  countryCode: 'JP',
);

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  test('forDate picks the season of the month', () {
    CardFrameStyle at(int m) => CardFrameStyleX.forDate(DateTime(2026, m, 15));
    expect(at(3), CardFrameStyle.sakura);
    expect(at(6), CardFrameStyle.summer);
    expect(at(9), CardFrameStyle.momiji);
    expect(at(12), CardFrameStyle.snow);
    expect(at(2), CardFrameStyle.snow);
  });

  test('classic gradient is derived from the brand colour', () {
    final g = CardFrameStyle.classic.gradient(_brand.primaryColor);
    expect(g, hasLength(2));
    expect(g.first, isNot(g.last));
  });

  test('ShareCardLabels.fill replaces {} in order', () {
    expect(ShareCardLabels.fill('{} / {}', [3, 47]), '3 / 47');
    expect(ShareCardLabels.fill('Day {}', [2]), 'Day 2');
    expect(ShareCardLabels.fill('{} {}', [1]), '1 ');
    expect(ShareCardLabels.fill('none', [1]), 'none');
  });

  testWidgets('ShareCardFrame shows brand, country code and content',
      (t) async {
    await t.pumpWidget(_host(const ShareCardFrame(
      style: CardFrameStyle.classic,
      brand: _brand,
      title: 'Hello',
      subtitle: 'sub',
      child: Text('body'),
    )));
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('body'), findsOneWidget);
    expect(find.text('Showglobe Japan'), findsOneWidget);
    expect(find.text('JP'), findsOneWidget);
    expect(t.getSize(find.byType(ShareCardFrame)),
        const Size(ShareCardFrame.width, ShareCardFrame.height));
  });

  testWidgets('no country code → no plate', (t) async {
    const brand = AppBrand(
      suffix: 'Trip',
      slug: 'trip',
      packageName: 'x',
      tagline: 't',
      primaryColor: Colors.red,
      supportEmail: 'a@example.com',
    );
    await t.pumpWidget(_host(const ShareCardFrame(
      style: CardFrameStyle.classic,
      brand: brand,
      title: 'T',
      child: SizedBox(),
    )));
    expect(find.text('JP'), findsNothing);
  });

  testWidgets('TripShareCard lists days and spots, folding the overflow',
      (t) async {
    final days = [
      const TripCardDay(dayNumber: 1, spots: [
        TripCardSpot(title: 'Spot A', note: 'early'),
        TripCardSpot(title: 'Spot B'),
      ]),
      TripCardDay(dayNumber: 2, spots: [
        for (var i = 0; i < 10; i++) TripCardSpot(title: 'Spot C$i'),
      ]),
    ];
    await t.pumpWidget(_host(TripShareCard(
      style: CardFrameStyle.classic,
      brand: _brand,
      title: 'Kyoto trip',
      days: days,
    )));
    expect(find.text('Kyoto trip'), findsOneWidget);
    expect(find.text('12 spots'), findsOneWidget);
    expect(find.text('Day 1'), findsOneWidget);
    expect(find.text('Day 2'), findsOneWidget);
    expect(find.text('Spot A — early'), findsOneWidget);
    // 8 rows max: 2 headers + 6 spots → 4 of day 2 are shown, the rest folded.
    expect(find.text('Spot C3'), findsOneWidget);
    expect(find.text('Spot C4'), findsNothing);
    expect(find.text('+6 more'), findsOneWidget);
  });

  testWidgets('PhotoShareCard shows title, body and the highlighted phrase',
      (t) async {
    // 1x1 transparent PNG.
    final png = MemoryImage(Uint8List.fromList(const [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xFF, 0xFF, 0x3F,
      0x00, 0x05, 0xFE, 0x02, 0xFE, 0xA7, 0x35, 0x81, 0x84, 0x00, 0x00, 0x00,
      0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ]));
    await t.pumpWidget(_host(PhotoShareCard(
      style: CardFrameStyle.classic,
      brand: _brand,
      title: 'Fushimi Inari',
      subtitle: 'AI Lens',
      photo: png,
      body: 'Thousands of torii gates.',
      highlight: 'ありがとう',
      highlightSub: 'Thank you',
    )));
    expect(find.text('Fushimi Inari'), findsOneWidget);
    expect(find.text('Thousands of torii gates.'), findsOneWidget);
    expect(find.text('ありがとう'), findsOneWidget);
    expect(find.text('Thank you'), findsOneWidget);
  });

  testWidgets('StampBookShareCard shows progress and the newest stamps',
      (t) async {
    final regions = [
      for (var i = 0; i < 6; i++)
        Region(id: 'r$i', label: 'R$i', col: i % 3, row: i ~/ 3),
    ];
    final visits = [
      VisitRecord(
          placeId: 'p1',
          title: 'p1',
          visitedAt: DateTime(2026, 1, 5),
          regionId: 'r0'),
      VisitRecord(
          placeId: 'p2',
          title: 'p2',
          visitedAt: DateTime(2026, 2, 5),
          regionId: 'r1'),
    ];
    await t.pumpWidget(_host(StampBookShareCard(
      style: CardFrameStyle.classic,
      brand: _brand,
      regions: regions,
      visits: visits,
    )));
    expect(find.text('Stamp Book'), findsOneWidget);
    expect(find.text('2 / 6'), findsOneWidget);
    expect(find.byType(StampBadge), findsNWidgets(2));
    expect(find.text('2026-02-05'), findsOneWidget);
  });

  testWidgets('YearSummaryShareCard shows the totals', (t) async {
    final summary = summarizeYear([
      VisitRecord(
          placeId: 'a',
          title: 'a',
          visitedAt: DateTime(2026, 4, 2),
          regionId: 'x'),
    ], 2026);
    await t.pumpWidget(_host(YearSummaryShareCard(
      style: CardFrameStyle.classic,
      brand: _brand,
      summary: summary,
    )));
    expect(find.text('2026 in review'), findsOneWidget);
    expect(find.text('Month 4'), findsOneWidget);
  });

  testWidgets('sheet lets the user switch the seasonal frame', (t) async {
    await t.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showShareCardSheet(
            context,
            cardBuilder: (_, style) => ShareCardFrame(
              style: style,
              brand: _brand,
              title: 'T',
              child: Text('style:${style.name}'),
            ),
          ),
          child: const Text('open'),
        ),
      ),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    for (final s in CardFrameStyle.values) {
      expect(find.widgetWithText(ChoiceChip, s.emoji), findsOneWidget);
    }
    await t.tap(find.widgetWithText(ChoiceChip, CardFrameStyle.snow.emoji));
    await t.pumpAndSettle();
    expect(find.text('style:snow'), findsOneWidget);
  });

  testWidgets('a very long title does not overflow the header', (t) async {
    await t.pumpWidget(_host(ShareCardFrame(
      style: CardFrameStyle.classic,
      brand: _brand,
      title: 'とても長いタイトル ' * 12,
      subtitle: 'AI Lens',
      child: const SizedBox(),
    )));
    expect(tester(t), isNull); // no exception was thrown while laying out
  });
}

Object? tester(WidgetTester t) => t.takeException();
