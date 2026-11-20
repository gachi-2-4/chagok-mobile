import 'package:chagok_mobile/features/home/data/box_category.dart';

/// 최근에 연 보관함 하나.
class RecentBox {
  const RecentBox({
    required this.id,
    required this.name,
    required this.category,
    required this.documentCount,
    required this.lastOpenedAt,
    this.nextDueDate,
  });

  final String id;

  /// 예: "집 · 임대"
  final String name;
  final BoxCategory category;
  final int documentCount;
  final DateTime lastOpenedAt;

  /// 이 보관함에서 가장 가까운 납부·만기일. 없으면 null.
  final DateTime? nextDueDate;
}
