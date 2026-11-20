import 'package:chagok_mobile/features/calendar/data/deadline.dart';

/// 목록에 보여 줄 기한과 오늘부터 남은 날.
class DeadlineItem {
  const DeadlineItem({required this.deadline, required this.daysLeft});

  /// 보여 줄 기한.
  final Deadline deadline;

  /// 오늘부터 기한까지 남은 날 수. 지났으면 음수입니다.
  final int daysLeft;
}
