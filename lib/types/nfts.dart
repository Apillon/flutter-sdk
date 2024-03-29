import 'apillon.dart';

enum EvmChain {
  moonbeam(1284),
  moonbase(1287),
  astar(592);

  const EvmChain(this.value);

  final num value;

  static EvmChain getByValue(num i) {
    return EvmChain.values.firstWhere((x) => x.value == i);
  }
}

enum CollectionStatus {
  created(0),
  deployInitiated(1),
  deploying(2),
  deployed(3),
  transferred(4),
  failed(5);

  const CollectionStatus(this.value);

  final num value;

  static CollectionStatus getByValue(num i) {
    return CollectionStatus.values.firstWhere((x) => x.value == i);
  }
}

enum CollectionType {
  generic(1),
  nestable(2);

  const CollectionType(this.value);

  final num value;

  static CollectionType getByValue(num i) {
    return CollectionType.values.firstWhere((x) => x.value == i);
  }
}

enum TransactionStatus {
  pending(1),
  confirmed(2),
  failed(3),
  error(4);

  const TransactionStatus(this.value);

  final num value;

  static TransactionStatus getByValue(num i) {
    return TransactionStatus.values.firstWhere((x) => x.value == i);
  }
}

enum TransactionType {
  deployContract(1),
  transferContractOwnership(2),
  mintNFT(3),
  setCollectionBaseUri(4),
  burnNFT(5),
  nestMintNFT(6);

  const TransactionType(this.value);

  final num value;

  static TransactionType getByValue(num i) {
    return TransactionType.values.firstWhere((x) => x.value == i);
  }
}

class ICreateCollection {
  CollectionType? collectionType1;
  EvmChain? chain1;
  String name;
  String symbol;
  String? description;
  String baseUri;
  String baseExtension;
  int? maxSupply;
  bool isRevokable;
  bool isSoulbound;
  String royaltiesAddress;
  int royaltiesFees;
  bool drop;
  int? dropStart;
  int? dropPrice;
  int? dropReserve;
  bool? isAutoIncrement;

  ICreateCollection(
      {required this.name,
      required this.symbol,
      required this.baseUri,
      required this.baseExtension,
      required this.isRevokable,
      required this.isSoulbound,
      required this.royaltiesAddress,
      required this.royaltiesFees,
      required this.drop,
      this.maxSupply,
      this.description,
      this.collectionType1,
      this.chain1,
      this.isAutoIncrement});

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "symbol": symbol,
      "baseUri": baseUri,
      "baseExtension": baseExtension,
      "isRevokable": isRevokable,
      "isSoulbound": isSoulbound,
      "royaltiesAddress": royaltiesAddress,
      "royaltiesFees": royaltiesFees,
      "drop": drop,
      "maxSupply": maxSupply,
      "description": description,
      "collectionType": collectionType1?.value,
      "chain": chain1?.value,
      "isAutoIncrement": isAutoIncrement ?? true,
      "dropPrice": dropPrice,
      "dropStart": dropStart,
      "dropReserve":dropReserve,
    };
  }
}

class ICollection extends ICreateCollection {
  String collectionUuid;
  String contractAddress;
  String deployerAddress;
  String transactionHash;
  CollectionStatus collectionStatus;
  int collectionType;
  int chain;
  String updateTime;
  String createTime;

  ICollection(
      {required this.collectionUuid,
      required this.contractAddress,
      required this.deployerAddress,
      required this.transactionHash,
      required this.collectionStatus,
      required this.collectionType,
      required this.chain,
      required this.updateTime,
      required this.createTime,
      required super.name,
      required super.symbol,
      required super.baseUri,
      required super.baseExtension,
      required super.isRevokable,
      required super.isSoulbound,
      required super.royaltiesAddress,
      required super.royaltiesFees,
      required super.drop,
      super.maxSupply,
      super.description,
      super.isAutoIncrement}) {
    super.collectionType1 = CollectionType.getByValue(collectionType);
    super.chain1 = EvmChain.getByValue(chain);
  }

  factory ICollection.fromJson(Map<String, dynamic> json) {
    return ICollection(
        collectionUuid: json["collectionUuid"],
        contractAddress: json["contractAddress"],
        deployerAddress: json["deployerAddress"],
        transactionHash: json["transactionHash"],
        collectionStatus: CollectionStatus.getByValue(json["collectionStatus"]),
        collectionType: json["collectionType"],
        chain: json["chain"],
        updateTime: json["updateTime"],
        createTime: json["createTime"],
        name: json["name"],
        symbol: json["symbol"],
        baseUri: json["baseUri"],
        baseExtension: json["baseExtension"],
        isRevokable: json["isRevokable"],
        isSoulbound: json["isSoulbound"],
        royaltiesAddress: json["royaltiesAddress"],
        royaltiesFees: json["royaltiesFees"],
        drop: json["drop"],
        maxSupply: json["maxSupply"],
        description: json["description"],
        isAutoIncrement: json["isAutoIncrement"]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "collectionUuid":collectionUuid,
      "contractAddress":contractAddress,
      "deployerAddress":deployerAddress,
      "transactionHash":transactionHash,
      "collectionStatus": collectionStatus.value,
      "updateTime":updateTime,
      "createTime":createTime,
      "name": name,
      "symbol": symbol,
      "baseUri": baseUri,
      "baseExtension": baseExtension,
      "isRevokable": isRevokable,
      "isSoulbound": isSoulbound,
      "royaltiesAddress": royaltiesAddress,
      "royaltiesFees": royaltiesFees,
      "drop": drop,
      "maxSupply": maxSupply,
      "description": description,
      "collectionType": collectionType1?.value,
      "chain": chain1?.value,
      "isAutoIncrement": isAutoIncrement ?? true,
      "dropPrice": dropPrice,
      "dropStart": dropStart,
      "dropReserve":dropReserve,
    };
  }
}

class ITransaction {
  int chainId;
  TransactionType transactionType;
  TransactionStatus transactionStatus;
  String transactionHash;
  String updateTime;
  String createTime;

  ITransaction({
    required this.chainId,
    required this.transactionType,
    required this.transactionStatus,
    required this.transactionHash,
    required this.updateTime,
    required this.createTime,
  });

  factory ITransaction.fromJson(Map<String, dynamic> json) {
    return ITransaction(
      chainId: json['chainId'],
      transactionType: TransactionType.getByValue(json['transactionType']),
      transactionStatus:TransactionStatus.getByValue(json['transactionStatus']),
      transactionHash: json['transactionHash'],
      updateTime: json['updateTime'],
      createTime: json['createTime'],
    );
  }
}

class ICollectionFilters extends IApillonPagination {
  CollectionStatus? collectionStatus;

  ICollectionFilters({
    this.collectionStatus,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'search': search,
      'orderBy': orderBy,
      'desc': desc,
      'collectionStatus': collectionStatus,
    };
  }
}

class INftActionResponse {
  bool success;
  String transactionHash;

  INftActionResponse({
    required this.success,
    required this.transactionHash,
  });

  factory INftActionResponse.fromJson(Map<String, dynamic> json) {
    return INftActionResponse(
      success: json['success'],
      transactionHash: json['transactionHash'],
    );
  }
}

class ITransactionFilters extends IApillonPagination {
  TransactionStatus? transactionStatus;
  TransactionType? transactionType;

  ITransactionFilters({
    super.search,
    super.page,
    super.limit,
    super.orderBy,
    super.desc,
    this.transactionStatus,
    this.transactionType,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'search': search,
      'orderBy': orderBy,
      'desc': desc,
      'TransactionStatus': transactionStatus,
      'transactionType': transactionType,
    };
  }
}

class IMintNftData {
  /// Address to receive the minted NFT
  String receivingAddress;

  /// How many NFTs to mint to the receiver
  int? quantity;

  /// If collection is set as isAutoIncrement=false,
  /// use this parameter to define the custom minted NFT token IDS
  List<int>? idsToMint;

  IMintNftData({
    required this.receivingAddress,
    this.quantity,
    this.idsToMint,
  });

  Map<String, dynamic> toJson() {
    return {
      "receivingAddress" : receivingAddress,
      "quantity": quantity,
      "idsToMint": idsToMint
    };
  }
}
