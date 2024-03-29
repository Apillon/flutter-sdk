// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

import '../libs/apillon-api.dart';
import '../libs/apillon-logger.dart';
import '../types/apillon.dart';
import '../types/storage.dart';

List<FileMetadata> listFilesRecursive(String folderPath,
    {List<FileMetadata>? fileList, String relativePath = ''}) {
  fileList ??= [];
  final gitignorePath = File('$folderPath/.gitignore');
  final gitignorePatterns =
      gitignorePath.existsSync() ? gitignorePath.readAsLinesSync() : [];
  gitignorePatterns.add('.git'); // Always ignore .git folder.

  final files = Directory(folderPath).listSync();
  for (var file in files) {
    final fileName = file.uri.pathSegments.last;
    final fullPath = file.path;
    final relativeFilePath = path.join(relativePath, fileName);

    // Skip file if it matches .gitignore patterns
    if (gitignorePatterns
        .any((pattern) => RegExp(pattern).hasMatch(relativeFilePath))) {
      continue;
    }
    // var newList = List.from(fileList);
    if (FileSystemEntity.isDirectorySync(fullPath)) {
      listFilesRecursive(fullPath,
          fileList: fileList, relativePath: '$relativeFilePath/');
    } else {
      fileList.add(FileMetadata(
          content: [],
          fileName: fileName,
          path: relativePath,
          index: fullPath,
          contentType: null));
    }
    // fileList = newList;
  }
  return fileList..sort((a, b) => a.fileName.compareTo(b.fileName));
}

Future<void> uploadFilesToS3(
    List<FileMetadata> uploadLinks, List<FileMetadata> files) async {
  final s3Api = http.Client();

  await Future.wait(uploadLinks.map((link) async {
    final file = files.firstWhereOrNull((x) =>
        x.fileName == link.fileName &&
        (x.path == null || x.path == "" || x.path == link.path));
    if (file == null) {
      throw StateError("Can't find file ${link.path}${link.fileName}!");
    }
    final content = file.index == "" || file.index == null
        ? file.content
        : File(file.index!).readAsBytesSync();
    await s3Api.put(Uri.parse(link.url!), body: content);
    ApillonLogger.log('File uploaded: ${file.fileName}');
  }));

  s3Api.close();
}

class UploadFilesType {
  late String sessionUuid;
  List<FileMetadata> files = [];

  UploadFilesType(this.sessionUuid, this.files);
}

Future<UploadFilesType> uploadFiles(String? folderPath, String apiPrefix,
    IFileUploadRequest? params, List<FileMetadata>? files) async {
  if (folderPath != null) {
    ApillonLogger.log('Preparing to upload files from $folderPath...');
  } else if (files?.isNotEmpty == true) {
    ApillonLogger.log('Preparing to upload ${files?.length} files...');
  } else {
    throw ArgumentError('Invalid upload parameters received');
  }
  // If folderPath param passed, read files from local storage
  if (folderPath != null && (files?.isEmpty ?? true)) {
    try {
      files = listFilesRecursive(folderPath);
    } catch (err) {
      ApillonLogger.log(err.toString(), LogLevel.ERROR);
      rethrow;
    }
  }

  ApillonLogger.log('Total files to upload: ${files?.length}');

  // Split files into chunks for parallel uploading
  const fileChunkSize = 200;
  final sessionUuid = uuidv4();
  final uploadedFiles = <List<FileMetadata>>[];

  for (final fileGroup in chunkify(files!, fileChunkSize)) {
    var fileGroupJson = fileGroup.map((e) => e.toMap()).toList();
    final response = await ApillonApi.post<IFileUploadResponse>(
        '$apiPrefix/upload',
        {'files': fileGroupJson, 'sessionUuid': sessionUuid},
        mapper: IFileUploadResponse.fromMap);
    await uploadFilesToS3(
        response.files.map((e) => FileMetadata.fromMap(e)).toList(), fileGroup);
    uploadedFiles.add(files);
  }

  ApillonLogger.logWithTime('File upload complete.');

  ApillonLogger.log('Closing upload session...');
  await ApillonApi.post('$apiPrefix/upload/$sessionUuid/end', params?.toMap());
  ApillonLogger.logWithTime('Upload session ended.');

  return UploadFilesType(sessionUuid, uploadedFiles.expand((f) => f).toList());
}

List<List<FileMetadata>> chunkify(List<FileMetadata> files,
    [int chunkSize = 10]) {
  // Divide files into chunks for parallel processing and uploading
  final fileChunks = <List<FileMetadata>>[];
  for (var i = 0; i < files.length; i += chunkSize) {
    fileChunks.add(files.sublist(i, min(i + chunkSize, files.length)));
  }
  return fileChunks;
}

String uuidv4() {
  final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(255));

  // Set the version (4) and variant (8, 9, A, or B) bits
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant (8, 9, A, or B)

  // Convert bytes to hexadecimal and format the UUID
  final uuid = base64UrlEncode(bytes);

  return '${uuid.substring(0, 8)}-${uuid.substring(8, 12)}-${uuid.substring(12, 16)}-${uuid.substring(16, 20)}-${uuid.substring(20)}';
}
