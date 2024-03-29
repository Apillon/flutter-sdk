// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:apillon_flutter/modules/storage/storage.dart';
import 'package:apillon_flutter/types/storage.dart';
import 'helpers/helper.dart';

void main() {
  late Storage storage;
  late String bucketUuid;
  late String lastFileUuid;
  // For get and delete tests
  const directoryUuid = '6c9c6ab1-801d-4915-a63e-120eed21fee0';

  setUpAll(() async {
    storage = Storage(getConfig());
    bucketUuid = getBucketUUID();
  });

  group('Storage tests', () {
    test('List buckets', () async {
      final response = await storage.listBuckets(null);
      expect(response.items.length, greaterThan(0));
      for (var item in response.items) {
        bucketUuid = item.uuid;
        expect(item.name, isNotNull);
      }
    });

    test('Get bucket', () async {
      final bucket = await storage.bucket(bucketUuid).get();
      expect(bucket.uuid, equals(bucketUuid));
      expect(bucket.name, isNotNull);
      expect(bucket.size, greaterThan(-1));
    });

    test('get bucket content', () async {
      final response = await storage.bucket(bucketUuid).listObjects(null);
      final items = response.items;
      for (final item in items) {
        if (item.type == StorageContentType.DIRECTORY) {
          await item.get();
        }
        print('${item.type}: ${item.name}');
      }
      expect(items.length, greaterThan(-1));
      for (var item in items) {
        expect(item.name, isNotNull);
      }
    });

    test('get bucket files', () async {
      final response = await storage.bucket(bucketUuid).listFiles(null);
      final items = response.items;
      for (final item in items) {
        print('${item.type}: ${item.name}');
        lastFileUuid = item.uuid;
      }
      expect(items.length, greaterThan(-1));
      for (var item in items) {
        expect(item.name, isNotNull);
      }
    });

    test('get bucket directory content', () async {
      final response = await storage.bucket(bucketUuid).listObjects(
          IStorageBucketContentRequest(directoryUuid: directoryUuid));
      final items = response.items;
      for (final item in items) {
        if (item.type == StorageContentType.DIRECTORY) {
          await item.get();
        }
        print('${item.type}: ${item.name}');
      }
      for (var item in items) {
        expect(item.name, isNotNull);
      }
    });

    test('get file details', () async {
      final file = await storage.bucket(bucketUuid).file(lastFileUuid).get();
      expect(file.name, isNotNull);
    });

    test('upload files from folder', () async {
      final uploadDir = path.join(
          path.dirname(Platform.script.toFilePath()), 'test/helpers/website/');

      print('File upload started');
      final files =
          await storage.bucket(bucketUuid).uploadFromFolder(uploadDir, null);
      print('File upload complete');

      expect(files.every((f) => f.fileUuid != null), isTrue);
    });

    test('upload files from buffer', () async {
      final css = File(path.join(path.dirname(Platform.script.toFilePath()),
              'test/helpers/website/style.css'))
          .readAsBytesSync();
      print('File upload started');
      await storage.bucket(bucketUuid).uploadFiles(
          [
            FileMetadata(
                fileName: 'style.css',
                contentType: 'text/css',
                path: null,
                content: css),
          ],
          IFileUploadRequest(
              wrapWithDirectory: true, directoryPath: 'main/subdir'));
      print('File upload complete');
    });
  });
}
