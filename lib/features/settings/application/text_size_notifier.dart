import 'package:chagok_mobile/features/settings/application/settings_notifier.dart';
import 'package:chagok_mobile/features/settings/data/text_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 글자 크기 화면(S02)에서 저장 전에 골라 보는 크기.
///
/// 저장하기 전까지는 미리 보기에만 반영하고 앱 전체에는 반영하지 않습니다.
final textSizeDraftProvider =
    NotifierProvider.autoDispose<TextSizeDraftNotifier, TextSize>(
      TextSizeDraftNotifier.new,
    );

/// 글자 크기를 골라 보고, 저장할 때 앱 설정에 반영합니다.
class TextSizeDraftNotifier extends Notifier<TextSize> {
  @override
  TextSize build() {
    // 설정을 늦게 불러오거나 저장해서 바뀌면 그 크기에서 다시 고르기 시작합니다.
    final settings = ref.watch(settingsProvider).value;
    return settings?.textSize ?? TextSize.normal;
  }

  /// 미리 볼 크기를 [value]로 바꿉니다. 앱 설정은 바꾸지 않습니다.
  void select(TextSize value) => state = value;

  /// 고른 크기를 앱 설정에 저장합니다. 저장했으면 true, 실패하면 false.
  ///
  /// 설정을 아직 불러오는 중이면 다 불러온 뒤 저장합니다. 불러오면 초안이 저장된
  /// 크기로 다시 시작하므로, 기다리기 전에 고른 크기를 붙잡아 둡니다.
  Future<bool> save() async {
    final chosen = state;
    try {
      await ref.read(settingsProvider.future);
    } catch (error) {
      return false;
    }
    if (!ref.mounted) return false;
    return ref.read(settingsProvider.notifier).setTextSize(chosen);
  }
}
