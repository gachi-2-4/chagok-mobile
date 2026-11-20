/// 최근 알림 하나.
class RecentAlert {
  const RecentAlert({
    required this.id,
    required this.title,
    required this.boxName,
    required this.createdAt,
    required this.isRead,
  });

  final String id;

  /// 예: "임대차계약서 만기가 30일 남았어요"
  final String title;

  /// 알림이 생긴 보관함 이름. 예: "집 · 임대"
  final String boxName;
  final DateTime createdAt;
  final bool isRead;
}
