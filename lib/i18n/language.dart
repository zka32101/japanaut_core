import 'dart:ui';

/// シリーズ共通の UI 言語（13 言語）。
///
/// 言語を足すときは、ここに追加し、`assets/translations/<ファイル名>.json`
/// （キット側の共通訳文と、各アプリ側の訳文）を用意する。
enum Language {
  ja('ja', '日本語', '🇯🇵', Locale('ja'), 'ja-JP', 'Japanese'),
  en('en', 'English', '🇬🇧', Locale('en'), 'en-US', 'English'),
  zh('zh', '中文', '🇨🇳', Locale('zh'), 'zh-CN', 'Simplified Chinese'),
  zhHant('zh-TW', '繁體中文', '🇹🇼', Locale('zh', 'TW'), 'zh-TW', 'Traditional Chinese'),
  ko('ko', '한국어', '🇰🇷', Locale('ko'), 'ko-KR', 'Korean'),
  fr('fr', 'Français', '🇫🇷', Locale('fr'), 'fr-FR', 'French'),
  th('th', 'ไทย', '🇹🇭', Locale('th'), 'th-TH', 'Thai'),
  es('es', 'Español', '🇪🇸', Locale('es'), 'es-ES', 'Spanish'),
  id('id', 'Bahasa Indonesia', '🇮🇩', Locale('id'), 'id-ID', 'Indonesian'),
  vi('vi', 'Tiếng Việt', '🇻🇳', Locale('vi'), 'vi-VN', 'Vietnamese'),
  pt('pt', 'Português', '🇧🇷', Locale('pt'), 'pt-BR', 'Portuguese'),
  hi('hi', 'हिन्दी', '🇮🇳', Locale('hi'), 'hi-IN', 'Hindi'),
  ar('ar', 'العربية', '🇸🇦', Locale('ar'), 'ar-SA', 'Arabic');

  const Language(
    this.code,
    this.displayName,
    this.flag,
    this.locale,
    this.ttsLocale,
    this.aiName,
  );

  /// 設定に保存し、言語ごとのマップのキーにも使う。
  final String code;

  /// その言語自身での名前（言語選択に表示）。
  final String displayName;
  final String flag;

  /// easy_localization / MaterialApp に渡すロケール。
  final Locale locale;

  /// 音声読み上げ用の BCP-47 タグ。
  final String ttsLocale;

  /// AI への指示で使う言語名（「Write in Thai.」など）。
  final String aiName;

  /// 右から左に書く言語か（レイアウトの向きの判断に使う）。
  bool get isRtl => this == Language.ar;

  static Language? tryFromCode(String? code) {
    for (final l in values) {
      if (l.code == code) return l;
    }
    return null;
  }

  /// 端末のロケールに合う対応言語。なければ英語。
  static Language fromLocale(Locale device) {
    if (device.languageCode == 'zh') {
      // 繁体字: 台湾・香港・マカオ、または Hant が明示されている場合。
      final traditional = device.scriptCode == 'Hant' ||
          const {'TW', 'HK', 'MO'}.contains(device.countryCode);
      return traditional ? Language.zhHant : Language.zh;
    }
    return tryFromCode(device.languageCode) ?? Language.en;
  }

  static Language fromDevice() => fromLocale(PlatformDispatcher.instance.locale);
}
