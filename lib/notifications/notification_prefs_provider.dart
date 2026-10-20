import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 通知の種類ごとの ON/OFF（例: streak / challenge / meetup）を保存する。
///
/// 種類はアプリが [NotificationPrefsNotifier.defaults] で決める。未保存の種類は
/// defaults の値（既定は ON）。
class NotificationPrefsNotifier extends StateNotifier<Map<String, bool>> {
  NotificationPrefsNotifier(Map<String, bool> defaults)
      : _defaults = Map.unmodifiable(defaults),
        super(Map.of(defaults)) {
    _load();
  }

  final Map<String, bool> _defaults;

  static String prefsKey(String kind) => 'settings_notif_$kind';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loaded = {
        for (final e in _defaults.entries)
          e.key: prefs.getBool(prefsKey(e.key)) ?? e.value,
      };
      if (mounted) state = loaded;
    } catch (_) {}
  }

  bool isEnabled(String kind) => state[kind] ?? true;

  Future<void> setEnabled(String kind, bool enabled) async {
    state = {...state, kind: enabled};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefsKey(kind), enabled);
    } catch (_) {}
  }

  Future<void> toggle(String kind) => setEnabled(kind, !isEnabled(kind));
}

/// アプリ側で `notificationPrefsProvider.overrideWith(...)` するか、
/// 既定（空）のまま `setEnabled` で種類を足して使う。
final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsNotifier, Map<String, bool>>(
  (ref) => NotificationPrefsNotifier(const {}),
);
