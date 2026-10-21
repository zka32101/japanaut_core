import 'package:flutter_test/flutter_test.dart';
import 'package:showglobe_core/showglobe_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('既定値を使い、切り替えを保存して次回読み戻す', () async {
    final n = NotificationPrefsNotifier({'streak': true, 'meetup': false});
    expect(n.isEnabled('streak'), isTrue);
    expect(n.isEnabled('meetup'), isFalse);
    expect(n.isEnabled('unknown'), isTrue);

    await n.toggle('streak');
    expect(n.isEnabled('streak'), isFalse);

    final reloaded = NotificationPrefsNotifier({'streak': true, 'meetup': false});
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(reloaded.isEnabled('streak'), isFalse);
    expect(reloaded.isEnabled('meetup'), isFalse);
  });
}
