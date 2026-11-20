import 'package:chagok_mobile/features/notification/data/notification_kind.dart';

/// 알림 하나. 예: "내일은 월세 납부일이에요"
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.sentAt,
    this.isRead = false,
    this.isDone = false,
    this.message,
    this.boxName,
    this.dueDate,
    this.amount,
    this.documentName,
  });

  /// 알림 id.
  final String id;

  /// 알림 종류.
  final NotificationKind kind;

  /// 목록에 보이는 한 줄 제목.
  final String title;

  /// 보낸 시각. 0시가 아니면 목록에 시각까지 보여 줍니다.
  final DateTime sentAt;

  /// 읽었으면 true.
  final bool isRead;

  /// 납부 등 할 일을 마쳤다고 표시했으면 true. "완료" 탭에 모입니다.
  final bool isDone;

  /// 상세 화면 본문. 예: "안녕하세요, 김차곡님. …"
  final String? message;

  /// 알림과 관련된 보관함. 예: "집 · 임대"
  final String? boxName;

  /// 납부일·만기일(0시).
  final DateTime? dueDate;

  /// 낼 금액(원).
  final int? amount;

  /// 연결된 서류 이름. 예: "임대차계약서"
  final String? documentName;

  /// 읽음·완료 여부만 바꾼 새 알림을 돌려줍니다.
  AppNotification copyWith({bool? isRead, bool? isDone}) {
    return AppNotification(
      id: id,
      kind: kind,
      title: title,
      sentAt: sentAt,
      isRead: isRead ?? this.isRead,
      isDone: isDone ?? this.isDone,
      message: message,
      boxName: boxName,
      dueDate: dueDate,
      amount: amount,
      documentName: documentName,
    );
  }
}
