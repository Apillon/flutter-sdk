// ignore_for_file: non_constant_identifier_names

import 'package:apillon_flutter/libs/apillon-api.dart';
import 'package:apillon_flutter/libs/apillon-logger.dart';
import 'package:apillon_flutter/libs/apillon.dart';
import 'package:apillon_flutter/types/storage.dart';

class File extends ApillonModel {
  /// Unique identifier of the file's bucket.
  String? bucketUuid;

  /// Unique identifier of the directory in which the file resides.
  String? directoryUuid;

  /// File name.
  String? name;

  /// File unique ipfs identifier.
  String? CID;

  /// File content identifier V1.
  String? CIDv1;

  /// File upload status.
  FileStatus? status;

  /// Type of content.
  StorageContentType? type = StorageContentType.FILE;

  /// Link on IPFS gateway.
  String? link;

  /// Full path to file.
  String? path;

  /// Constructor which should only be called via StorageBucket class.
  /// @param bucketUuid Unique identifier of the file's bucket.
  /// @param directoryUuid Unique identifier of the file's directory.
  /// @param fileUuid Unique identifier of the file.
  /// @param data Data to populate the directory with.
  File(this.bucketUuid, this.directoryUuid, String fileUuid,
      Map<String, dynamic>? data)
      : super(fileUuid) {
    apiPrefix = '/storage/buckets/$bucketUuid/files/$fileUuid';
    populate(data);
  }

  @override
  dynamic populate(dynamic data) {
    if (data != null) {
      name ??= data["name"];
      CID ??= data["CID"];
      CIDv1 ??= data["CIDv1"];
      status ??= FileStatus.getByValue(data["fileStatus"]);
      if (data["type"] != null) {
        type ??= StorageContentType.getByValue(data["type"]);
      }
      link ??= data["link"];
      path ??= data["path"];
      directoryUuid ??= data["directoryUuid"];
      return super.populate(data);
    }
  }

  factory File.fromJson(
      String? bucketUuid, String fileUuid, Map<String, dynamic> json) {
    return File(bucketUuid, json["directoryUuid"], fileUuid, json);
  }

  /// Gets file details.
  /// @returns File instance
  Future<File> get() async {
    final data = await ApillonApi.get(apiPrefix!);
    populate(data);
    return this;
  }

  /// Deletes a file from the bucket.
  Future<void> delete() async {
    await ApillonApi.delete(apiPrefix!);
    ApillonLogger.log('File deleted successfully');
  }
}
