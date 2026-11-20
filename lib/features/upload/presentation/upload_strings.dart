/// 서류 올리기 화면에 보이는 문구.
///
/// 다국어를 도입할 때 옮기기 쉽도록 한곳에 모읍니다.
abstract final class UploadStrings {
  static const comingSoon = '곧 지원할 예정이에요.';
  static const failed = '처리하지 못했어요. 잠시 후 다시 시도해 주세요.';

  /// 방법 카드의 설명과 화살표. 예: "종이 서류를 카메라로 찍어요　›"
  static String optionDescription(String description) => '$description　›';

  // U01 방법 고르기
  static const sourceTitle = '어떤 서류를 담을까요?';
  static const sourceDescription = '사진도 PDF도 차곡에 담아 보세요.';
  static const cameraTitle = '사진 촬영';
  static const cameraDescription = '종이 서류를 카메라로 찍어요';
  static const albumTitle = '앨범에서 선택';
  static const albumDescription = '이미 찍어 둔 서류를 불러와요';
  static const pdfTitle = 'PDF 파일 선택';
  static const pdfDescription = '기기에 저장된 파일을 불러와요';
  static const sourceNote = '글자가 선명하게 보이는 서류를 올려 주세요.';
  static const pickPdf = 'PDF 파일 고르기';

  // U02 파일 확인
  static const confirmTitle = '이 파일을 분석할까요?';
  static const pdfLabel = 'PDF';
  static const imageLabel = '사진';

  /// 서류 전체 페이지 수. 예: 3 → "3페이지"
  static String pageCount(int count) => '$count페이지';

  /// 파일을 담을 보관함 이름. 예: "집 · 임대" → "집 · 임대 보관함"
  static String boxSuffix(String boxName) => '$boxName 보관함';

  /// 미리 보기 아래 쪽수. [current]는 보고 있는 쪽, [total]은 전체 쪽수입니다.
  /// 예: (1, 3) → "서류 미리보기 · 1 / 3"
  static String previewPage(int current, int total) =>
      '서류 미리보기 · $current / $total';
  static const boxLabel = '보관할 곳';
  static const pdfPasswordNote = '암호가 걸린 PDF는 암호를 해제한 후 다시 올려 주세요.';
  static const startAnalysis = '분석 시작';
  static const analyzing = '분석하고 있어요…';
  static const pickOtherFile = '다른 파일 선택';

  // U03 다시 찍기
  static const retakeTitle = '조금 더 선명하게 찍어 주세요';
  static const blurryTitle = '일부 글자가 흐릿해요';
  static const blurryDescription = '금액과 날짜를 정확히 읽기 어려워요.';
  static const frameGuide = '서류의 네 모서리를\n화면 안에 맞춰 주세요';
  static const retakeTips = [
    '① 밝은 곳에서 그림자를 피해주세요.',
    '② 서류를 평평하게 펴 주세요.',
    '③ 카메라를 고정한 뒤 촬영해 주세요.',
  ];
  static const retake = '다시 촬영하기';
  static const pickOtherImage = '다른 이미지 선택';

  // U04 결과 확인
  static const reviewTitle = '읽어 낸 내용을 확인해요';
  static const reviewDescription =
      '서류에서 찾은 조건을 같은 이름으로 정리했어요. 다른 내용이 있으면 수정해 주세요.';
  static const needsCheck = '확인 필요';

  /// 값을 확실히 읽지 못한 조건 안내. [label]은 조건 이름입니다.
  /// 예: "중도 해지 위약금" → "중도 해지 위약금을 확실히 읽지 못했어요."
  static String uncertainNotice(String label) => '$label을 확실히 읽지 못했어요.';
  static const uncertainHelp = '원본을 확인한 뒤 직접 입력할 수 있어요.';

  /// 이름을 바꿔 정리한 조건 안내. [original]은 원본 서류에 쓰인 이름,
  /// [label]은 차곡이 정리한 이름입니다. 예: ("월세", "월 임대료")
  static String renamedNote(String original, String label) =>
      '원본의 ‘$original’를 ‘$label’로 정리했어요.';
  static const saveDocument = '확인하고 보관';
  static const editDocument = '내용 수정하기';
  static const saved = '서류를 보관함에 담았어요.';
}
