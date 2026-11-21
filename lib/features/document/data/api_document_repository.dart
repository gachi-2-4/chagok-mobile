import 'package:chagok_mobile/core/constants/document_type_names.dart';
import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_exception.dart';
import 'package:chagok_mobile/core/network/api_formats.dart';
import 'package:chagok_mobile/core/network/json_map.dart';
import 'package:chagok_mobile/features/document/data/document_detail.dart';
import 'package:chagok_mobile/features/document/data/document_not_found_exception.dart';
import 'package:chagok_mobile/features/document/data/document_repository.dart';
import 'package:chagok_mobile/features/document/data/payment_reminder.dart';

/// 차곡 API 서버의 서류 상세·서류 내용 수정·기한 알림 API로 서류를 다루는 [DocumentRepository].
///
/// 서류 항목은 AI 문서 분석이 정한 key로 주고받습니다. 이 화면이 쓰는 항목은
/// 월세(`monthlyRent`), 계약 만료일(`contractEndDate`), 중도 해지 위약금입니다.
/// 서버는 그 서류에 없는 key를 고치려 하면 400을 주므로, 불러온 서류에 있는 항목만 보냅니다.
class ApiDocumentRepository implements DocumentRepository {
  ApiDocumentRepository({required this._client});

  final ApiClient _client;

  static const _monthlyRentKey = 'monthlyRent';
  static const _contractEndDateKey = 'contractEndDate';

  /// 명세 예시마다 위약금 key가 달라(`earlyTerminationPenalty`·`earlyTerminationFee`) 둘 다 찾습니다.
  static const _penaltyKeys = [
    'earlyTerminationPenalty',
    'earlyTerminationFee',
  ];

  @override
  List<String> get documentTypes => documentTypeNames.values.toList();

  @override
  Future<DocumentDetail> fetchDetail(String id) async {
    final json = await _fetchDocument(id);
    final fields = _fieldsByKey(json);
    final penaltyKey = _penaltyKeyIn(fields);
    return DocumentDetail(
      id: json.id('documentId'),
      boxName: json.mapOrNull('box')?.stringOrNull('name') ?? '',
      documentType: documentTypeNameOf(json.stringOrNull('docType')),
      monthlyRent: fields[_monthlyRentKey]?.integerOrNull('value'),
      paymentDay: _monthlySchedule(json)?.integerOrNull('dayOfMonth'),
      contractEndDate: switch (fields[_contractEndDateKey]?.stringOrNull(
        'value',
      )) {
        final date? => parseApiDate(date),
        null => null,
      },
      earlyTerminationPenalty: penaltyKey == null
          ? null
          : fields[penaltyKey]?.stringOrNull('value'),
    );
  }

  /// 고친 내용을 저장합니다.
  ///
  /// 서류 종류를 바꾸면 서버가 항목 구성을 새로 정하려고 다시 분석하므로, 종류만 따로
  /// 보내고 나머지 값은 보내지 않습니다(다시 분석하면 덮어써집니다).
  @override
  Future<void> updateDetail(DocumentDetail detail) async {
    final json = await _fetchDocument(detail.id);
    final path = '/documents/${apiId(detail.id)}/fields';
    final docType = documentTypeNames.entries
        .where((entry) => entry.value == detail.documentType)
        .firstOrNull
        ?.key;
    if (docType != null && docType != json.stringOrNull('docType')) {
      await _client.patch(path, body: {'docType': docType});
      return;
    }

    final fields = _fieldsByKey(json);
    final penaltyKey = _penaltyKeyIn(fields);
    final changes = [
      if (fields.containsKey(_monthlyRentKey))
        {'key': _monthlyRentKey, 'value': detail.monthlyRent},
      if (fields.containsKey(_contractEndDateKey))
        {
          'key': _contractEndDateKey,
          'value': switch (detail.contractEndDate) {
            final date? => formatApiDate(date),
            null => null,
          },
        },
      if (penaltyKey != null)
        {'key': penaltyKey, 'value': detail.earlyTerminationPenalty},
    ];
    final schedule = _monthlySchedule(json);
    final paymentDay = detail.paymentDay;
    await _client.patch(
      path,
      body: {
        'fields': changes,
        if (schedule != null && paymentDay != null)
          'paymentSchedules': [
            {'key': schedule.string('key'), 'dayOfMonth': paymentDay},
          ],
      },
    );
  }

  @override
  Future<PaymentReminder?> fetchReminder(String documentId) async {
    final json = await _fetchDocument(documentId);
    final deadline = _paymentDeadline(json);
    final reminder = deadline?.mapOrNull('reminder');
    if (deadline == null || reminder == null) return null;
    return PaymentReminder(
      documentId: documentId,
      paymentDay:
          _monthlySchedule(json)?.integerOrNull('dayOfMonth') ??
          parseApiDate(deadline.string('date')).day,
      minuteOfDay: parseApiTime(reminder.string('alertTime')),
      advanceDays: reminder.integers('advanceDays').toSet(),
      isMonthly: deadline.stringOrNull('recurrence') == 'MONTHLY',
    );
  }

  /// 납부일 알림을 저장합니다.
  ///
  /// 기한 알림은 기한이 생길 때 서버가 대부분 미리 만들어 두므로, 있으면 고치고
  /// (`PATCH /reminders/{id}`) 없으면 새로 켭니다(`POST /reminders`). 납부일은
  /// 기한 알림이 아니라 서류 내용이라, 바뀌었으면 서류 내용 수정으로 먼저 고칩니다.
  /// 납부 기한이 없는 서류면 [StateError]를 던집니다.
  @override
  Future<void> saveReminder(PaymentReminder reminder) async {
    var json = await _fetchDocument(reminder.documentId);
    final schedule = _monthlySchedule(json);
    if (schedule != null &&
        schedule.integerOrNull('dayOfMonth') != reminder.paymentDay) {
      json = await _client.patch(
        '/documents/${apiId(reminder.documentId)}/fields',
        body: {
          'paymentSchedules': [
            {'key': schedule.string('key'), 'dayOfMonth': reminder.paymentDay},
          ],
        },
      );
    }
    final deadline =
        _paymentDeadline(json) ??
        (throw StateError('서류 ${reminder.documentId}에 납부 기한이 없습니다'));
    final isRecurring = deadline.stringOrNull('recurrence') == 'MONTHLY';
    final body = {
      'alertTime': formatApiTime(reminder.minuteOfDay),
      'advanceDays': reminder.advanceDays.toList()..sort(),
      // 매월 반복은 반복 기한에만 보낼 수 있습니다.
      if (isRecurring) 'repeatMonthly': reminder.isMonthly,
    };
    final reminderId = deadline.mapOrNull('reminder')?.idOrNull('reminderId');
    if (reminderId != null) {
      await _client.patch('/reminders/$reminderId', body: body);
    } else {
      await _client.post(
        '/reminders',
        body: {'deadlineId': deadline.integer('deadlineId'), ...body},
      );
    }
  }

  Future<JsonMap> _fetchDocument(String id) async {
    try {
      return await _client.get('/documents/${apiId(id)}');
    } on ApiException catch (error) {
      if (error.isNotFound) throw DocumentNotFoundException(id);
      rethrow;
    } on FormatException {
      // 숫자가 아닌 id는 서버에 있을 수 없는 서류입니다.
      throw DocumentNotFoundException(id);
    }
  }

  Map<String, JsonMap> _fieldsByKey(JsonMap document) => {
    for (final field in document.maps('fields')) field.string('key'): field,
  };

  String? _penaltyKeyIn(Map<String, JsonMap> fields) =>
      _penaltyKeys.where(fields.containsKey).firstOrNull;

  /// 매월 납부 일정. 월세 일정이 있으면 그것을, 없으면 첫 일정을 씁니다.
  JsonMap? _monthlySchedule(JsonMap document) {
    final schedules = document.maps('paymentSchedules');
    return schedules
            .where(
              (schedule) => schedule.stringOrNull('key') == _monthlyRentKey,
            )
            .firstOrNull ??
        schedules.firstOrNull;
  }

  /// D02가 알림을 거는 납부 기한. 매월 반복하는 납부 기한을 먼저 고릅니다.
  JsonMap? _paymentDeadline(JsonMap document) {
    final payments = document
        .maps('deadlines')
        .where((deadline) => deadline.stringOrNull('type') == 'PAYMENT')
        .toList();
    return payments
            .where(
              (deadline) => deadline.stringOrNull('recurrence') == 'MONTHLY',
            )
            .firstOrNull ??
        payments.firstOrNull;
  }
}
