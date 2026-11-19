import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_shadows.dart';
import 'package:flutter/material.dart';

/// 켜고 끄는 스위치.
///
/// Figma `Setting/Toggle` 컴포넌트에 해당합니다.
/// [onChanged]가 null이면 비활성화됩니다.
/// 키보드로 포커스를 옮긴 뒤 Enter·Space로도 바꿀 수 있습니다.
class AppToggle extends StatelessWidget {
  const AppToggle({required this.value, required this.onChanged, super.key});

  static const _width = 46.0;
  static const _height = 28.0;
  static const _knobSize = 22.0;
  static const _padding = 3.0;
  static const _focusBorderWidth = 2.0;
  static const _duration = Duration(milliseconds: 150);

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final isEnabled = onChanged != null;

    return Semantics(
      toggled: value,
      enabled: isEnabled,
      child: FocusableActionDetector(
        enabled: isEnabled,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onChanged?.call(!value);
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTap: isEnabled ? () => onChanged(!value) : null,
          child: Opacity(
            opacity: isEnabled ? 1 : 0.5,
            // 포커스 테두리를 그리려면 포커스 변화에 맞춰 다시 그려야 해서 Builder로 감쌉니다.
            child: Builder(
              builder: (context) => AnimatedContainer(
                duration: _duration,
                width: _width,
                height: _height,
                padding: const EdgeInsets.all(_padding),
                decoration: BoxDecoration(
                  color: value ? AppColors.toggleOn : AppColors.toggleOff,
                  borderRadius: BorderRadius.circular(_height / 2),
                ),
                foregroundDecoration: Focus.of(context).hasPrimaryFocus
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(_height / 2),
                        border: Border.all(
                          color: AppColors.primary,
                          width: _focusBorderWidth,
                        ),
                      )
                    : null,
                child: AnimatedAlign(
                  duration: _duration,
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.toggleKnob,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.toggleKnob,
                    ),
                    child: SizedBox.square(dimension: _knobSize),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
