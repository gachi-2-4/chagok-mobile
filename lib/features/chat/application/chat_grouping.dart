import 'package:chagok_mobile/features/chat/data/chat_thread.dart';

/// 대화를 오늘 한 것과 그 전에 한 것으로 나눕니다. 순서는 그대로 둡니다.
({List<ChatThread> today, List<ChatThread> earlier}) groupByToday(
  List<ChatThread> threads,
  DateTime now,
) {
  bool isToday(DateTime time) =>
      time.year == now.year && time.month == now.month && time.day == now.day;

  return (
    today: threads.where((thread) => isToday(thread.updatedAt)).toList(),
    earlier: threads.where((thread) => !isToday(thread.updatedAt)).toList(),
  );
}
