import 'dart:async';

import 'package:chagok_mobile/core/constants/core_strings.dart';
import 'package:chagok_mobile/core/constants/document_type_names.dart';
import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_exception.dart';
import 'package:chagok_mobile/core/network/api_formats.dart';
import 'package:chagok_mobile/core/network/json_map.dart';
import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/document_box.dart';
import 'package:chagok_mobile/features/upload/data/extracted_field.dart';
import 'package:chagok_mobile/features/upload/data/picked_document.dart';
import 'package:chagok_mobile/features/upload/data/upload_file.dart';
import 'package:chagok_mobile/features/upload/data/upload_repository.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// 차곡 API 서버의 서류 업로드·상세 조회·추출 결과 확인으로 서류를 담는 [UploadRepository].
///
/// 분석은 서버에서 비동기로 합니다. 올리면(`POST /documents`) 서버가 바로 서류 ID를
/// 주고, 앱은 분석이 끝날 때까지 서류 상세를 2초마다 최대 120초 조회합니다.
/// 파일 고르기는 기기 기능이라 [_pick]에 맡깁니다.
class ApiUploadRepository implements UploadRepository {
  ApiUploadRepository({
    required this._client,
    required this._pick,
    this._pollInterval = const Duration(seconds: 2),
    this._pollTimeout = const Duration(seconds: 120),
    this._wait = _delay,
  });

  final ApiClient _client;

  /// 기기에서 파일을 고르는 함수. 사용자가 취소하면 null을 돌려줍니다.
  final Future<PickedDocument?> Function(UploadSource source) _pick;

  /// 분석 상태를 다시 조회하는 간격.
  final Duration _pollInterval;

  /// 분석을 기다리는 최대 시간. 넘으면 [TimeoutException]을 던집니다.
  final Duration _pollTimeout;

  /// [_pollInterval]만큼 기다리는 함수. 테스트에서 시간을 건너뛰려고 받습니다.
  final Future<void> Function(Duration duration) _wait;

  /// 서류 ID별로 올릴 때 고른 보관함. 확인하기 전에 보관함을 바꾸면 옮깁니다.
  final _uploadedBoxIds = <String, String>{};

  @override
  Future<PickedDocument?> pick(UploadSource source) => _pick(source);

  @override
  Future<List<DocumentBox>> fetchBoxes() async {
    final json = await _client.get('/boxes');
    return [
      for (final box in json.maps('content'))
        DocumentBox(id: box.id('boxId'), name: box.string('name')),
    ];
  }

  /// 파일을 올리고 분석이 끝날 때까지 기다립니다.
  ///
  /// 글자를 읽지 못했으면 [AnalysisUnclear]를, 서버가 분석하지 못했으면
  /// [ApiException]을 돌려줍니다. 올릴 파일 내용이 없으면 [StateError]를 던집니다.
  @override
  Future<AnalysisResult> analyze(
    PickedDocument document, {
    required String boxId,
  }) async {
    final files = document.files;
    if (files.isEmpty) {
      throw StateError('${document.fileName}: 올릴 파일 내용이 없습니다');
    }
    final uploaded = await _client.postMultipart(
      '/documents',
      fields: {
        'boxId': '${apiId(boxId)}',
        'source': switch (document.source) {
          UploadSource.camera => 'CAMERA',
          UploadSource.album => 'ALBUM',
          UploadSource.pdf => 'PDF',
        },
      },
      files: () => [for (final file in files) _multipartOf(file)],
    );
    final documentId = uploaded.id('documentId');
    _uploadedBoxIds[documentId] = boxId;

    final json = await _waitForAnalysis(documentId);
    if (json.stringOrNull('status') == 'FAILED') {
      if (json.stringOrNull('failReason') == 'TEXT_NOT_RECOGNIZED') {
        return const AnalysisUnclear();
      }
      throw const ApiException(
        statusCode: 502,
        code: 'ANALYSIS_ERROR',
        message: CoreStrings.unknownError,
      );
    }
    return AnalysisSucceeded(
      documentId: documentId,
      documentType: documentTypeNameOf(json.stringOrNull('docType')),
      pageCount: json.integerOrNull('pageCount') ?? document.pageCount,
      fields: [for (final field in json.maps('fields')) _fieldOf(field)],
    );
  }

  /// 분석 결과를 확인하고 보관을 마칩니다(`POST /documents/{id}/confirm`).
  ///
  /// 올린 뒤 보관함을 바꿨으면 먼저 그 보관함으로 옮깁니다. 서버에 올리지 않은
  /// 결과면 [StateError]를 던집니다.
  @override
  Future<void> save({
    required PickedDocument document,
    required AnalysisSucceeded result,
    required String boxId,
  }) async {
    final documentId =
        result.documentId ??
        (throw StateError('${document.fileName}: 서버에 올린 서류가 아닙니다'));
    final path = '/documents/${apiId(documentId)}';
    if (_uploadedBoxIds[documentId] != boxId) {
      await _client.patch(path, body: {'boxId': apiId(boxId)});
    }
    await _client.post('$path/confirm');
    _uploadedBoxIds.remove(documentId);
  }

  Future<JsonMap> _waitForAnalysis(String documentId) async {
    final path = '/documents/${apiId(documentId)}';
    var waited = Duration.zero;
    while (true) {
      final json = await _client.get(path);
      if (json.stringOrNull('status') != 'ANALYZING') return json;
      if (waited >= _pollTimeout) {
        throw TimeoutException('서류 $documentId 분석이 끝나지 않았습니다', _pollTimeout);
      }
      await _wait(_pollInterval);
      waited += _pollInterval;
    }
  }

  /// 서버 항목을 확인 화면(U04)의 조건 하나로 바꿉니다.
  ///
  /// 확인이 필요한 항목(`needsReview`)은 값을 비워 "확실히 읽지 못했어요"로 보여 줍니다.
  ExtractedField _fieldOf(JsonMap json) {
    final label = json.string('label');
    final originalLabel = json.stringOrNull('originalLabel');
    return ExtractedField(
      label: label,
      value: json.boolean('needsReview') ? null : _valueOf(json),
      originalLabel: originalLabel == label ? null : originalLabel,
    );
  }

  String? _valueOf(JsonMap json) {
    final value = json['value'];
    return switch ((json.stringOrNull('valueType'), value)) {
      (_, null) => null,
      ('AMOUNT', final num amount) => '${_thousands(amount.toInt())}원',
      ('DATE', final String date) => _dotDate(date),
      (_, final value) => '$value',
    };
  }

  /// `2027-01-02` → `2027.1.2`
  String _dotDate(String date) {
    final parsed = parseApiDate(date);
    return '${parsed.year}.${parsed.month}.${parsed.day}';
  }

  /// `500000` → `500,000`
  String _thousands(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer(value < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  http.MultipartFile _multipartOf(UploadFile file) {
    final extension = file.fileName.split('.').last.toLowerCase();
    return http.MultipartFile.fromBytes(
      'files',
      file.bytes,
      filename: file.fileName,
      contentType: switch (extension) {
        'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
        'png' => MediaType('image', 'png'),
        'heic' => MediaType('image', 'heic'),
        'pdf' => MediaType('application', 'pdf'),
        _ => MediaType('application', 'octet-stream'),
      },
    );
  }
}

Future<void> _delay(Duration duration) => Future<void>.delayed(duration);
