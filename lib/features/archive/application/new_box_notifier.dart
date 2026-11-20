import 'package:chagok_mobile/features/archive/application/box_list_notifier.dart';
import 'package:chagok_mobile/features/archive/application/new_box_form.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 새 박스 만들기 입력값. 시트를 닫으면 버립니다.
final newBoxProvider = NotifierProvider.autoDispose<NewBoxNotifier, NewBoxForm>(
  NewBoxNotifier.new,
);

/// 새 박스의 이름·색·아이콘을 받아 보관함을 만듭니다.
class NewBoxNotifier extends Notifier<NewBoxForm> {
  @override
  NewBoxForm build() => const NewBoxForm();

  /// 박스 이름 입력값을 바꿉니다.
  void updateName(String value) => state = state.copyWith(name: value);

  /// 상자 색을 고릅니다.
  void selectColor(BoxColor value) => state = state.copyWith(color: value);

  /// 종류 아이콘을 고릅니다.
  void selectIcon(BoxIcon value) => state = state.copyWith(icon: value);

  /// 보관함을 만들고 목록을 다시 불러옵니다. 만들었으면 true.
  ///
  /// 만들지 못하면 입력값은 그대로 두고 [NewBoxForm.hasSaveFailed]를 켭니다.
  Future<bool> submit() async {
    final form = state;
    if (!form.canSubmit) return false;
    state = form.copyWith(isSaving: true, hasSaveFailed: false);
    try {
      await ref
          .read(archiveRepositoryProvider)
          .createBox(
            name: form.name.trim(),
            color: form.color,
            icon: form.icon,
          );
    } catch (error, stackTrace) {
      debugPrint('보관함을 만들지 못했습니다: $error\n$stackTrace');
      if (ref.mounted) {
        state = state.copyWith(isSaving: false, hasSaveFailed: true);
      }
      return false;
    }
    // 만드는 사이 시트를 닫아 이 Notifier가 버려졌으면 ref를 쓸 수 없습니다.
    // 시트는 결과를 기다리는 동안 열려 있으므로 보통은 여기까지 옵니다.
    if (!ref.mounted) return true;
    ref.invalidate(boxListProvider);
    state = state.copyWith(isSaving: false);
    return true;
  }
}
