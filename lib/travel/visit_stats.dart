import 'visit.dart';

/// 1 年分のまとめ。
class YearSummary {
  const YearSummary({
    required this.year,
    required this.spotCount,
    required this.visitCount,
    required this.regionCount,
    required this.busiestMonth,
    required this.photos,
    required this.firstVisit,
    required this.lastVisit,
  });

  final int year;

  /// 訪れた場所の数（同じ場所は 1 か所）。
  final int spotCount;

  /// 記録の数（同じ場所を複数回含む）。
  final int visitCount;

  /// 訪れた地域の数。
  final int regionCount;

  /// 記録がいちばん多い月（1〜12）。同数なら早い月。記録が無ければ null。
  final int? busiestMonth;

  /// 写真の URL（新しい順、最大 [summarizeYear] の maxPhotos 枚）。
  final List<String> photos;

  final DateTime? firstVisit;
  final DateTime? lastVisit;

  bool get isEmpty => visitCount == 0;
}

/// 訪れたことのある地域の ID。
Set<String> visitedRegionIds(Iterable<VisitRecord> visits) => {
      for (final v in visits)
        if (v.regionId != null) v.regionId!,
    };

/// 訪れた地域ごとの、最初に訪れた日。
Map<String, DateTime> firstVisitByRegion(Iterable<VisitRecord> visits) {
  final out = <String, DateTime>{};
  for (final v in visits) {
    final id = v.regionId;
    if (id == null) continue;
    final current = out[id];
    if (current == null || v.visitedAt.isBefore(current)) out[id] = v.visitedAt;
  }
  return out;
}

/// [year] 年の記録をまとめる。
YearSummary summarizeYear(
  Iterable<VisitRecord> visits,
  int year, {
  int maxPhotos = 6,
}) {
  final inYear = visits.where((v) => v.visitedAt.year == year).toList()
    ..sort((a, b) => b.visitedAt.compareTo(a.visitedAt)); // 新しい順

  final perMonth = <int, int>{};
  for (final v in inYear) {
    perMonth[v.visitedAt.month] = (perMonth[v.visitedAt.month] ?? 0) + 1;
  }
  // 月を早い順に見て、厳密に多いときだけ更新する（同数なら早い月が残る）。
  int? busiest;
  var best = 0;
  for (final month in (perMonth.keys.toList()..sort())) {
    if (perMonth[month]! > best) {
      best = perMonth[month]!;
      busiest = month;
    }
  }

  final photos = <String>[
    for (final v in inYear)
      if (v.imageUrl != null && v.imageUrl!.isNotEmpty) v.imageUrl!,
  ].take(maxPhotos).toList();

  return YearSummary(
    year: year,
    spotCount: inYear.map((v) => v.placeId).toSet().length,
    visitCount: inYear.length,
    regionCount: visitedRegionIds(inYear).length,
    busiestMonth: busiest,
    photos: photos,
    firstVisit: inYear.isEmpty ? null : inYear.last.visitedAt,
    lastVisit: inYear.isEmpty ? null : inYear.first.visitedAt,
  );
}
