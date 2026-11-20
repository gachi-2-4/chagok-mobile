import 'package:flutter/painting.dart';

/// 기기 글자 크기 설정([base])에 앱 설정 배율([factor])을 한 번 더 곱하는 [TextScaler].
///
/// 앱 전체에 저장한 글자 크기를 적용할 때 쓰고, 미리 보기는 [base]만 꺼내
/// 아직 저장하지 않은 배율을 곱해 보여 줄 수 있습니다.
class AppTextScaler extends TextScaler {
  const AppTextScaler(this.base, this.factor);

  /// 기기 글자 크기 설정.
  final TextScaler base;

  /// 앱 설정에서 고른 배율.
  final double factor;

  @override
  double scale(double fontSize) => base.scale(fontSize) * factor;

  @override
  // ignore: deprecated_member_use - TextScaler를 구현하려면 재정의해야 합니다.
  double get textScaleFactor => base.textScaleFactor * factor;

  @override
  bool operator ==(Object other) =>
      other is AppTextScaler && other.base == base && other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}
