/// 도로명·지번 주소에서 서버에 보낼 시·도와 시·군·구를 뽑습니다.
///
/// 온보딩 설문 저장 API는 상세 주소 없이 `region.sido`·`region.sigungu`만 받습니다.
/// - `서울특별시 마포구 월드컵북로 396` → (서울특별시, 마포구)
/// - `경기도 성남시 분당구 판교역로 166` → (경기도, 성남시 분당구)
/// - `세종특별자치시 한누리대로 2130` → (세종특별자치시, '')
///
/// 시 아래에 구가 있는 곳(행정시 + 자치구가 아닌 구)은 둘을 이어 시·군·구로 봅니다.
({String sido, String sigungu}) regionOf(String address) {
  final words = address.trim().split(RegExp(r'\s+'));
  if (words.first.isEmpty) return (sido: '', sigungu: '');
  final sido = words.first;
  final rest = words.skip(1).toList();
  if (rest.isEmpty || !_isSigungu(rest.first)) return (sido: sido, sigungu: '');
  final hasDistrict =
      rest.first.endsWith('시') && rest.length > 1 && rest[1].endsWith('구');
  return (
    sido: sido,
    sigungu: hasDistrict ? '${rest[0]} ${rest[1]}' : rest.first,
  );
}

/// 주소의 한 낱말이 시·군·구 이름이면 true. 도로명(…로, …길)이나 번지는 아닙니다.
bool _isSigungu(String word) =>
    word.endsWith('시') || word.endsWith('군') || word.endsWith('구');
