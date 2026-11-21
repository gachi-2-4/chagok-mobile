import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 이 기기를 가리키는 ID. 푸시 토큰 등록·로그아웃 API에 넘깁니다.
final deviceIdProvider = Provider<String>((ref) {
  // TODO: 푸시 알림을 붙일 때 설치할 때 한 번 만들어 기기에 저장하도록 바꿉니다.
  return generateDeviceId(Random.secure());
});

/// [random]으로 UUID v4 형식의 기기 ID를 만듭니다.
///
/// 예: `8d1c3e0a-6b2f-4c1e-9a77-1f0c2b3d4e5f`
String generateDeviceId(Random random) {
  final bytes = List.generate(16, (_) => random.nextInt(256));
  // RFC 4122: 7번째 바이트 앞 4비트는 버전(4), 9번째 바이트 앞 2비트는 변형(10).
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = [
    for (final byte in bytes) byte.toRadixString(16).padLeft(2, '0'),
  ];
  return [
    hex.sublist(0, 4).join(),
    hex.sublist(4, 6).join(),
    hex.sublist(6, 8).join(),
    hex.sublist(8, 10).join(),
    hex.sublist(10).join(),
  ].join('-');
}
