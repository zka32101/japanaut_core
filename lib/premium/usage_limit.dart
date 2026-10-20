import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 無料枠の集計期間。
enum UsagePeriod { daily, weekly }

/// 機能ごとの「無料ユーザーは期間あたり N 回まで」を数える。
///
/// 例: `UsageLimit(key: 'audio_guide', period: UsagePeriod.daily, freeLimit: 3)`。
/// プレミアムなら常に使える。回数は期間が変わると自動で 0 に戻る。
class UsageLimit {
  const UsageLimit({
    required this.key,
    required this.period,
    required this.freeLimit,
    this.clock = DateTime.now,
  });

  /// 保存キーの元（機能ごとに一意）。
  final String key;
  final UsagePeriod period;
  final int freeLimit;

  /// テストで日時を差し替えるための時計。
  final DateTime Function() clock;

  String get _prefsKey => 'usage_${key}_v1';

  /// 現在の期間を表す文字列（日: 2026-10-20、週: 2026-W03）。
  String get periodKey => switch (period) {
        UsagePeriod.daily => dateKey(clock()),
        UsagePeriod.weekly => weekKey(clock()),
      };

  Future<int> used() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return 0;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['period'] != periodKey) return 0;
      return (data['count'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> remaining() async => (freeLimit - await used()).clamp(0, freeLimit);

  Future<bool> canUse({required bool isPremium}) async {
    if (isPremium) return true;
    return await used() < freeLimit;
  }

  Future<void> record() async {
    final count = await used() + 1;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode({'period': periodKey, 'count': count}),
      );
    } catch (_) {}
  }

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// ISO 8601 の週番号（月曜始まり）。
  static String weekKey(DateTime d) {
    final date = DateTime.utc(d.year, d.month, d.day);
    final thursday = date.add(Duration(days: 4 - date.weekday));
    final week =
        (thursday.difference(DateTime.utc(thursday.year)).inDays ~/ 7) + 1;
    return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
  }
}
