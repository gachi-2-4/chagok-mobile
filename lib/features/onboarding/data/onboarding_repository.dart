import 'package:chagok_mobile/features/onboarding/data/onboarding_answers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 첫 설문 답을 저장하고 불러오는 창구.
abstract interface class OnboardingRepository {
  /// 저장한 답. 아직 설문을 마치지 않았으면 null.
  Future<OnboardingAnswers?> fetch();

  Future<void> save(OnboardingAnswers answers);
}

/// 백엔드가 정해지기 전까지 쓰는 메모리 저장소. 앱을 끄면 사라집니다.
class InMemoryOnboardingRepository implements OnboardingRepository {
  Map<String, Object?>? _saved;

  @override
  Future<OnboardingAnswers?> fetch() async {
    final saved = _saved;
    return saved == null ? null : OnboardingAnswers.fromJson(saved);
  }

  @override
  Future<void> save(OnboardingAnswers answers) async {
    _saved = answers.toJson();
  }
}

/// 앱 전역 [OnboardingRepository].
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  // TODO: 백엔드가 정해지면 실제 구현으로 바꿉니다.
  return InMemoryOnboardingRepository();
});
