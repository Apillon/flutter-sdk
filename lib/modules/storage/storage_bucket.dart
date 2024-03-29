import 'package:apillon_flutter/libs/apillon.dart';
import 'package:apillon_flutter/types/storage.dart';

import 'package:apillon_flutter/libs/apillon-api.dart';
import 'package:apillon_flutter/libs/apillon-logger.dart';
import 'package:apillon_flutter/libs/common.dart';
import 'package:apillon_flutter/types/apillon.dart';
import 'package:apillon_flutter/util/file-utils.dart' as file_utils;
import 'package:apillon_flutter/modules/storage/directory.dart';
import './file.dart';
import 'package:apillon_flutter/modules/storage/ipns.dart';

class StorageBucket extends ApillonModel {
  /// Name of the bucket.
  String? name;

  /// Bucket description.
  String? description;

  /// Size of the bucket in bytes.
  int? size;

  /// Bucket content which are files and directories.
  List<ApillonModel> content = [];

  /// Constructor which should only be called via Storage class.
  /// @param uuid Unique identifier of the bucket.
  /// @param data Data to populate storage bucket with.
  StorageBucket(super.uuid, {Map<String, dynamic>? data}) {
    apiPrefix = '/storage/buckets/$uuid';
    populate(data);
  }

  @override
  populate(data) {
    if (data != null) {
      name = data?["name"];
      description = data?["description"];
      size = data?["size"];
      // content = data?["content"];  # is ignored in typescript
      super.populate(data);
    }
  }

  /// Gets bucket details.
  /// @returns Bucket instance
  Future<StorageBucket> get() async {
    final data = await ApillonApi.get(apiPrefix!);
    return StorageBucket(uuid, data: data);
  }

  /// Gets contents of a bucket.
  /// @returns A a list of File and Directory objects.
  Future<IApillonList<dynamic>> listObjects(
      IStorageBucketContentRequest? params) async {
    List<ApillonModel> content1 = [];
    final url =
        constructUrlWithQueryParams('$apiPrefix/content', params?.toJson());
    final data =
        await ApillonApi.get<IApillonList>(url, mapper: IApillonList.fromJson);

    for (final json in data.items) {
      if (json["type"] == StorageContentType.FILE.value) {
        content1.add(File(uuid, json["directoryUuid"], json["uuid"], json));
      } else if (json["type"] == StorageContentType.DIRECTORY.value) {
        // final dir = json as Directory;
        final directory = Directory(uuid, json["uuid"], data: json);
        content1.add(directory);
        content1.addAll(await directory.get());
      } else {
        throw Exception("Wrong type: $json");
      }
    }
    content = content1;
    return IApillonList(total: data.total, items: content);
  }

  /// Gets all files in a bucket.
  /// @param {?IBucketFilesRequest} [params] - query filter parameters
  /// @returns List of files in the bucket
  Future<IApillonList<File>> listFiles(IBucketFilesRequest? params) async {
    final url = constructUrlWithQueryParams(
        '/storage/buckets/$uuid/files', params?.toJson());
    final data =
        await ApillonApi.get<IApillonList>(url, mapper: IApillonList.fromJson);

    return IApillonList<File>(
      total: data.total,
      items: data.items
          .map((json) =>
              File(uuid, json["directoryUuid"], json["fileUuid"], json))
          .toList(),
    );
  }

  /// Uploads files inside a local folder via path.
  /// @param folderPath Path to the folder to upload.
  /// @param {IFileUploadRequest} params - Optional parameters to be used for uploading files
  /// @returns List of uploaded files with their properties
  Future<List<FileUploadResult>> uploadFromFolder(
      String folderPath, IFileUploadRequest? params) async {
    final temp =
        await file_utils.uploadFiles(folderPath, apiPrefix!, params, null);

    if (params?.awaitCid == false) {
      return temp.files;
    }

    return await resolveFileCIDs(temp.sessionUuid, temp.files.length);
  }

  /// Uploads files to the bucket.
  /// @param {FileMetadata[]} files - The files to be uploaded
  /// @param {IFileUploadRequest} params - Optional parameters to be used for uploading files
  Future<List<FileUploadResult>> uploadFiles(
      List<FileMetadata> files, IFileUploadRequest? params) async {
    var res = await file_utils.uploadFiles(null, apiPrefix!, params, files);

    if (params?.awaitCid == false) {
      return res.files;
    }
    return await resolveFileCIDs(res.sessionUuid, res.files.length);
  }

  /// Gets file instance.
  /// @param fileUuid UUID of the file.
  /// @returns File instance.
  File file(String fileUuid) {
    return File(uuid, null, fileUuid, null);
  }

  /// Gets a directory instance.
  /// @param directoryUuid UUID of the directory.
  /// @returns Directory instance.
  Directory directory(String directoryUuid) {
    return Directory(uuid, directoryUuid);
  }

  Future<List<FileUploadResult>> resolveFileCIDs(
      String sessionUuid, int limit) async {
    List<FileUploadResult> resolvedFiles = [];
    // Resolve CIDs for each file
    int retryTimes = 0;
    ApillonLogger.log('Resolving file CIDs...');
    while (resolvedFiles.isEmpty ||
        !resolvedFiles.every((f) => f.CID != null && f.CID != "")) {
      resolvedFiles = (await listFiles(
              IBucketFilesRequest(limit: limit, sessionUuid: sessionUuid)))
          .items
          .map((file) => FileUploadResult(
              fileName: file.name!,
              fileUuid: file.uuid,
              CID: file.CID,
              CIDv1: file.CIDv1))
          .toList();
      await Future.delayed(const Duration(milliseconds: 1000));
      if (++retryTimes >= 15) {
        ApillonLogger.log('Unable to resolve file CIDs', LogLevel.ERROR);
        return resolvedFiles;
      }
    }
    return resolvedFiles;
  }

  //#region IPNS methods

  /// Gets an IPNS record instance.
  /// @param ipnsUuid UUID of the IPNS record.
  /// @returns Ipns instance.
  Ipns ipns(String ipnsUuid) {
    return Ipns(uuid, ipnsUuid);
  }

  Future<IApillonList<Ipns>> listIpnsNames(IPNSListRequest? params) async {
    final url = constructUrlWithQueryParams(
        '/storage/buckets/$uuid/ipns', params?.toJson());
    final data =
        await ApillonApi.get<IApillonList>(url, mapper: IApillonList.fromJson);

    return IApillonList<Ipns>(
      total: data.total,
      items: data.items
          .map((ipns) => Ipns(uuid, ipns["ipnsUuid"], data: ipns))
          .toList(),
    );
  }

  /// Create a new IPNS record for this bucket
  /// @param {ICreateIpns} body
  /// @returns New IPNS instance
  Future<Ipns> createIpns(ICreateIpns body) async {
    final url = '/storage/buckets/$uuid/ipns';
    final ipns =
        await ApillonApi.post<Ipns>(url, body.toMap(), mapper: Ipns.fromMap);
    ipns.bucketUuid = uuid;
    return ipns;
  }
}
