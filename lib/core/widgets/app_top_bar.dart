import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

export 'package:chagok_mobile/core/widgets/app_top_bar_action.dart';

/// 뒤로 가기 · 가운데 제목 · 오른쪽 버튼으로 이루어진 화면 상단 바.
///
/// Figma `div.bar` 컴포넌트에 해당합니다.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    required this.title,
    this.showBackButton = true,
    this.onBack,
    this.onMore,
    this.action,
    super.key,
  }) : assert(
         onMore == null || action == null,
         '오른쪽 자리는 하나라 onMore와 action을 함께 쓸 수 없습니다.',
       ),
       _variant = _AppTopBarVariant.brand;

  /// 가운데에 화면 이름 대신 로고 '차곡'을 보여 주는 상단 바.
  ///
  /// 홈처럼 첫 화면에서 씁니다. 로고 폰트(Jua)에는 '차곡' 두 글자만 있어
  /// 제목을 따로 받지 않습니다.
  const AppTopBar.logo({
    this.showBackButton = false,
    this.onBack,
    this.onMore,
    this.action,
    super.key,
  }) : assert(
         onMore == null || action == null,
         '오른쪽 자리는 하나라 onMore와 action을 함께 쓸 수 없습니다.',
       ),
       title = logoText,
       _variant = _AppTopBarVariant.logo;

  /// 브랜드 색 없이 진한 글자로 화면 이름을 보여 주는 상단 바.
  ///
  /// 알림 화면처럼 앱 기능 화면에서 씁니다. 뒤로 가기는 화살표(←)이고,
  /// 오른쪽에는 [action] 아이콘 버튼을 둘 수 있습니다.
  const AppTopBar.plain({
    required this.title,
    this.showBackButton = true,
    this.onBack,
    this.action,
    super.key,
  }) : onMore = null,
       _variant = _AppTopBarVariant.plain;

  /// 로고 글자.
  static const logoText = '차곡';

  /// 기본·로고 상단 바의 높이.
  static const height = 54.0;

  /// [AppTopBar.plain]의 높이.
  static const plainHeight = 52.0;

  /// 가운데에 보이는 제목. 예: "차곡", "회원가입"
  final String title;

  /// 왼쪽 뒤로 가기 버튼을 보일지 여부.
  final bool showBackButton;

  /// 뒤로 가기를 눌렀을 때 동작. 비우면 `Navigator.maybePop`을 호출합니다.
  final VoidCallback? onBack;

  /// 오른쪽 더보기(···)를 눌렀을 때 동작. 비우면 더보기를 숨깁니다.
  final VoidCallback? onMore;

  /// 오른쪽 아이콘 버튼. [onMore]와 함께 쓸 수 없습니다.
  final AppTopBarAction? action;

  final _AppTopBarVariant _variant;

  @override
  Size get preferredSize => Size.fromHeight(_variant.height);

  @override
  Widget build(BuildContext context) {
    final variant = _variant;
    final trailing = switch ((action, onMore)) {
      (final AppTopBarAction action, _) => _TapTarget(
        height: variant.height,
        semanticLabel: action.semanticLabel,
        onTap: action.onTap,
        child: action.hasBadge
            ? _Badged(child: _Icon(asset: action.icon))
            : _Icon(asset: action.icon),
      ),
      (null, final VoidCallback onMore) => _TapTarget(
        height: variant.height,
        semanticLabel: '더보기',
        onTap: onMore,
        child: Text(
          '···',
          style: AppTypography.listValue.copyWith(color: AppColors.textPrimary),
        ),
      ),
      (null, null) => null,
    };

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: variant.height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: variant.horizontalPadding),
          child: Row(
            children: [
              SizedBox(
                width: _sideSlotWidth,
                child: showBackButton
                    ? _TapTarget(
                        height: variant.height,
                        semanticLabel: '뒤로 가기',
                        onTap: onBack ?? () => Navigator.maybePop(context),
                        child: _Icon(asset: variant.backIcon),
                      )
                    : null,
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: variant.titleStyle,
                ),
              ),
              SizedBox(width: _sideSlotWidth, child: trailing),
            ],
          ),
        ),
      ),
    );
  }
}

const _iconSize = 24.0;

/// 양쪽 버튼의 누르는 영역. 손가락으로 누르기 쉬운 최소 크기(48)를 지킵니다.
/// 양쪽 너비가 같아야 제목이 가운데에 옵니다.
const _sideSlotWidth = kMinInteractiveDimension;

/// 상단 바 모양별 값. Figma에서 기본·로고 바와 알림 화면 바의 규격이 다릅니다.
enum _AppTopBarVariant {
  brand(
    height: AppTopBar.height,
    iconInset: AppSpacing.screenHorizontal,
    backIcon: AppIcons.back,
    titleStyle: AppTypography.topBarTitle,
  ),
  logo(
    height: AppTopBar.height,
    iconInset: AppSpacing.screenHorizontal,
    backIcon: AppIcons.back,
    titleStyle: AppTypography.logo,
  ),
  plain(
    height: AppTopBar.plainHeight,
    iconInset: AppSpacing.plainTopBarIconInset,
    backIcon: AppIcons.arrowBack,
    titleStyle: AppTypography.topBarTitlePlain,
  );

  const _AppTopBarVariant({
    required this.height,
    required this.iconInset,
    required this.backIcon,
    required this.titleStyle,
  });

  final double height;

  /// 화면 끝에서 아이콘까지의 거리.
  final double iconInset;
  final String backIcon;
  final TextStyle titleStyle;

  /// 누르는 영역이 아이콘보다 넓어진 만큼 바깥 여백을 줄여,
  /// 아이콘이 디자인과 같은 위치([iconInset])에 오게 합니다.
  double get horizontalPadding => iconInset - (_sideSlotWidth - _iconSize) / 2;
}

class _Icon extends StatelessWidget {
  const _Icon({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(asset, width: _iconSize, height: _iconSize);
  }
}

/// 아이콘 오른쪽 위에 작은 점을 겹쳐 그립니다.
class _Badged extends StatelessWidget {
  const _Badged({required this.child});

  final Widget child;

  static const _size = 7.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        const Positioned(
          top: 0,
          right: 0,
          child: SizedBox.square(
            dimension: _size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.navActive,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 작은 아이콘에도 손가락으로 누르기 쉬운 영역을 주는 래퍼.
class _TapTarget extends StatelessWidget {
  const _TapTarget({
    required this.height,
    required this.semanticLabel,
    required this.onTap,
    required this.child,
  });

  final double height;
  final String semanticLabel;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Center(child: child),
        ),
      ),
    );
  }
}
