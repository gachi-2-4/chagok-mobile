import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 지금 시각을 돌려주는 함수. 테스트에서 시간을 직접 정하려고 Provider로 둡니다.
final authClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
