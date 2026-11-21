import 'dart:math';

import 'package:chagok_mobile/core/network/device_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('generateDeviceId', () {
    test('기기 ID를 만들면 UUID v4 형식이다', () {
      final id = generateDeviceId(Random(1));

      expect(
        id,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    });
  });
}
