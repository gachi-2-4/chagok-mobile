import 'dart:async';

import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_document_layout.dart';
import 'package:chagok_mobile/core/widgets/app_option_sheet.dart';
import 'package:chagok_mobile/core/widgets/app_page_header.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:chagok_mobile/features/document/application/document_edit_form.dart';
import 'package:chagok_mobile/features/document/application/document_edit_notifier.dart';
import 'package:chagok_mobile/features/document/presentation/document_strings.dart';
import 'package:chagok_mobile/features/document/presentation/widgets/picker_field.dart';
import 'package:chagok_mobile/features/document/presentation/widgets/thousands_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// D01 · 서류에서 읽어 낸 조건을 바로잡는 화면.
class DocumentEditScreen extends ConsumerWidget {
  const DocumentEditScreen({required this.documentId, super.key});

  /// 고칠 서류 id.
  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = documentEditProvider(documentId);

    return ref
        .watch(provider)
        .when(
          data: (form) => _DocumentEditBody(documentId: documentId, form: form),
          loading: () => const AppDocumentLayout(
            body: [Center(child: CircularProgressIndicator())],
            actions: [],
          ),
          error: (error, stackTrace) => AppDocumentLayout(
            body: const [
              Text(DocumentStrings.loadFailed, style: AppTypography.body),
            ],
            actions: [
              AppButton.secondary(
                label: DocumentStrings.retry,
                onPressed: () => ref.invalidate(provider),
              ),
            ],
          ),
        );
  }
}

/// 불러온 [form]으로 그린 입력창들과 저장·원본 확인 버튼.
class _DocumentEditBody extends ConsumerWidget {
  const _DocumentEditBody({required this.documentId, required this.form});

  final String documentId;
  final DocumentEditForm form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DocumentEditNotifier notifier() =>
        ref.read(documentEditProvider(documentId).notifier);

    Future<void> save() async {
      final isSaved = await notifier().save();
      if (!isSaved || !context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(DocumentStrings.saved)));
      await Navigator.maybePop(context);
    }

    void viewOriginal() {
      // TODO: 원본 파일 보기 화면이 생기면 연결합니다.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(DocumentStrings.comingSoon)));
    }

    return AppDocumentLayout(
      body: [
        const AppPageHeader(
          title: DocumentStrings.editTitle,
          description: DocumentStrings.editDescription,
        ),
        const SizedBox(height: AppSpacing.block),
        _PickerFields(documentId: documentId, form: form),
        const SizedBox(height: AppSpacing.stack),
        _PenaltyField(
          initialValue: form.penaltyText,
          onChanged: (value) => notifier().updatePenalty(value),
        ),
        const SizedBox(height: AppSpacing.stack),
        const Text(DocumentStrings.editNote, style: AppTypography.caption),
        if (form.hasSaveFailed) ...[
          const SizedBox(height: AppSpacing.stack),
          Text(
            DocumentStrings.saveFailed,
            style: AppTypography.caption.copyWith(color: AppColors.danger),
          ),
        ],
      ],
      actions: [
        AppButton.primary(
          label: DocumentStrings.saveEdit,
          onPressed: form.canSave ? () => unawaited(save()) : null,
        ),
        AppButton.secondary(
          label: DocumentStrings.viewOriginal,
          onPressed: viewOriginal,
        ),
      ],
    );
  }
}

/// 문서 종류·월 임대료·납부일·계약 종료일 입력창.
class _PickerFields extends ConsumerWidget {
  const _PickerFields({required this.documentId, required this.form});

  final String documentId;
  final DocumentEditForm form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DocumentTypeField(documentId: documentId, selected: form.documentType),
        const SizedBox(height: AppSpacing.stack),
        _MonthlyRentField(
          initialValue: form.monthlyRentText,
          hasError: form.hasInvalidMonthlyRent,
          onChanged: (value) => ref
              .read(documentEditProvider(documentId).notifier)
              .updateMonthlyRent(value),
        ),
        const SizedBox(height: AppSpacing.stack),
        _PaymentDayField(documentId: documentId, selected: form.paymentDay),
        const SizedBox(height: AppSpacing.stack),
        _ContractEndDateField(
          documentId: documentId,
          selected: form.contractEndDate,
        ),
      ],
    );
  }
}

/// 문서 종류 고르기. 누르면 서류 종류 목록을 띄웁니다.
class _DocumentTypeField extends ConsumerWidget {
  const _DocumentTypeField({required this.documentId, required this.selected});

  final String documentId;
  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> pick() async {
      final type = await showAppOptionSheet(
        context,
        options: ref.read(documentTypesProvider),
        labelOf: (type) => type,
        selected: selected,
      );
      if (type == null) return;
      ref
          .read(documentEditProvider(documentId).notifier)
          .updateDocumentType(type);
    }

    return PickerField(
      label: DocumentStrings.documentType,
      value: selected,
      onTap: () => unawaited(pick()),
    );
  }
}

/// 매월 납부일 고르기. 누르면 1~31일 목록을 띄웁니다.
class _PaymentDayField extends ConsumerWidget {
  const _PaymentDayField({required this.documentId, required this.selected});

  final String documentId;
  final int? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = this.selected;

    Future<void> pick() async {
      final day = await showAppOptionSheet(
        context,
        options: [for (var day = 1; day <= 31; day++) day],
        labelOf: DocumentStrings.monthlyDay,
        selected: selected,
      );
      if (day == null) return;
      ref.read(documentEditProvider(documentId).notifier).updatePaymentDay(day);
    }

    return PickerField(
      label: DocumentStrings.paymentDay,
      value: selected == null ? '' : DocumentStrings.monthlyDay(selected),
      onTap: () => unawaited(pick()),
    );
  }
}

/// 계약 종료일 고르기. 누르면 달력을 띄웁니다.
class _ContractEndDateField extends ConsumerWidget {
  const _ContractEndDateField({
    required this.documentId,
    required this.selected,
  });

  final String documentId;
  final DateTime? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = this.selected;

    Future<void> pick() async {
      final now = DateTime.now();
      final date = await showDatePicker(
        context: context,
        initialDate: selected ?? now,
        firstDate: DateTime(now.year - 10),
        lastDate: DateTime(now.year + 30),
      );
      if (date == null) return;
      ref
          .read(documentEditProvider(documentId).notifier)
          .updateContractEndDate(date);
    }

    return PickerField(
      label: DocumentStrings.contractEndDate,
      value: selected == null ? '' : DocumentStrings.date(selected),
      hintText: DocumentStrings.contractEndDateHint,
      icon: Icons.calendar_today_outlined,
      onTap: () => unawaited(pick()),
    );
  }
}

/// 월 임대료 입력창. 숫자를 세 자리마다 쉼표로 끊어 보여 주고 뒤에 "원"을 붙입니다.
class _MonthlyRentField extends StatefulWidget {
  const _MonthlyRentField({
    required this.initialValue,
    required this.hasError,
    required this.onChanged,
  });

  final String initialValue;
  final bool hasError;
  final ValueChanged<String> onChanged;

  @override
  State<_MonthlyRentField> createState() => _MonthlyRentFieldState();
}

class _MonthlyRentFieldState extends State<_MonthlyRentField> {
  late final _controller = TextEditingController(
    text: ThousandsInputFormatter.format(widget.initialValue),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: DocumentStrings.monthlyRent,
          controller: _controller,
          onChanged: widget.onChanged,
          keyboardType: TextInputType.number,
          inputFormatters: const [ThousandsInputFormatter()],
          suffix: const Text(
            DocumentStrings.won,
            style: AppTypography.fieldInput,
          ),
        ),
        if (widget.hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            DocumentStrings.invalidMonthlyRent,
            style: AppTypography.caption.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}

/// 중도 해지 위약금 입력창.
class _PenaltyField extends StatefulWidget {
  const _PenaltyField({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_PenaltyField> createState() => _PenaltyFieldState();
}

class _PenaltyFieldState extends State<_PenaltyField> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: DocumentStrings.penalty,
      hintText: DocumentStrings.penaltyHint,
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.done,
    );
  }
}
