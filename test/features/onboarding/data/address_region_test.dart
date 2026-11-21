import 'package:chagok_mobile/features/onboarding/data/address_region.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('regionOf', () {
    test('도로명주소를 넘기면 시·도와 시·군·구를 뽑는다', () {
      expect(regionOf('서울특별시 마포구 월드컵북로 396'), (sido: '서울특별시', sigungu: '마포구'));
    });

    test('시 아래에 구가 있으면 시와 구를 이어 시·군·구로 본다', () {
      expect(regionOf('경기도 성남시 분당구 판교역로 166'), (
        sido: '경기도',
        sigungu: '성남시 분당구',
      ));
    });

    test('시·군·구가 없는 세종시면 시·군·구를 비운다', () {
      expect(regionOf('세종특별자치시 한누리대로 2130'), (sido: '세종특별자치시', sigungu: ''));
    });

    test('빈 주소를 넘기면 둘 다 비운다', () {
      expect(regionOf('  '), (sido: '', sigungu: ''));
    });
  });
}
