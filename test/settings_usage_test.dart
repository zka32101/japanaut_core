import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:showglobe_core/showglobe_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('ThemeModeNotifier', () {
    test('encode/decode は往復でき、未知の値はシステム', () {
      for (final m in ThemeMode.values) {
        expect(ThemeModeNotifier.decode(ThemeModeNotifier.encode(m)), m);
      }
      expect(ThemeModeNotifier.decode(null), ThemeMode.system);
      expect(ThemeModeNotifier.decode('x'), ThemeMode.system);
    });

    test('保存した値を次回起動で読み戻す', () async {
      await ThemeModeNotifier().setThemeMode(ThemeMode.dark);
      final reloaded = ThemeModeNotifier();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(reloaded.state, ThemeMode.dark);
    });
  });

  group('UsageLimit', () {
    var now = DateTime(2026, 10, 20, 9);
    UsageLimit daily() => UsageLimit(
        key: 'guide',
        period: UsagePeriod.daily,
        freeLimit: 2,
        clock: () => now);

    test('無料は上限まで、プレミアムは常に使える', () async {
      final l = daily();
      expect(await l.canUse(isPremium: false), isTrue);
      await l.record();
      await l.record();
      expect(await l.canUse(isPremium: false), isFalse);
      expect(await l.canUse(isPremium: true), isTrue);
      expect(await l.remaining(), 0);
    });

    test('日が変わると回数が戻る', () async {
      final l = daily();
      await l.record();
      await l.record();
      now = DateTime(2026, 10, 21, 0, 1);
      expect(await l.used(), 0);
      now = DateTime(2026, 10, 20, 9);
    });

    test('週キーは ISO 週（年またぎ含む）', () {
      expect(UsageLimit.weekKey(DateTime(2026, 1, 1)), '2026-W01');
      expect(UsageLimit.weekKey(DateTime(2027, 1, 1)), '2026-W53');
      expect(UsageLimit.weekKey(DateTime(2026, 10, 19)), '2026-W43');
      expect(UsageLimit.weekKey(DateTime(2026, 10, 25)), '2026-W43');
    });
  });
}
