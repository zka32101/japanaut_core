import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:japanaut_kit/japanaut_kit.dart';

Set<String> _flatKeys(Map<String, dynamic> m, [String prefix = '']) => {
      for (final e in m.entries)
        if (e.value is Map<String, dynamic>)
          ..._flatKeys(e.value as Map<String, dynamic>, '$prefix${e.key}.')
        else
          '$prefix${e.key}',
    };

Map<String, dynamic> _load(String code) => jsonDecode(
        File('assets/translations/$code.json').readAsStringSync())
    as Map<String, dynamic>;

void main() {
  test('共通訳文は13言語すべてにあり、キーが英語と一致する', () {
    final en = _flatKeys(_load('en'));
    expect(en, isNotEmpty);
    for (final l in Language.values) {
      expect(_flatKeys(_load(l.code)), en, reason: l.code);
    }
  });
}
