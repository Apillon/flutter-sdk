import 'package:apillon_flutter/libs/apillon-api.dart';
import 'package:apillon_flutter/libs/apillon.dart';
import 'package:apillon_flutter/libs/common.dart';
import 'package:apillon_flutter/types/apillon.dart';
import 'package:apillon_flutter/modules/storage/storage_bucket.dart';

class Storage extends ApillonModule {
  /// API url for storage.
  String apiPrefix = '/storage/buckets';

  Storage(super.config);

  /// Lists all buckets.
  /// @param {ICollectionFilters} params Filter for listing collections.
  /// @returns Array of StorageBucket objects.
  Future<IApillonList<StorageBucket>> listBuckets(
      IApillonPagination? params) async {
    final url = constructUrlWithQueryParams(apiPrefix, params?.toJson());
    final data =
        await ApillonApi.get<IApillonList>(url, mapper: IApillonList.fromJson);

    return IApillonList<StorageBucket>(
        total: data.total,
        items: data.items
            .map<StorageBucket>(
                (bucket) => StorageBucket(bucket["bucketUuid"], data: bucket))
            .toList());
  }

  /// @param uuid Unique bucket identifier.
  /// @returns An instance of StorageBucket.
  StorageBucket bucket(String uuid) {
    return StorageBucket(uuid);
  }
}
