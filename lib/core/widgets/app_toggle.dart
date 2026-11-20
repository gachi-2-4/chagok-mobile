import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
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
  static const _disabledOpacity = 0.5;
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
            opacity: isEnabled ? 1 : _disabledOpacity,
            child: _ToggleTrack(value: value),
          ),
        ),
      ),
    );
  }
}

/// 스위치 바탕과 손잡이. 포커스를 받으면 테두리를 그립니다.
class _ToggleTrack extends StatelessWidget {
  const _ToggleTrack({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    // 포커스 테두리를 그리려면 포커스 변화에 맞춰 다시 그려야 해서 Focus.of로 읽습니다.
    final hasFocus = Focus.of(context).hasPrimaryFocus;

    return AnimatedContainer(
      duration: AppToggle._duration,
      width: AppToggle._width,
      height: AppToggle._height,
      // 손잡이를 바탕 가운데에 두도록, 바탕 높이와 손잡이 크기의 차이만큼 띄웁니다.
      padding: const EdgeInsets.all(
        (AppToggle._height - AppToggle._knobSize) / 2,
      ),
      decoration: BoxDecoration(
        color: value ? AppColors.toggleOn : AppColors.toggleOff,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      foregroundDecoration: hasFocus
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: AppColors.primary,
                width: AppToggle._focusBorderWidth,
              ),
            )
          : null,
      child: AnimatedAlign(
        duration: AppToggle._duration,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.toggleKnob,
            shape: BoxShape.circle,
            boxShadow: AppShadows.toggleKnob,
          ),
          child: SizedBox.square(dimension: AppToggle._knobSize),
        ),
      ),
    );
  }
}
