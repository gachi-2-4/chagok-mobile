import 'dart:async';

import 'package:chagok_mobile/features/onboarding/data/onboarding_answers.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_repository.dart';

/// 저장한 답을 들고 있고, 저장 실패를 흉내 낼 수 있는 [OnboardingRepository].
class FakeOnboardingRepository implements OnboardingRepository {
  OnboardingAnswers? saved;

  /// 값을 넣으면 [save]가 이 예외를 던집니다.
  Exception? saveError;

  /// 값을 넣으면 [save]가 이것이 끝날 때까지 기다립니다.
  Completer<void>? saveGate;

  @override
  Future<OnboardingAnswers?> fetch() async => saved;

  @override
  Future<void> save(OnboardingAnswers answers) async {
    await saveGate?.future;
    if (saveError case final error?) throw error;
    saved = answers;
  }
}
