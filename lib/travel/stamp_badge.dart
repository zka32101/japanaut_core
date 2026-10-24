import 'package:flutter/material.dart';

/// 行った地域に押すスタンプ。二重の丸の中に地域名と日付。
/// 角度は [label] から決まるので、同じスタンプはいつも同じ向きになる。
class StampBadge extends StatelessWidget {
  const StampBadge({
    super.key,
    required this.label,
    required this.color,
    this.date,
    this.size = 76,
  });

  final String label;
  final Color color;

  /// 小さく添える日付（例: 2026-10-24）。
  final String? date;
  final double size;

  /// -0.2〜0.2 ラジアンの、label から決まる傾き。
  static double angleFor(String label) {
    var h = 0;
    for (final c in label.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return ((h % 41) - 20) / 100;
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angleFor(label),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
        ),
        padding: const EdgeInsets.all(4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.7), width: 1),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                if (date != null)
                  Text(
                    date!,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: size * 0.12,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
