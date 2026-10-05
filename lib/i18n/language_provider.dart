import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language.dart';

/// UI 言語の唯一の情報源。設定に保存し、起動時に読み戻す。
class LanguageNotifier extends StateNotifier<Language> {
  LanguageNotifier() : super(Language.fromDevice()) {
    _load();
  }

  static const _prefsKey = 'language';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = Language.tryFromCode(prefs.getString(_prefsKey));
      if (mounted) state = saved ?? Language.fromDevice();
    } catch (_) {
      // 設定が読めなければ端末の言語のまま使う。
    }
  }

  Future<void> setLanguage(Language language) async {
    state = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, language.code);
    } catch (_) {}
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Language>(
  (ref) => LanguageNotifier(),
);
