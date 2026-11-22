import 'package:chagok_mobile/features/onboarding/data/address_region.dart';
import 'package:chagok_mobile/features/onboarding/data/sample_address_regions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('searchAddressRegions', () {
    test('시·군·구 이름 일부를 넣으면 그 주소를 찾는다', () {
      final results = searchAddressRegions('마포');

      expect(results, ['서울특별시 마포구']);
    });

    test('시·도를 줄여 쓰면 끝의 시·도를 떼고 맞춰 본다', () {
      final results = searchAddressRegions('서울시 마포구');

      expect(results, ['서울특별시 마포구']);
    });

    test('낱말을 띄어 쓰면 모두 들어 있는 주소만 찾는다', () {
      final results = searchAddressRegions('부산 중구');

      expect(results, ['부산광역시 중구']);
    });

    test('맞는 주소가 많으면 limit개까지만 돌려준다', () {
      final results = searchAddressRegions('서울', limit: 3);

      expect(results, hasLength(3));
    });

    test('검색어가 비어 있으면 빈 목록을 돌려준다', () {
      final results = searchAddressRegions('  ');

      expect(results, isEmpty);
    });

    test('맞는 주소가 없으면 빈 목록을 돌려준다', () {
      final results = searchAddressRegions('없는동네');

      expect(results, isEmpty);
    });
  });

  group('sampleAddressRegions', () {
    test('주소를 나누면 모두 시·도가 있다', () {
      final regions = sampleAddressRegions.map(regionOf);

      expect(regions.every((region) => region.sido.isNotEmpty), isTrue);
    });

    test('목록을 집합으로 바꾸면 개수가 그대로다', () {
      final unique = sampleAddressRegions.toSet();

      expect(unique, hasLength(sampleAddressRegions.length));
    });
  });
}
