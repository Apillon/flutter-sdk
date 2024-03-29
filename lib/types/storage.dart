// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'apillon.dart';

enum StorageContentType {
  DIRECTORY(1),
  FILE(2);

  const StorageContentType(this.value);
  final num value;

  static StorageContentType getByValue(num i) {
    return StorageContentType.values.firstWhere((x) => x.value == i);
  }
}

enum FileStatus {
  UPLOAD_REQUEST_GENERATED(1),
  UPLOADED(2),
  AVAILABLE_ON_IPFS(3),
  AVAILABLE_ON_IPFS_AND_REPLICATED(4);

  const FileStatus(this.value);
  final num value;

  static FileStatus getByValue(num i) {
    return FileStatus.values.firstWhere((x) => x.value == i);
  }
}

class IStorageBucketContentRequest extends IApillonPagination {
  String? directoryUuid;

  /// Search files by upload session UUID
  bool? markedForDeletion;

  IStorageBucketContentRequest({
    this.directoryUuid,
    this.markedForDeletion,
    super.search,
    super.page,
    super.limit,
    super.orderBy,
    super.desc,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'search': search,
      'page': page,
      'limit': limit,
      'orderBy': orderBy,
      'desc': desc,
      'directoryUuid': directoryUuid,
      'markedForDeletion': markedForDeletion
    };
  }
}

class IBucketFilesRequest extends IApillonPagination {
  FileStatus? fileStatus;
  String? sessionUuid;

  IBucketFilesRequest({
    this.fileStatus,
    this.sessionUuid,
    super.search,
    super.page,
    super.limit,
    super.orderBy,
    super.desc,
  });
}

class FileUploadResult {
  String fileName;

  /// File [MIME type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types)
  String? contentType;

  /// Virtual file path. Empty for root. Must not contain fileName.
  /// The path field can be used to place file in virtual directories inside a bucket. If directories do not yet exist, they will be automatically generated.
  /// For example, an images/icons path creates images directory in a bucket and icons directory inside it. File will then be created in the icons directory.
  String? path;

  /// The file's UUID, obtained after uploadig
  String? fileUuid;

  /// The file's CID on IPFS
  String? CID;
  String? CIDv1;

  FileUploadResult(
      {required this.fileName,
      this.path,
      this.contentType,
      this.fileUuid,
      this.CID,
      this.CIDv1});
}

class FileMetadata extends FileUploadResult {
  List<int> content;
  String? index;
  String? url;

  FileMetadata(
      {required this.content,
      required super.fileName,
      super.path,
      super.contentType,
      super.fileUuid,
      super.CID,
      super.CIDv1,
      this.index,
      this.url});

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'fileName': fileName,
      'path': path,
      'contentType': contentType,
      'fileUuid': fileUuid,
      'CID': CID,
      'CIDv1': CIDv1,
    };
  }

  factory FileMetadata.fromMap(Map<String, dynamic> map) {
    return FileMetadata(
            content: map["content"] ?? [], fileName: map["fileName"])
        .populate(map);
  }

  dynamic populate(dynamic map) {
    if (map != null) {
      // content = map["content"];
      // fileName = map["fileName"];
      path ??= map["path"];
      contentType ??= map["contentType"];
      fileUuid ??= map["fileUuid"];
      CID ??= map["CID"];
      CIDv1 ??= map["CIDv1"];
      index ??= map["index"];
      url ??= map["url"];
    }
    return this;
  }
}

class IFileUploadRequest {
  /// Wrap uploaded files to IPFS directory.
  /// Files in session can be wrapped to CID on IPFS via wrapWithDirectory parameter. This means that the directory gets its own CID and its content cannot be modified afterwards.
  /// @docs [IPFS docs](https://dweb-primer.ipfs.io/files-on-ipfs/wrap-directories-around-content#explanation)
  bool? wrapWithDirectory;

  /// Path to wrapped directory inside bucket.
  /// Mandatory when `wrapWithDirectory` is true.
  /// @example `main-dir` --> Files get uploaded to a folder named `main-dir` in the bucket.
  /// @example `main-dir/sub-dir` --> Files get uploaded to a subfolder in the location `/main-dir/sub-dir`.
  String? directoryPath;

  /// If set to true, the upload action will wait until files receive a CID from IPFS before returning a result
  bool? awaitCid;

  IFileUploadRequest(
      {this.wrapWithDirectory, this.directoryPath, this.awaitCid});

  Map<String, dynamic> toMap() {
    return {
      'wrapWithDirectory': wrapWithDirectory,
      'directoryPath': directoryPath,
      'awaitCid': awaitCid
    };
  }
}

class IFileUploadResponse<T> {
  /// IPNS name, that is used to access ipns content on ipfs gateway
  List<T> files;

  /// IPFS value (CID), to which this ipns points
  String sessionUuid;

  IFileUploadResponse(this.files, this.sessionUuid);

  factory IFileUploadResponse.fromMap(Map<String, dynamic> map) {
    return IFileUploadResponse(map['files'], map['sessionUuid']);
  }
}

class IPNSListRequest extends IApillonPagination {
  String ipnsName;
  String ipnsValue;

  IPNSListRequest({
    required this.ipnsName,
    required this.ipnsValue,
    super.search,
    super.page,
    super.limit,
    super.orderBy,
    super.desc,
  });
}

class ICreateIpns {
  String name;
  String? description;

  /// CID to which this IPNS name will point.
  /// If this property is specified, API executes ipns publish which sets ipnsName and ipnsValue properties
  String? cid;

  ICreateIpns({required this.name, this.description, this.cid});

  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description, 'cid': cid};
  }
}
