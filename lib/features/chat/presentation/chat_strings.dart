/// 채팅 화면에 보이는 문구.
///
/// 다국어를 도입할 때 옮기기 쉽도록 한곳에 모읍니다.
abstract final class ChatStrings {
  static const loadFailed = '대화를 불러오지 못했어요.';
  static const listLoadFailed = '대화 목록을 불러오지 못했어요.';
  static const documentsLoadFailed = '보관함 서류를 불러오지 못했어요.';
  static const retry = '다시 시도';

  // H01 대화
  static const roomTitle = '서류에 대해 물어보세요';
  static String linkedDocument(String name) => '연결된 서류 · $name';
  static const noLinkedDocument = '연결된 서류가 없어요';
  static const change = '변경 ›';

  /// 대화 화면 위 서류 띠. 예: "연결된 서류 · 임대차계약서　변경 ›"
  static String documentBanner(String? documentName) {
    final label = documentName == null
        ? noLinkedDocument
        : linkedDocument(documentName);
    return '$label　$change';
  }

  /// 입력줄 왼쪽 서류 추가 버튼의 이름. 아이콘 버튼이라 화면 읽기 프로그램이 읽습니다.
  static const addDocument = '서류 추가';
  static const inputHint = '서류에 대해 질문하기';
  static const send = '보내기';
  static String source(String value) => '근거: $value';
  static const viewOriginal = '원본 확인　›';
  static const typing = '답을 찾고 있어요…';
  static const sendFailed = '답을 받지 못했어요. 잠시 후 다시 보내 주세요.';
  static const resend = '다시 보내기';
  static const sendNeedsDocument = '물어볼 서류가 없어요. 대화에 서류를 먼저 추가해 주세요.';

  // H02 서류 추가
  static const attachTitle = '대화에 서류 추가';
  static const attachDescription = '궁금한 서류를 함께 올리면\n내용을 바탕으로 답해 드릴게요.';
  static const pickFromBox = '내 보관함에서 선택　›';
  static const pickFromBoxDescription = '이미 차곡에 보관한 서류';
  static const noDocumentsInBox = '아직 보관한 서류가 없어요.\n보관함에 서류를 먼저 올려 주세요.';
  static String selected(String fileName) => '선택됨 · $fileName\n분석 후 대화에 연결돼요.';
  static const externalFileHelp =
      '외부 파일을 올리고 싶다면?\n보관함 → 박스에 파일을 업로드해 사용할 수 있어요.';
  static const attach = '이 서류로 대화하기';
  static const attachFailed = '서류를 연결하지 못했어요. 다시 시도해 주세요.';
  static const cancel = '취소';

  // H03 대화 목록
  static const listTitle = '채팅 목록';
  static const searchHint = '대화 내용 검색';
  static const today = '오늘';
  static const earlier = '이전 대화';
  static const empty = '아직 나눈 대화가 없어요.';
  static const noResult = '검색 결과가 없어요.';
  static const newChat = '새 대화 시작';
  static const newChatFailed = '새 대화를 시작하지 못했어요. 다시 시도해 주세요.';

  /// [time]이 [now]와 같은 날이면 시각, 아니면 날짜.
  ///
  /// 오늘이면 시각, 아니면 날짜. 예: "오전 9:41", "11월 14일"
  static String updatedAt(DateTime time, DateTime now) {
    final isToday =
        time.year == now.year && time.month == now.month && time.day == now.day;
    if (!isToday) return '${time.month}월 ${time.day}일';
    final period = time.hour < 12 ? '오전' : '오후';
    final hour = switch (time.hour % 12) {
      0 => 12,
      final value => value,
    };
    final minute = time.minute.toString().padLeft(2, '0');
    return '$period $hour:$minute';
  }
}
