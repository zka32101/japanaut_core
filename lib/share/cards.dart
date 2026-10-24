import 'package:flutter/material.dart';

import '../brand/app_brand.dart';
import '../travel/region_tile_map.dart';
import '../travel/stamp_badge.dart';
import '../travel/visit.dart';
import '../travel/visit_stats.dart';
import 'share_card_frame.dart';
import 'share_card_labels.dart';

const _ink = Color(0xFF1D1D1D);
const _muted = Color(0xFF6B6B6B);

// ── 旅のしおり ───────────────────────────────────────────────────────────

/// しおりカードに載せるスポット 1 件。
class TripCardSpot {
  const TripCardSpot({required this.title, this.imageUrl, this.note});
  final String title;
  final String? imageUrl;
  final String? note;
}

/// しおりカードの 1 日分。日割りが無いプランは [dayNumber] が null の 1 件だけ。
class TripCardDay {
  const TripCardDay({this.dayNumber, required this.spots});
  final int? dayNumber;
  final List<TripCardSpot> spots;
}

/// 旅のしおりカード: プラン名、日ごとのスポット（小さな写真つき）。
/// 入りきらない分は「+N」にまとめる。
class TripShareCard extends StatelessWidget {
  const TripShareCard({
    super.key,
    required this.style,
    required this.brand,
    required this.title,
    required this.days,
    this.labels = const ShareCardLabels(),
  });

  /// カードに並べる行（日の見出しも 1 行と数える）の上限。
  static const maxRows = 8;

  final CardFrameStyle style;
  final AppBrand brand;
  final String title;
  final List<TripCardDay> days;
  final ShareCardLabels labels;

  @override
  Widget build(BuildContext context) {
    final total = days.fold<int>(0, (n, d) => n + d.spots.length);
    final accent = style.gradient(brand.primaryColor).last;

    final rows = <Widget>[];
    var used = 0;
    var shown = 0;
    outer:
    for (final day in days) {
      if (day.spots.isEmpty) continue;
      if (day.dayNumber != null) {
        if (used + 2 > maxRows) break; // 見出しだけで終わらせない
        rows.add(_DayHeader(
          text: ShareCardLabels.fill(labels.dayN, [day.dayNumber!]),
          color: accent,
        ));
        used++;
      }
      for (final spot in day.spots) {
        if (used >= maxRows) break outer;
        rows.add(_SpotRow(spot: spot, accent: accent));
        used++;
        shown++;
      }
    }
    final hidden = total - shown;

    return ShareCardFrame(
      style: style,
      brand: brand,
      title: title,
      subtitle: ShareCardLabels.fill(labels.spotsN, [total]),
      // 万一はみ出しても描画エラーにせず、スクロールさせずに切る。
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...rows,
          if (hidden > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                ShareCardLabels.fill(labels.moreN, [hidden]),
                style: const TextStyle(fontSize: 12, color: _muted),
              ),
            ),
        ],
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _SpotRow extends StatelessWidget {
  const _SpotRow({required this.spot, required this.accent});
  final TripCardSpot spot;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final note = spot.note;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 28,
              height: 28,
              child: spot.imageUrl == null
                  ? ColoredBox(color: accent.withValues(alpha: 0.2))
                  : Image.network(
                      spot.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          ColoredBox(color: accent.withValues(alpha: 0.2)),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note == null || note.isEmpty
                  ? spot.title
                  : '${spot.title} — $note',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: _ink),
            ),
          ),
        ],
      ),
    );
  }
}

// ── スタンプ帳 / 地域マップ ──────────────────────────────────────────────

/// 行った地域を色づけたタイルマップ + 最近押したスタンプ。
class StampBookShareCard extends StatelessWidget {
  const StampBookShareCard({
    super.key,
    required this.style,
    required this.brand,
    required this.regions,
    required this.visits,
    this.labels = const ShareCardLabels(),
    this.stampCount = 3,
  });

  final CardFrameStyle style;
  final AppBrand brand;
  final List<Region> regions;
  final List<VisitRecord> visits;
  final ShareCardLabels labels;

  /// 下に並べる最新のスタンプの数。
  final int stampCount;

  @override
  Widget build(BuildContext context) {
    final accent = style.gradient(brand.primaryColor).last;
    final visited = visitedRegionIds(visits)
        .where((id) => regions.any((r) => r.id == id))
        .toSet();
    final first = firstVisitByRegion(visits);
    final latest = (visited.toList()
          ..sort((a, b) => first[b]!.compareTo(first[a]!)))
        .take(stampCount);
    String labelOf(String id) => regions.firstWhere((r) => r.id == id).label;

    return ShareCardFrame(
      style: style,
      brand: brand,
      title: labels.stampBook,
      subtitle: ShareCardLabels.fill(labels.progress, [visited.length, regions.length]),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: RegionTileMap(
                regions: regions,
                visitedIds: visited,
                color: accent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final id in latest)
                StampBadge(
                  label: labelOf(id),
                  color: accent,
                  date: _ymd(first[id]!),
                  size: 70,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 年間まとめ ───────────────────────────────────────────────────────────

/// 1 年のまとめカード: 場所の数・地域の数・いちばん多い月・写真のコラージュ。
class YearSummaryShareCard extends StatelessWidget {
  const YearSummaryShareCard({
    super.key,
    required this.style,
    required this.brand,
    required this.summary,
    this.labels = const ShareCardLabels(),
  });

  final CardFrameStyle style;
  final AppBrand brand;
  final YearSummary summary;
  final ShareCardLabels labels;

  @override
  Widget build(BuildContext context) {
    final accent = style.gradient(brand.primaryColor).last;
    final month = summary.busiestMonth;
    return ShareCardFrame(
      style: style,
      brand: brand,
      title: ShareCardLabels.fill(labels.yearTitle, [summary.year]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _Stat(
                    value: '${summary.spotCount}',
                    label: labels.visitedSpots,
                    color: accent),
              ),
              Expanded(
                child: _Stat(
                    value: '${summary.regionCount}',
                    label: labels.visitedRegions,
                    color: accent),
              ),
              if (month != null)
                Expanded(
                  child: _Stat(
                      value: ShareCardLabels.fill(labels.monthN, [month]),
                      label: labels.busiestMonth,
                      color: accent),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: _Collage(photos: summary.photos, accent: accent)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.w800, color: color),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: _muted),
        ),
      ],
    );
  }
}

/// 写真を 3 列で敷き詰める（足りない分はうすい色のタイル）。
class _Collage extends StatelessWidget {
  const _Collage({required this.photos, required this.accent});
  final List<String> photos;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    const cols = 3;
    const count = 6;
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: cols,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: [
        for (var i = 0; i < count; i++)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: i < photos.length
                ? Image.network(
                    photos[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        ColoredBox(color: accent.withValues(alpha: 0.15)),
                  )
                : ColoredBox(color: accent.withValues(alpha: 0.15)),
          ),
      ],
    );
  }
}

String _ymd(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
