import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';

/// 새 박스 만들기 시트(05)의 입력값.
class NewBoxForm {
  const NewBoxForm({
    this.name = '',
    this.color = BoxColor.peach,
    this.icon = BoxIcon.package,
    this.isSaving = false,
    this.hasSaveFailed = false,
  });

  /// 박스 이름 입력값. 앞뒤 공백은 저장할 때 뺍니다.
  final String name;
  final BoxColor color;
  final BoxIcon icon;

  /// 만드는 중이면 true.
  final bool isSaving;

  /// 마지막으로 만들려다 실패했으면 true.
  final bool hasSaveFailed;

  /// 이름을 적었고 만드는 중이 아니면 true.
  bool get canSubmit => name.trim().isNotEmpty && !isSaving;

  /// 넘긴 값만 바꾼 입력값을 돌려줍니다.
  NewBoxForm copyWith({
    String? name,
    BoxColor? color,
    BoxIcon? icon,
    bool? isSaving,
    bool? hasSaveFailed,
  }) {
    return NewBoxForm(
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isSaving: isSaving ?? this.isSaving,
      hasSaveFailed: hasSaveFailed ?? this.hasSaveFailed,
    );
  }
}
