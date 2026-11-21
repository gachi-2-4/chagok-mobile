import 'dart:typed_data';

import 'package:chagok_mobile/features/upload/data/camera_permission_denied_exception.dart';
import 'package:chagok_mobile/features/upload/data/device_document_picker.dart';
import 'package:chagok_mobile/features/upload/data/upload_file.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// 스캐너에 넘어온 (갤러리에서 고르는지, 최대 장수).
  late List<(bool, int)> scanCalls;

  /// 가짜 스캐너가 돌려줄 사진 경로. null이면 취소입니다.
  late List<String>? scannedPaths;

  /// 가짜 파일 선택기가 돌려줄 PDF. null이면 취소입니다.
  late UploadFile? pickedPdf;

  late DeviceDocumentPicker picker;

  setUp(() {
    scanCalls = [];
    scannedPaths = ['/cache/page-a.JPG', '/cache/page-b.png'];
    pickedPdf = UploadFile(fileName: '임대차계약서.pdf', bytes: Uint8List(3));
    picker = DeviceDocumentPicker(
      scan: ({required fromGallery, required maxPages}) async {
        scanCalls.add((fromGallery, maxPages));
        return scannedPaths;
      },
      pickPdf: () async => pickedPdf,
      // 경로 길이만큼의 바이트로, 어느 경로를 읽었는지 알 수 있게 합니다.
      readFile: (path) async => Uint8List(path.length),
    );
  });

  group('DeviceDocumentPicker', () {
    test('카메라로 찍으면 쪽 순서대로 원래 확장자를 살려 파일로 담는다', () async {
      final document = await picker.pick(UploadSource.camera);

      expect(document?.source, UploadSource.camera);
      expect(document?.pageCount, 2);
      expect(document?.files.map((file) => file.fileName), [
        'scan-1.jpg',
        'scan-2.png',
      ]);
      expect(document?.files.first.bytes.length, '/cache/page-a.JPG'.length);
      expect(document?.preview, isNull);
    });

    test('카메라로 찍으면 갤러리가 아닌 카메라로 서버 한도만큼 찍게 한다', () async {
      await picker.pick(UploadSource.camera);

      expect(scanCalls, [(false, DeviceDocumentPicker.maxPages)]);
    });

    test('앨범에서 고르면 스캐너의 갤러리 고르기를 연다', () async {
      final document = await picker.pick(UploadSource.album);

      expect(scanCalls, [(true, DeviceDocumentPicker.maxPages)]);
      expect(document?.source, UploadSource.album);
    });

    test('확장자가 없는 사진이면 jpg로 이름 붙인다', () async {
      scannedPaths = ['/cache/page'];

      final document = await picker.pick(UploadSource.camera);

      expect(document?.files.single.fileName, 'scan-1.jpg');
    });

    test('스캐너를 취소하면 null을 돌려준다', () async {
      scannedPaths = null;

      expect(await picker.pick(UploadSource.camera), isNull);
    });

    test('한 장도 찍지 않고 닫으면 null을 돌려준다', () async {
      scannedPaths = [];

      expect(await picker.pick(UploadSource.camera), isNull);
    });

    test('PDF를 고르면 파일 하나를 담고 쪽수는 모르는 채로 둔다', () async {
      final document = await picker.pick(UploadSource.pdf);

      expect(document?.isPdf, isTrue);
      expect(document?.fileName, '임대차계약서.pdf');
      expect(document?.files.single.fileName, '임대차계약서.pdf');
      expect(document?.pageCount, isNull);
      expect(scanCalls, isEmpty);
    });

    test('PDF 고르기를 취소하면 null을 돌려준다', () async {
      pickedPdf = null;

      expect(await picker.pick(UploadSource.pdf), isNull);
    });

    test('카메라 권한이 꺼져 있으면 CameraPermissionDeniedException을 그대로 던진다', () async {
      picker = DeviceDocumentPicker(
        scan: ({required fromGallery, required maxPages}) async =>
            throw const CameraPermissionDeniedException(),
      );

      await expectLater(
        picker.pick(UploadSource.camera),
        throwsA(isA<CameraPermissionDeniedException>()),
      );
    });
  });
}
