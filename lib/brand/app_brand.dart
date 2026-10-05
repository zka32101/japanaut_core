import 'dart:ui' show Color;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Japanaut シリーズ全体の名前（全アプリ共通）。
const String kSeriesName = 'Japanaut';

/// シリーズ内の 1 アプリの「名前・色・識別子」を 1 か所で決める設定。
///
/// 例: `AppBrand(suffix: 'Trip', ...)` なら表示名は「Japanaut Trip」。
/// アプリ名の変更や新アプリ（Food など）の追加は、この設定だけで済むようにする。
class AppBrand {
  const AppBrand({
    required this.suffix,
    required this.slug,
    required this.packageName,
    required this.tagline,
    required this.primaryColor,
    required this.supportEmail,
    this.accentColor,
  });

  /// アプリごとの名前の後半（Trip / Food …）。
  final String suffix;

  /// 英小文字の識別子（trip / food …）。チャンネル ID・保存キーなどに使う。
  final String slug;

  /// Android のパッケージ名／iOS の Bundle ID（既存アプリは変更しない）。
  final String packageName;

  /// ひとこと説明（英語。ストア・共有文の元）。
  final String tagline;

  final Color primaryColor;
  final Color? accentColor;

  /// 利用規約・プライバシーポリシーに載せる連絡先。
  final String supportEmail;

  /// 表示名。例: 「Japanaut Trip」。
  String get displayName => '$kSeriesName $suffix';

  /// 通知チャンネル ID。
  String get notificationChannelId => '${slug}_default';

  /// 通知チャンネル名（端末の設定画面に出る）。
  String get notificationChannelName => displayName;

  /// SNS 共有で使うハッシュタグ。
  String get hashtag => '#$kSeriesName$suffix';

  /// Google Play のタイトル上限（30 文字）に収まる「名前: 説明」を作る。
  /// 収まらなければ、説明を省いた表示名だけを返す。
  String storeTitle(String descriptor) {
    final full = '$displayName: $descriptor';
    return full.length <= 30 ? full : displayName;
  }
}

/// アプリ起動時に `ProviderScope(overrides: [appBrandProvider.overrideWithValue(...)])`
/// で、そのアプリの [AppBrand] を渡す。
final appBrandProvider = Provider<AppBrand>(
  (ref) => throw UnimplementedError(
    'appBrandProvider を ProviderScope の overrides で上書きしてください',
  ),
);
