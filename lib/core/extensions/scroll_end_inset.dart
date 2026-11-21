import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:flutter/widgets.dart';

/// 스크롤 목록 맨 아래에 두는 여백을 한곳에서 정합니다.
extension ScrollEndInset on BuildContext {
  /// 목록의 마지막 항목이 바텀바·홈 인디케이터에 붙거나 가리지 않도록 끝에 둘 여백.
  ///
  /// [gap]에 지금 화면 아래쪽 안전 영역(`MediaQuery.paddingOf(context).bottom`)을
  /// 더합니다. 하단 탭 화면은 바깥 Scaffold가 바텀바 높이와 홈 인디케이터를 이미
  /// 빼고 그리므로 이 값이 0이라 [gap]만 남고, 바텀바 없이 열리거나 바텀바가 내용
  /// 위에 겹치게(`extendBody`) 바뀌면 그만큼 저절로 더해집니다.
  /// 떠 있는 버튼이 있는 화면은 [gap]에 [AppSpacing.floatingButtonClearance]를 넘깁니다.
  double scrollEndInset({double gap = AppSpacing.scrollEnd}) =>
      gap + MediaQuery.paddingOf(this).bottom;
}
