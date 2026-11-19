import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_document_layout.dart';
import 'package:chagok_mobile/core/widgets/app_page_header.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:chagok_mobile/features/document/application/document_edit_form.dart';
import 'package:chagok_mobile/features/document/application/document_edit_notifier.dart';
import 'package:chagok_mobile/features/document/data/document_repository.dart';
import 'package:chagok_mobile/features/document/presentation/document_strings.dart';
import 'package:chagok_mobile/features/document/presentation/widgets/option_sheet.dart';
import 'package:chagok_mobile/features/document/presentation/widgets/picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// D01 · 서류에서 읽어 낸 조건을 바로잡는 화면.
class DocumentEditScreen extends ConsumerWidget {
  const DocumentEditScreen({required this.documentId, super.key});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = documentEditProvider(documentId);
    final formValue = ref.watch(provider);

    return formValue.when(
      data: (form) => _DocumentEditBody(
        form: form,
        notifier: ref.read(provider.notifier),
        documentTypes: ref.read(documentRepositoryProvider).documentTypes,
      ),
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

class _DocumentEditBody extends StatelessWidget {
  const _DocumentEditBody({
    required this.form,
    required this.notifier,
    required this.documentTypes,
  });

  final DocumentEditForm form;
  final DocumentEditNotifier notifier;
  final List<String> documentTypes;

  static const _headerGap = 18.0;

  @override
  Widget build(BuildContext context) {
    final paymentDay = form.paymentDay;
    final contractEndDate = form.contractEndDate;

    Future<void> pickDocumentType() async {
      final type = await showOptionSheet(
        context,
        options: documentTypes,
        labelOf: (type) => type,
        selected: form.documentType,
      );
      if (type != null) notifier.updateDocumentType(type);
    }

    Future<void> pickPaymentDay() async {
      final day = await showOptionSheet(
        context,
        options: [for (var day = 1; day <= 31; day++) day],
        labelOf: DocumentStrings.monthlyDay,
        selected: paymentDay,
      );
      if (day != null) notifier.updatePaymentDay(day);
    }

    Future<void> pickContractEndDate() async {
      final now = DateTime.now();
      final date = await showDatePicker(
        context: context,
        initialDate: contractEndDate ?? now,
        firstDate: DateTime(now.year - 10),
        lastDate: DateTime(now.year + 30),
      );
      if (date != null) notifier.updateContractEndDate(date);
    }

    Future<void> save() async {
      final isSaved = await notifier.save();
      if (!isSaved || !context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(DocumentStrings.saved)));
      Navigator.maybePop(context);
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
        const SizedBox(height: _headerGap),
        PickerField(
          label: DocumentStrings.documentType,
          value: form.documentType,
          onTap: pickDocumentType,
        ),
        const SizedBox(height: AppSpacing.stack),
        _MonthlyRentField(
          initialValue: form.monthlyRentText,
          hasError: form.hasInvalidMonthlyRent,
          onChanged: notifier.updateMonthlyRent,
        ),
        const SizedBox(height: AppSpacing.stack),
        PickerField(
          label: DocumentStrings.paymentDay,
          value: paymentDay == null
              ? ''
              : DocumentStrings.monthlyDay(paymentDay),
          onTap: pickPaymentDay,
        ),
        const SizedBox(height: AppSpacing.stack),
        PickerField(
          label: DocumentStrings.contractEndDate,
          value: contractEndDate == null
              ? ''
              : DocumentStrings.date(contractEndDate),
          hintText: DocumentStrings.contractEndDateHint,
          icon: Icons.calendar_today_outlined,
          onTap: pickContractEndDate,
        ),
        const SizedBox(height: AppSpacing.stack),
        _PenaltyField(
          initialValue: form.penaltyText,
          onChanged: notifier.updatePenalty,
        ),
        const SizedBox(height: AppSpacing.stack),
        const Text(DocumentStrings.editNote, style: AppTypography.caption),
      ],
      actions: [
        AppButton.primary(
          label: DocumentStrings.saveEdit,
          onPressed: form.canSave ? save : null,
        ),
        AppButton.secondary(
          label: DocumentStrings.viewOriginal,
          onPressed: viewOriginal,
        ),
      ],
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
    text: _ThousandsFormatter.format(widget.initialValue),
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
          inputFormatters: const [_ThousandsFormatter()],
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

/// 숫자만 남기고 세 자리마다 쉼표를 넣습니다. 예: "500000" → "500,000"
class _ThousandsFormatter extends TextInputFormatter {
  const _ThousandsFormatter();

  static String format(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    final value = int.tryParse(digits);
    return value == null ? '' : DocumentStrings.amount(value);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = format(newValue.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
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
