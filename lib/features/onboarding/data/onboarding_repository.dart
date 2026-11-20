import 'package:chagok_mobile/features/onboarding/data/in_memory_onboarding_repository.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_answers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 첫 설문 답을 저장하고 불러오는 창구.
abstract interface class OnboardingRepository {
  /// 저장한 답. 아직 설문을 마치지 않았으면 null.
  Future<OnboardingAnswers?> fetch();

  /// [answers]를 저장합니다. 앞서 저장한 답은 덮어씁니다.
  Future<void> save(OnboardingAnswers answers);
}

/// 앱 전역 [OnboardingRepository].
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  // TODO: 백엔드가 정해지면 실제 구현으로 바꿉니다.
  return InMemoryOnboardingRepository();
});
