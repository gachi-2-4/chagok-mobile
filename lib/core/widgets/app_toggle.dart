import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 켜고 끄는 스위치.
///
/// Figma `Setting/Toggle` 컴포넌트에 해당합니다.
/// [onChanged]가 null이면 비활성화됩니다.
class AppToggle extends StatelessWidget {
  const AppToggle({required this.value, required this.onChanged, super.key});

  static const _width = 46.0;
  static const _height = 28.0;
  static const _knobSize = 22.0;
  static const _padding = 3.0;
  static const _duration = Duration(milliseconds: 150);

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;

    return Semantics(
      toggled: value,
      enabled: onChanged != null,
      child: GestureDetector(
        onTap: onChanged == null ? null : () => onChanged(!value),
        child: Opacity(
          opacity: onChanged == null ? 0.5 : 1,
          child: AnimatedContainer(
            duration: _duration,
            width: _width,
            height: _height,
            padding: const EdgeInsets.all(_padding),
            decoration: BoxDecoration(
              color: value ? AppColors.toggleOn : AppColors.toggleOff,
              borderRadius: BorderRadius.circular(_height / 2),
            ),
            child: AnimatedAlign(
              duration: _duration,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.toggleKnob,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x26000000),
                      offset: Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: SizedBox.square(dimension: _knobSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
