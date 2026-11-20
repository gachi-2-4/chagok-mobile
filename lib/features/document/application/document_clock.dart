import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 지금 시각을 돌려주는 함수. 테스트에서 시각을 바꿔 보려고 Provider로 둡니다.
final documentClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);
