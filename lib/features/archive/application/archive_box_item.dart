import 'package:chagok_mobile/features/archive/data/archive_box.dart';

/// 보관함 목록에 보여 줄 보관함 하나와 가장 가까운 기한까지 남은 날.
class ArchiveBoxItem {
  const ArchiveBoxItem({required this.box, required this.daysLeft});

  final ArchiveBox box;

  /// 가장 가까운 기한까지 남은 날. 기한이 없거나 지났으면 null.
  final int? daysLeft;
}
