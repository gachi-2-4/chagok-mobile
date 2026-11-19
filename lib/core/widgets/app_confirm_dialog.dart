import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_shadows.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// "예/아니요"로 한 번 더 확인받는 작은 창.
///
/// Figma `Setting/ConfirmModal` 컴포넌트에 해당합니다.
/// 보통 [AppConfirmDialog.show]로 띄웁니다.
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    required this.title,
    this.description,
    this.confirmLabel = '예',
    this.cancelLabel = '아니요',
    this.isDestructive = false,
    super.key,
  });

  static const _width = 300.0;
  static const _buttonHeight = 50.0;

  final String title;
  final String? description;
  final String confirmLabel;
  final String cancelLabel;

  /// 회원 탈퇴처럼 되돌릴 수 없는 동작이면 true. 확인 버튼이 붉게 보입니다.
  final bool isDestructive;

  /// 확인 창을 띄우고, 확인을 누르면 true를 돌려줍니다.
  ///
  /// 취소를 누르거나 바깥을 눌러 닫으면 false를 돌려줍니다.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    String? description,
    String confirmLabel = '예',
    String cancelLabel = '아니요',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.scrim,
      builder: (context) => AppConfirmDialog(
        title: title,
        description: description,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final description = this.description;

    // 설명이 길거나 글자가 커도 버튼이 화면 밖으로 밀려나지 않도록,
    // 제목·설명만 스크롤하고 버튼은 항상 아래에 고정합니다.
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Container(
            width: _width,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.dialogPaddingTop,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              color: AppColors.dialogSurface,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              boxShadow: AppShadows.dialog,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: AppTypography.dialogTitle,
                          ),
                          if (description != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              description,
                              textAlign: TextAlign.center,
                              style: AppTypography.dialogBody,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _DialogActions(
                    cancelLabel: cancelLabel,
                    confirmLabel: confirmLabel,
                    isDestructive: isDestructive,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  const _DialogActions({
    required this.cancelLabel,
    required this.confirmLabel,
    required this.isDestructive,
  });

  final String cancelLabel;
  final String confirmLabel;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DialogButton(
            label: cancelLabel,
            backgroundColor: AppColors.dialogCancel,
            foregroundColor: AppColors.textPrimary,
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _DialogButton(
            label: confirmLabel,
            backgroundColor: isDestructive
                ? AppColors.dangerButton
                : AppColors.primary,
            foregroundColor: AppColors.dialogSurface,
            onPressed: () => Navigator.pop(context, true),
          ),
        ),
      ],
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: const Size.fromHeight(AppConfirmDialog._buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
      ),
      child: Text(label, style: AppTypography.dialogButton),
    );
  }
}
