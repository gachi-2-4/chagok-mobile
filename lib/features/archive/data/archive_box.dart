import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';

/// 서류를 모아 두는 보관함 하나.
class ArchiveBox {
  const ArchiveBox({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.documentCount,
    this.nextDueDate,
  });

  final String id;

  /// 예: "집 · 임대"
  final String name;
  final BoxColor color;
  final BoxIcon icon;

  /// 담긴 서류 수.
  final int documentCount;

  /// 담긴 서류 중 가장 가까운 납부·만기일. 없으면 null.
  final DateTime? nextDueDate;
}
