import 'package:flutter/painting.dart';

/// 차곡 디자인 시스템의 색상 토큰.
///
/// Figma `01 시작·계정·설정`, `02 서류·비교·채팅·알림` 화면에서
/// 공통으로 쓰이는 값을 모았습니다. 위젯에서는 이 값을 직접 쓰거나
/// `Theme.of(context).colorScheme`을 통해 가져옵니다.
abstract final class AppColors {
  // 브랜드
  static const primary = Color(0xFFC57638);
  static const onPrimary = Color(0xFFFFF9EF);
  static const brand = Color(0xFF985529);

  /// 로고 '차곡' 글자색.
  static const logo = Color(0xFF8C491A);
  static const navActive = Color(0xFFB2662C);

  // 배경·표면
  static const background = Color(0xFFF5EAD8);
  static const surface = Color(0xFFFFF8EE);
  static const surfaceBorder = Color(0xFFE4D8C4);
  static const dialogSurface = Color(0xFFFFFAF2);
  static const navBackground = Color(0xFFFAF3E7);
  static const navBorder = Color(0xFFE1D3BC);
  static const sectionBand = Color(0xFFECDFCA);
  static const divider = Color(0xFFDFD3BE);

  // 텍스트
  static const textPrimary = Color(0xFF383329);
  static const textSecondary = Color(0xFF7B7060);
  static const textTertiary = Color(0xFF827661);
  static const textFooter = Color(0xFF84745F);

  // 입력창
  static const fieldFill = Color(0xFFFAF5ED);
  static const fieldBorder = Color(0xFFD9CDBB);

  // 보조 버튼
  static const secondaryButtonBorder = Color(0xFFD9CBB5);
  static const secondaryButtonText = Color(0xFF64533F);

  // 칩
  static const chipFill = Color(0xFFFAF5EB);
  static const chipBorder = Color(0xFFD6C8B2);
  static const chipSelectedFill = Color(0xFFCEDBB3);
  static const chipSelectedBorder = Color(0xFF92A66E);
  static const chipSelectedText = Color(0xFF486032);

  // 강조 톤 (카드·배너)
  static const green = Color(0xFFDCE5C6);
  static const greenBorder = Color(0xFFB4C394);
  static const peach = Color(0xFFFFDAB9);
  static const peachBorder = Color(0xFFE5B48D);
  static const neutralBanner = Color(0xFFD9CDBB);

  // 토글
  static const toggleOn = Color(0xFF8DA36C);
  static const toggleOff = Color(0xFFCFC5B6);
  static const toggleKnob = Color(0xFFFFFAF1);

  // 보관함 그림 (뚜껑 · 상자 · 아이콘 · 날짜 표)
  static const boxLid = Color(0xFFD67F48);
  static const boxBody = Color(0xFFFFC6A5);
  static const boxIcon = Color(0xFF643312);
  static const boxTag = Color(0xFFF9F4ED);

  // 보관함 색. 피치색 상자는 [boxLid]·[boxBody]를 씁니다.
  static const boxLidGreen = Color(0xFF929F78);
  static const boxBodyGreen = Color(0xFFCFDBB6);
  static const boxLidGray = Color(0xFF9F9788);
  static const boxBodyGray = Color(0xFFDAD3C6);

  /// 보관함 화면의 동그란 뒤로 가기 버튼, 아이콘 칸, 서류 원본 자리의 바탕.
  static const softFill = Color(0xFFF8F4EE);

  /// 서류 원본 자리에 긋는 빗금.
  static const documentStripe = Color(0xFFEDE7DC);

  // 기타
  static const chevron = Color(0xFF998D79);
  static const bullet = Color(0xFF827661);
  static const danger = Color(0xFFA35036);
  static const dangerButton = Color(0xFF9C4E39);
  static const dialogCancel = Color(0xFFECDFCA);
  static const scrim = Color(0x801F1A14);

  // 간편 로그인: 각 회사 로그인 버튼 가이드의 색을 그대로 씁니다.
  /// 카카오 로그인 버튼 배경.
  static const kakao = Color(0xFFFEE500);

  /// 간편 로그인 버튼 글자.
  static const socialLoginText = Color(0xFF302B19);

  /// 보이지 않게 그릴 때 쓰는 투명 색. 예: 칸 뒤에 겹쳐 둔 입력창 글자
  static const transparent = Color(0x00000000);

  /// 요일 이름처럼 흐리게 보이는 글자.
  static const textDisabled = Color(0xFFAAA091);

  /// 알림 목록에서 고르지 않은 탭 바탕. 본문 글자색을 아주 옅게 깐 색입니다.
  static const tabInactiveFill = Color(0x0F383329);

  /// 알림 목록·상세의 구분선.
  static const noticeDivider = Color(0x1F383329);

  /// 알림 상세 본문 바탕.
  static const noticeBody = Color(0xFFFAF5ED);

  /// 캘린더 달력 카드 바탕.
  static const calendarSurface = Color(0xFFF9F4ED);

  /// 캘린더의 이전·다음 달 버튼과 여유 있는 D-n 표 바탕.
  static const calendarControl = Color(0xFFEEE7DB);

  /// 기기 캘린더에 아직 등록하지 않은 기한을 가리키는 점.
  static const calendarDotMuted = Color(0xFFC0B6A5);
}
