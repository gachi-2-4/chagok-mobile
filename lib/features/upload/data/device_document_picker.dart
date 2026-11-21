import 'dart:io';
import 'dart:typed_data';

import 'package:chagok_mobile/features/upload/data/camera_permission_denied_exception.dart';
import 'package:chagok_mobile/features/upload/data/picked_document.dart';
import 'package:chagok_mobile/features/upload/data/upload_file.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';

/// 문서 스캐너로 서류 쪽 사진을 찍거나 고릅니다. 취소하면 null, 사진 경로는 쪽 순서입니다.
typedef ScanPages = Future<List<String>?> Function({
  required bool fromGallery,
  required int maxPages,
});

/// 기기에 저장된 PDF 하나를 고릅니다. 취소하면 null.
typedef PickPdf = Future<UploadFile?> Function();

/// [path]의 파일 내용을 읽습니다.
typedef ReadFile = Future<Uint8List> Function(String path);

/// 기기의 문서 스캐너와 파일 선택기로 서류를 가져옵니다.
///
/// - 카메라: 문서 스캐너가 종이 테두리를 찾아 반듯하게 펴 주고, 여러 쪽을 이어 찍습니다.
/// - 앨범: 같은 스캐너의 사진 고르기로 여러 장을 고릅니다.
/// - PDF: 파일 선택기로 하나를 고릅니다. 쪽수는 서버가 분석해야 알 수 있습니다.
///
/// 스캐너·파일 선택기·파일 읽기는 테스트에서 바꿔 끼울 수 있게 받습니다.
class DeviceDocumentPicker {
  DeviceDocumentPicker({ScanPages? scan, PickPdf? pickPdf, ReadFile? readFile})
    : _scan = scan ?? _scanWithScanner,
      _pickPdf = pickPdf ?? _pickPdfWithFilePicker,
      _readFile = readFile ?? _readFromDisk;

  /// 서버가 서류 하나로 받는 사진의 최대 장수.
  static const maxPages = 10;

  final ScanPages _scan;
  final PickPdf _pickPdf;
  final ReadFile _readFile;

  /// [source]에서 서류를 가져옵니다. 사용자가 취소하면 null.
  ///
  /// 카메라 권한이 꺼져 있으면 [CameraPermissionDeniedException]을 던집니다.
  Future<PickedDocument?> pick(UploadSource source) async {
    return switch (source) {
      UploadSource.camera => _pickPages(source, fromGallery: false),
      UploadSource.album => _pickPages(source, fromGallery: true),
      UploadSource.pdf => _pickPdfDocument(),
    };
  }

  Future<PickedDocument?> _pickPages(
    UploadSource source, {
    required bool fromGallery,
  }) async {
    final paths = await _scan(fromGallery: fromGallery, maxPages: maxPages);
    if (paths == null || paths.isEmpty) return null;
    final files = [
      for (final (index, path) in paths.indexed)
        UploadFile(
          // 서버는 확장자로 JPG·PNG·HEIC를 가리므로 원래 확장자를 살립니다.
          fileName: 'scan-${index + 1}.${_extensionOf(path)}',
          bytes: await _readFile(path),
        ),
    ];
    return PickedDocument(
      fileName: files.first.fileName,
      source: source,
      pageCount: files.length,
      files: files,
    );
  }

  Future<PickedDocument?> _pickPdfDocument() async {
    final file = await _pickPdf();
    if (file == null) return null;
    return PickedDocument(
      fileName: file.fileName,
      source: UploadSource.pdf,
      files: [file],
    );
  }

  /// 경로의 확장자(소문자). 없으면 스캐너 기본 형식인 jpg로 봅니다.
  static String _extensionOf(String path) {
    final name = path.split(Platform.pathSeparator).last;
    final dot = name.lastIndexOf('.');
    return dot < 0 ? 'jpg' : name.substring(dot + 1).toLowerCase();
  }

  static Future<List<String>?> _scanWithScanner({
    required bool fromGallery,
    required int maxPages,
  }) async {
    try {
      final result = await CunningDocumentScanner.scanDocuments(
        noOfPages: maxPages,
        scannerSource: fromGallery
            ? ScannerSource.gallery
            : ScannerSource.camera,
        // 서버에 올릴 크기를 줄이려고 PNG 대신 JPG로 받습니다.
        iosScannerOptions: IosScannerOptions(
          imageFormat: IosImageFormat.jpg,
          jpgCompressionQuality: _jpgQuality,
        ),
      );
      return result?.images;
    } on CunningDocumentScannerException catch (error) {
      if (error.code == _permissionDeniedCode) {
        throw const CameraPermissionDeniedException();
      }
      rethrow;
    }
  }

  static Future<UploadFile?> _pickPdfWithFilePicker() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    final file = files.firstOrNull;
    if (file == null) return null;
    return UploadFile(fileName: file.name, bytes: await file.readAsBytes());
  }

  static Future<Uint8List> _readFromDisk(String path) =>
      File(path).readAsBytes();

  /// 글자를 읽을 수 있을 만큼 선명하면서 용량을 줄이는 JPG 품질.
  static const _jpgQuality = 0.85;

  /// 스캐너가 카메라 권한이 없을 때 주는 코드.
  static const _permissionDeniedCode = 'permission_denied';
}
