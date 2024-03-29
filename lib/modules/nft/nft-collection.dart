// ignore_for_file: file_names
import 'package:apillon_flutter/libs/apillon-api.dart';
import 'package:apillon_flutter/libs/apillon-logger.dart';
import 'package:apillon_flutter/libs/apillon.dart';
import 'package:apillon_flutter/libs/common.dart';
import 'package:apillon_flutter/types/apillon.dart';
import 'package:apillon_flutter/types/nfts.dart';

class NftCollection extends ApillonModel {
  /// Collection symbol.
  String? symbol;

  /// Collection name
  String? name;

  /// collection description.
  String? description;

  /// Collection type. Defines the smart contract used.
  CollectionType? collectionType;

  /// Max amount of NFTs that can get minted in this collection. 0 represents unlimited.
  int? maxSupply;

  /// Base uri from which uri for each token is calculated from:
  /// Base uri + token id + base extension.
  String? baseUri;

  /// Base extension from which uri for each token is calculated from:
  /// Base uri + token id + base extension.
  String? baseExtension;

  /// If nft is transferable.
  bool? isSoulbound;

  /// If true, NFT token IDs are always sequential.
  /// If false, custom token IDs can be provided when minting.
  bool? isAutoIncrement;

  /// If collection owner can burn / destroy a NFT.
  bool? isRevokable;

  /// If this collection has drop (anyone can buy a nft directly from the smart contract) functionality enabled.
  bool? drop;

  /// Price per NFT if drop is active.
  int? dropPrice;

  /// UNIX timestamp of when general buying of NFTs start.
  int? dropStart;

  /// Amount of reserved NFTs that can't be bought by general public but can get minted by the collection owner.
  int? dropReserve;

  /// Percentage amount of royalties fees.
  int? royaltiesFees;

  /// Address to which royalties are paid.
  String? royaltiesAddress;

  /// Status of the collection. From not deployed etc.
  CollectionStatus? collectionStatus;

  /// Smart contract address (available after succesfull deploy).
  String? contractAddress;

  /// Transaction hash of contract deploy.
  String? transactionHash;

  /// Wallet address of deployer.
  String? deployerAddress;

  /// Chain on which the smart contract was deployed.
  EvmChain? chain;

  /// Constructor which should only be called via Nft class.
  /// @param uuid Unique identifier of the NFT collection.
  /// @param data Data to populate the collection with.
  NftCollection(String uuid, Map<String, dynamic>? data) : super(uuid) {
    apiPrefix = '/nfts/collections/$uuid';
    populate(data);
  }

  @override
  populate(dynamic data) {
    if (data != null) {
      symbol = data["symbol"];
      name = data["name"];
      description = data["description"];
      if (data["collectionType"] != null) {
        collectionType = CollectionType.getByValue(data["collectionType"]);
      }
      maxSupply = data["maxSupply"];
      baseUri = data["baseUri"];
      baseExtension = data["baseExtension"];
      isSoulbound = data["isSoulbound"];
      isAutoIncrement = data["isAutoIncrement"];
      isRevokable = data["isRevokable"];
      drop = data["drop"];
      dropPrice = data["dropPrice"];
      dropStart = data["dropStart"];
      dropReserve = data["dropReserve"];
      royaltiesFees = data["royaltiesFees"];
      royaltiesAddress = data["royaltiesAddress"];
      if (data["collectionStatus"] != null) {
        collectionStatus =
            CollectionStatus.getByValue(data["collectionStatus"]);
      }
      contractAddress = data["contractAddress"];
      transactionHash = data["transactionHash"];
      deployerAddress = data["deployerAddress"];
      if (data["chain"] != null) {
        chain = EvmChain.getByValue(data["chain"]);
      }
      super.populate(data);
      return this;
    }
  }

  /// Gets and populates collection information.
  /// @returns Collection instance.
  Future<NftCollection> get() async {
    final data = await ApillonApi.get<dynamic>(apiPrefix!);
    return populate(data);
  }

  /// @param {IMintNftData} params - NFT mint parameters
  /// @returns {INftActionResponse} - success status and transaction hash of the mint
  Future<INftActionResponse> mint(IMintNftData params) async {
    if (params.idsToMint?.isNotEmpty ?? false) {
      params.quantity = params.idsToMint?.length;
    }

    final data = await ApillonApi.post<INftActionResponse>(
        '$apiPrefix/mint', params.toJson(),
        mapper: INftActionResponse.fromJson);

    ApillonLogger.log(
      '${params.quantity} NFTs minted successfully to ${params.receivingAddress}',
    );

    return data;
  }

  /// Mints new nfts directly to an existing nft.
  /// @warn This method is only available for nestable collections.
  /// @param parentCollectionUuid UUID of the collection we want to nest mint to.
  /// @param parentNftId ID of the nft in the collection we want to nest mint to.
  /// @param quantity Amount of nfts we want to mint.
  /// @returns Call status.
  Future<INftActionResponse> nestMint(
      String parentCollectionUuid, int parentNftId, int quantity) async {
    if (collectionType != CollectionType.nestable) {
      throw Exception('Collection is not nestable.');
    }
    final data = await ApillonApi.post<INftActionResponse>(
      '$apiPrefix/nest-mint',
      {
        'parentCollectionUuid': parentCollectionUuid,
        'parentNftId': parentNftId,
        'quantity': quantity,
      },
    );

    ApillonLogger.log('NFT nest minted successfully on NFT $parentNftId');
    return data;
  }

  /// Burns a nft.
  /// @warn Can only burn NFTs if the collection is revokable.
  /// @param tokenId Token ID of the NFT we want to burn.
  /// @returns Status.
  Future<INftActionResponse> burn(String tokenId) async {
    if (isRevokable != null && !isRevokable!) {
      throw Exception('Collection is not revokable.');
    }
    final data = await ApillonApi.post<INftActionResponse>(
      '$apiPrefix/burn',
      {'tokenId': tokenId},
    );

    ApillonLogger.log('NFT $tokenId burned successfully');
    return data;
  }

  /// Transfers ownership of this collection.
  /// @warn Once ownership is transferred you cannot call mint methods anymore since you are the
  /// owner and you need to the smart contracts call directly on chain.
  /// @param address Address to which the ownership will be transferred.
  /// @returns Collection data.
  Future<NftCollection> transferOwnership(String address) async {
    final data = await ApillonApi.post<ICollection>(
      '$apiPrefix/transfer',
      {'address': address},
    );

    populate(data);

    ApillonLogger.log('NFT collection transferred successfully to $address');
    return this;
  }

  /// Gets list of transactions that occurred on this collection through Apillon.
  /// @param params Filters.
  /// @returns List of transactions.
  Future<IApillonList<ITransaction>> listTransactions(
      ITransactionFilters? params) async {
    final url = constructUrlWithQueryParams(
      '$apiPrefix/transactions',
      params?.toJson(),
    );

    final data =
        await ApillonApi.get<IApillonList>(url, mapper: IApillonList.fromJson);

    return IApillonList<ITransaction>(
      total: data.total,
      items: data.items.map((t) => ITransaction.fromJson(t)).toList(),
    );
  }
}
