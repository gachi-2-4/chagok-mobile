/// `**굵게**` 표시가 들어간 글을 굵은 부분과 보통 부분으로 나눕니다.
///
/// 예: "매월 **25일**까지" → [("매월 ", false), ("25일", true), ("까지", false)]
/// 짝이 맞지 않는 `**`는 글자 그대로 둡니다.
List<({String text, bool isBold})> splitEmphasis(String text) {
  final parts = <({String text, bool isBold})>[];
  final pattern = RegExp(r'\*\*(.+?)\*\*');
  var start = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > start) {
      parts.add((text: text.substring(start, match.start), isBold: false));
    }
    parts.add((text: match.group(1) ?? '', isBold: true));
    start = match.end;
  }
  if (start < text.length) {
    parts.add((text: text.substring(start), isBold: false));
  }
  return parts;
}
