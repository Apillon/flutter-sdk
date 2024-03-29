import 'package:apillon_flutter/libs/apillon-api.dart';
import 'package:apillon_flutter/libs/apillon.dart';
import 'package:apillon_flutter/libs/common.dart';
import 'package:apillon_flutter/types/apillon.dart';
import 'package:apillon_flutter/types/nfts.dart';
import 'package:apillon_flutter/modules/nft/nft-collection.dart';

class Nft extends ApillonModule {
  /// API url for collections.
  String apiPrefix = '/nfts/collections';

  Nft(super.config);

  /// @param uuid Unique collection identifier.
  /// @returns An instance of NFT Collection
  NftCollection collection(String uuid) {
    return NftCollection(uuid, null);
  }

  /// Lists all nft collections available.
  /// @param {ICollectionFilters} params Filter for listing collections.
  /// @returns Array of NftCollection.
  Future<IApillonList<NftCollection>> listCollections(
      ICollectionFilters? params) async {
    final url = constructUrlWithQueryParams(apiPrefix, params?.toJson());
    final data =
        await ApillonApi.get<IApillonList>(url, mapper: IApillonList.fromJson);

    return IApillonList<NftCollection>(
        total: data.total,
        items: data.items
            .map<NftCollection>(
                (nft) => NftCollection(nft["collectionUuid"], nft))
            .toList());
  }

  /// Deploys a new NftCollection smart contract.
  /// @param data NFT collection data.
  /// @returns A NftCollection instance.
  Future<NftCollection> create(ICreateCollection data) async {
    // If not drop, set drop properties to default 0
    if (!data.drop) {
      data.dropStart = data.dropPrice = data.dropReserve = 0;
    }
    final response = await ApillonApi.post<ICollection>(
        apiPrefix, data.toJson(),
        mapper: ICollection.fromJson);

    return NftCollection(response.collectionUuid, response.toJson());
  }
}
