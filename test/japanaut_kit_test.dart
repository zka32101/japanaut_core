import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:japanaut_kit/japanaut_kit.dart';

const _trip = AppBrand(
  suffix: 'Trip',
  slug: 'trip',
  packageName: 'com.yourwish.japanexplorer',
  tagline: 'AI Travel Guide',
  primaryColor: Color(0xFFE63946),
  supportEmail: 'support@example.com',
);

const _food = AppBrand(
  suffix: 'Food',
  slug: 'food',
  packageName: 'com.yourwish.japanautfood',
  tagline: 'Japanese Food Guide',
  primaryColor: Color(0xFFF4A261),
  supportEmail: 'support@example.com',
);

void main() {
  group('AppBrand', () {
    test('シリーズ名とアプリごとの名前を組み合わせる', () {
      expect(_trip.displayName, 'Japanaut Trip');
      expect(_food.displayName, 'Japanaut Food');
      expect(_trip.hashtag, '#JapanautTrip');
    });

    test('通知チャンネルはアプリごとに別のIDで、名前は表示名', () {
      expect(_trip.notificationChannelId, 'trip_default');
      expect(_food.notificationChannelId, 'food_default');
      expect(_trip.notificationChannelName, 'Japanaut Trip');
    });

    test('ストアのタイトルは30文字以内。収まらなければ表示名だけ', () {
      expect(_trip.storeTitle('AI Travel Guide'), 'Japanaut Trip: AI Travel Guide');
      expect(_trip.storeTitle('AI Travel Guide').length, lessThanOrEqualTo(30));
      expect(_trip.storeTitle('A very long descriptive subtitle'), 'Japanaut Trip');
    });
  });

  group('Language', () {
    test('13言語', () => expect(Language.values.length, 13));

    test('コードから引ける', () {
      expect(Language.tryFromCode('zh-TW'), Language.zhHant);
      expect(Language.tryFromCode('xx'), isNull);
    });

    test('端末のロケールから選ぶ（繁体字・未対応は英語）', () {
      expect(Language.fromLocale(const Locale('ja', 'JP')), Language.ja);
      expect(Language.fromLocale(const Locale('zh', 'TW')), Language.zhHant);
      expect(Language.fromLocale(const Locale('zh', 'HK')), Language.zhHant);
      expect(Language.fromLocale(const Locale('zh', 'CN')), Language.zh);
      expect(
        Language.fromLocale(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')),
        Language.zhHant,
      );
      expect(Language.fromLocale(const Locale('de')), Language.en);
    });

    test('右から左はアラビア語だけ', () {
      expect(Language.values.where((l) => l.isRtl), [Language.ar]);
    });

    test('コードは重複しない', () {
      final codes = Language.values.map((l) => l.code).toSet();
      expect(codes.length, Language.values.length);
    });
  });

  group('JapanautAssetLoader.deepMerge', () {
    test('アプリ側の訳文が共通訳文を上書きし、他は残る', () {
      final merged = JapanautAssetLoader.deepMerge(
        {
          'common': {'ok': 'OK', 'cancel': 'Cancel'},
          'auth': {'login': 'Log in'},
        },
        {
          'common': {'ok': 'Okay'},
          'home': {'title': 'Home'},
        },
      );
      expect(merged['common'], {'ok': 'Okay', 'cancel': 'Cancel'});
      expect(merged['auth'], {'login': 'Log in'});
      expect(merged['home'], {'title': 'Home'});
    });
  });

  group('LegalText', () {
    test('アプリ名と連絡先が差し込まれる', () {
      final privacy = LegalText.privacy(_food, collectedUsage: 'dishes you save');
      expect(privacy, contains('Japanaut Food collects information'));
      expect(privacy, contains('dishes you save'));
      expect(privacy, contains('support@example.com'));
      expect(privacy, isNot(contains('Japanaut Trip')));
    });

    test('利用規約にサービス説明が入る', () {
      final terms = LegalText.terms(_trip, serviceSummary: 'travel planning tools');
      expect(terms, contains('Japanaut Trip provides travel planning tools.'));
      expect(terms, contains('"as is."'));
    });
  });
}