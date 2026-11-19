import 'package:chagok_mobile/features/settings/data/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile.fromJson', () {
    test('이름과 전화번호가 있으면 그대로 읽는다', () {
      final profile = UserProfile.fromJson(const {
        'name': '김차곡',
        'phoneNumber': '01011112222',
      });

      expect(profile.name, '김차곡');
      expect(profile.phoneNumber, '01011112222');
    });

    test('값이 없으면 빈 글로 둔다', () {
      final profile = UserProfile.fromJson(const {});

      expect(profile.name, isEmpty);
      expect(profile.phoneNumber, isEmpty);
    });
  });
}
