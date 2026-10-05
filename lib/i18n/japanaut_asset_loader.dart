import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'language.dart';

/// 共通訳文（キット側）と、各アプリの訳文を重ねて読み込む easy_localization 用ローダー。
///
/// 同じキーがあれば、アプリ側の訳文が共通訳文を上書きする。
/// 使い方:
/// ```dart
/// EasyLocalization(
///   supportedLocales: [for (final l in Language.values) l.locale],
///   path: 'assets/translations',
///   assetLoader: const JapanautAssetLoader(),
///   fallbackLocale: Language.en.locale,
///   child: ...,
/// )
/// ```
class JapanautAssetLoader extends AssetLoader {
  const JapanautAssetLoader();

  /// キットが同梱する共通訳文のフォルダ。
  static const commonPath = 'packages/japanaut_kit/assets/translations';

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final file = _fileName(locale);
    final common = await _read('$commonPath/$file.json');
    final app = await _read('$path/$file.json');
    return deepMerge(common, app);
  }

  static String _fileName(Locale locale) {
    for (final l in Language.values) {
      if (l.locale == locale) return l.code;
    }
    return Language.fromLocale(locale).code;
  }

  static Future<Map<String, dynamic>> _read(String assetPath) async {
    try {
      final text = await rootBundle.loadString(assetPath);
      return json.decode(text) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{}; // 共通訳文がまだ無い言語は空として扱う
    }
  }

  /// [base] に [override] を深く重ねる（同じキーは [override] が勝つ）。
  static Map<String, dynamic> deepMerge(
    Map<String, dynamic> base,
    Map<String, dynamic> override,
  ) {
    final out = Map<String, dynamic>.from(base);
    override.forEach((key, value) {
      final current = out[key];
      if (current is Map<String, dynamic> && value is Map<String, dynamic>) {
        out[key] = deepMerge(current, value);
      } else {
        out[key] = value;
      }
    });
    return out;
  }
}
