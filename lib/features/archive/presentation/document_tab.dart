/// 서류 상세 화면 위의 탭. 원본(07)과 AI 정리본(08) 중 하나를 보여 줍니다.
enum DocumentTab {
  original,
  summary;

  /// 경로의 `?tab=` 값으로 탭을 고릅니다. `summary`가 아니면 원본 탭입니다.
  static DocumentTab fromQuery(String? value) =>
      value == 'summary' ? summary : original;
}
