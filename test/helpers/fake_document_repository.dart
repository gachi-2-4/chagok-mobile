import 'dart:async';

import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:chagok_mobile/features/document/data/document_not_found_exception.dart';
import 'package:chagok_mobile/features/document/data/document_repository.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';

/// 서류 하나를 메모리에 두고 저장 요청을 기록하는 가짜 [DocumentRepository].
class FakeDocumentRepository implements DocumentRepository {
  FakeDocumentRepository({required this.detail, this.reminder});

  DocumentDetail detail;
  PaymentReminder? reminder;
  final updatedDetails = <DocumentDetail>[];
  final savedReminders = <PaymentReminder>[];

  /// 값을 넣으면 저장 요청([updateDetail]·[saveReminder])에서 이 예외를 던집니다.
  Exception? saveError;

  /// 값을 넣으면 저장 요청이 이것이 끝날 때까지 기다립니다.
  Completer<void>? saveGate;

  @override
  List<String> get documentTypes => const ['임대차계약서', '관리비 고지서'];

  @override
  Future<DocumentDetail> fetchDetail(String id) async {
    if (id != detail.id) throw DocumentNotFoundException(id);
    return detail;
  }

  @override
  Future<void> updateDetail(DocumentDetail detail) async {
    await saveGate?.future;
    if (saveError case final error?) throw error;
    updatedDetails.add(detail);
    this.detail = detail;
  }

  @override
  Future<PaymentReminder?> fetchReminder(String documentId) async => reminder;

  @override
  Future<void> saveReminder(PaymentReminder reminder) async {
    await saveGate?.future;
    if (saveError case final error?) throw error;
    savedReminders.add(reminder);
    this.reminder = reminder;
  }
}
