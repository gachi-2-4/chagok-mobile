import 'package:chagok_mobile/features/settings/presentation/settings_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsStrings.reminderTimeLabel', () {
    test('정각이면 분을 빼고 보여 준다', () {
      expect(SettingsStrings.reminderTimeLabel(9 * 60), '오전 9시');
    });

    test('오후 시각이면 12시간제로 바꿔 보여 준다', () {
      expect(SettingsStrings.reminderTimeLabel(14 * 60 + 30), '오후 2시 30분');
    });

    test('자정이나 정오면 12시로 보여 준다', () {
      expect(SettingsStrings.reminderTimeLabel(0), '오전 12시');
      expect(SettingsStrings.reminderTimeLabel(12 * 60), '오후 12시');
    });
  });
}
