// ignore_for_file: non_constant_identifier_names
import 'package:apillon_flutter/libs/apillon-api.dart';
import 'package:apillon_flutter/libs/apillon-logger.dart';
import 'package:apillon_flutter/libs/apillon.dart';
import 'package:apillon_flutter/libs/common.dart';
import 'package:apillon_flutter/types/storage.dart';
import 'package:apillon_flutter/modules/storage/file.dart';
import 'package:apillon_flutter/types/apillon.dart';

class Directory extends ApillonModel {
  /// Unique identifier of the bucket.
  String? bucketUuid;

  /// Directory name.
  String? name;

  /// Directory unique ipfs identifier.
  String? CID;

  /// Id of the directory in which the file resides.
  String? parentDirectoryUuid;

  /// Type of content.
  StorageContentType type = StorageContentType.DIRECTORY;

  /// Link on IPFS gateway.
  String? link;
  List<ApillonModel> content = [];

  /// Constructor which should only be called via StorageBucket class.
  /// @param bucketUuid Unique identifier of the directory's bucket.
  /// @param directoryUuid Unique identifier of the directory.
  /// @param data Data to populate the directory with.
  Directory(
    this.bucketUuid,
    super.directoryUuid, {
    Map<String, dynamic>? data,
  }) {
    bucketUuid = bucketUuid;
    apiPrefix = '/storage/buckets/$bucketUuid';
    populate(data);
  }

  @override
  populate(dynamic data) {
    if (data != null) {
      name = data["name"];
      CID = data["CID"];
      parentDirectoryUuid = data["parentDirectoryUuid"];
      if (data["type"] != null) {
        type = StorageContentType.getByValue(data["type"]);
      }
      link = data["link"];
      super.populate(data);
      // done excludedKeys = ['content']; in typescript
    }
  }

  /// Gets contents of a directory.
  /// @returns Directory data and content (files and subfolders)
  Future<List<ApillonModel>> get({IStorageBucketContentRequest? params}) async {
    content = [];
    params ??= IStorageBucketContentRequest();
    params.directoryUuid = uuid;
    final url =
        constructUrlWithQueryParams('$apiPrefix/content', params.toJson());
    final data = await ApillonApi.get<IApillonList<dynamic>>(url,
        mapper: IApillonList.fromJson);

    for (final json in data.items) {
      if (json["type"] == StorageContentType.FILE.value) {
        content.add(File(uuid, json["directoryUuid"], json["uuid"], json));
      } else {
        content.add(Directory(bucketUuid, json["uuid"], data: json));
      }
    }
    return content;
  }

  /// Deletes a directory from the bucket.
  Future<void> delete() async {
    await ApillonApi.delete('$apiPrefix/directories/$uuid');
    ApillonLogger.log('Directory deleted successfully');
  }
}
