/// 캘린더에 보이는 서류 기한 하나. 예: "실손보험 청구 안내 · 11월 20일"
class Deadline {
  /// [tags]는 복사해서 바꿀 수 없는 목록으로 보관합니다.
  Deadline({
    required this.id,
    required this.title,
    required this.dueDate,
    required List<String> tags,
    this.isRegistered = false,
  }) : tags = List.unmodifiable(tags);

  /// 기한 id.
  final String id;

  /// 기한 이름. 예: "11월 관리비 고지서"
  final String title;

  /// 기한 날짜(0시).
  final DateTime dueDate;

  /// 서류가 담긴 보관함 분류. 예: ["집", "임대"]
  final List<String> tags;

  /// 기기 캘린더에 기한을 등록했으면 true.
  final bool isRegistered;

  /// [isRegistered]만 바꾼 새 기한을 돌려줍니다.
  Deadline copyWith({bool? isRegistered}) {
    return Deadline(
      id: id,
      title: title,
      dueDate: dueDate,
      tags: tags,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}
