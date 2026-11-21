import 'dart:async';

import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/core_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 동그란 바탕 위의 뒤로 가기(‹) 버튼.
///
/// 상단 바 없이 내용이 바로 시작하는 화면의 왼쪽 위에 둡니다.
/// 예: 보관함 상세, 서류 상세
class AppCircleBackButton extends StatelessWidget {
  const AppCircleBackButton({this.onTap, super.key});

  /// 버튼 지름.
  static const size = 40.0;

  /// 눌렀을 때 동작. 비우면 `Navigator.maybePop`을 호출합니다.
  final VoidCallback? onTap;

  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: CoreStrings.back,
      child: Material(
        color: AppColors.softFill,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap ?? () => unawaited(Navigator.maybePop(context)),
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: SvgPicture.asset(
                AppIcons.back,
                width: _iconSize,
                height: _iconSize,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
