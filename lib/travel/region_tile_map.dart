import 'package:flutter/material.dart';

import 'visit.dart';

/// 地域をタイル（正方形）で並べた地図。行った地域は [color] で塗り、
/// まだの地域はうすい灰色。タイルの位置は [Region.col]/[Region.row]。
class RegionTileMap extends StatelessWidget {
  const RegionTileMap({
    super.key,
    required this.regions,
    required this.visitedIds,
    required this.color,
    this.gap = 2,
  });

  final List<Region> regions;
  final Set<String> visitedIds;
  final Color color;
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (regions.isEmpty) return const SizedBox.shrink();
    final cols = regions.map((r) => r.col).reduce((a, b) => a > b ? a : b) + 1;
    final rows = regions.map((r) => r.row).reduce((a, b) => a > b ? a : b) + 1;

    return AspectRatio(
      aspectRatio: cols / rows,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cell = constraints.maxWidth / cols;
          final fontSize = (cell * 0.34).clamp(7.0, 14.0);
          return Stack(
            children: [
              for (final r in regions)
                Positioned(
                  left: r.col * cell + gap / 2,
                  top: r.row * cell + gap / 2,
                  width: cell - gap,
                  height: cell - gap,
                  child: _Tile(
                    label: r.label,
                    visited: visitedIds.contains(r.id),
                    color: color,
                    fontSize: fontSize,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.visited,
    required this.color,
    required this.fontSize,
  });

  final String label;
  final bool visited;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: visited ? color : const Color(0xFFE6E3DD),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        // 3 文字の県名（北海道・神奈川など）もタイル幅に収まるよう縮める。
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontSize: fontSize,
              height: 1,
              fontWeight: visited ? FontWeight.bold : FontWeight.normal,
              color: visited ? Colors.white : const Color(0xFF8A867F),
            ),
          ),
        ),
      ),
    );
  }
}
