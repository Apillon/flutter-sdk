import 'package:flutter_test/flutter_test.dart';

import 'package:apillon_flutter/modules/nft/nft.dart';
import 'package:apillon_flutter/types/nfts.dart';
import 'helpers/helper.dart';

final nftData = ICreateCollection(
  chain1: EvmChain.moonbase,
  collectionType1: CollectionType.generic,
  name: 'SDK Test',
  description: 'Created from SDK tests',
  symbol: 'SDKT',
  royaltiesFees: 0,
  royaltiesAddress: '0x0000000000000000000000000000000000000000',
  baseUri: 'https://test.com/metadata/',
  baseExtension: '.json',
  maxSupply: 5,
  isRevokable: false,
  isSoulbound: false,
  drop: false,
);
final nftData1 = ICreateCollection(
    chain1: EvmChain.moonbase,
    collectionType1: CollectionType.generic,
    description: 'Created from SDK tests',
    symbol: 'SDKT',
    royaltiesFees: 0,
    royaltiesAddress: '0x0000000000000000000000000000000000000000',
    baseUri: 'https://test.com/metadata/',
    baseExtension: '.json',
    maxSupply: 5,
    isRevokable: false,
    isSoulbound: false,
    drop: false,
    name: 'SDK Test isAutoIncrement=false',
    isAutoIncrement: false);

void main() {
  late Nft nft;
  late String collectionUuid = "";
  late String receivingAddress;

  var createdCollectionUuid = "";

  setUp(() {
    nft = Nft(getConfig());
    collectionUuid = getCollectionUUID();
    receivingAddress = getMintAddress();
  });
  group('Nft tests', () {
    test('list nft collections', () async {
      final collections = (await nft.listCollections(null)).items;
      expect(collections.length, greaterThan(0));
      // No need for type check since collections array is type of List<NftCollection>
      // expect(collections[0], isInstanceOf<NftCollection>());
    });

    test('mints a new nft', () async {
      final collection = nft.collection(collectionUuid);
      final res = await collection
          .mint(IMintNftData(receivingAddress: receivingAddress, quantity: 1));
      expect(res.success, isTrue);
      expect(res.transactionHash, isNotNull);
    });

    test('creates a new collection', () async {
      final collection = await nft.create(nftData);
      expect(collection.uuid, isNotNull);
      expect(collection.contractAddress, isNotNull);
      expect(collection.symbol, 'SDKT');
      expect(collection.name, 'SDK Test');
      expect(collection.description, 'Created from SDK tests');
      expect(collection.isAutoIncrement, isTrue);

      createdCollectionUuid = collection.uuid;
    });

    test('get nft collection transactions', () async {
      final transactions =
          (await nft.collection(collectionUuid).listTransactions(null)).items;
      expect(transactions.length, greaterThan(0));
      expect(transactions[0].transactionHash, isNotNull);
    });

    test('get nft collection details', () async {
      final collection = await nft.collection(createdCollectionUuid).get();
      expect(collection.name, 'SDK Test');
    });

    test(
        'should fail nest minting for collection that is not nestable if collection populated',
        () async {
      final collection = await nft.collection(collectionUuid).get();
      expect(collection.nestMint('', 1, 1), throwsA(isA<Exception>()));
    });

    // TODO: unhandled error in api
    test('should fail nest minting', () async {
      final collection = nft.collection(collectionUuid);
      expect(() => collection.nestMint(collectionUuid, 1, 1), throwsException);
    });

    test(
        'should fail revoking for collection that is not revokable if collection populated',
        () async {
      final collection = await nft.collection(collectionUuid).get();
      expect(() => collection.burn('1'), throwsA(isA<Exception>()));
    });
  });

  group('NFT with custom IDs mint', () {
    test('creates a new collection', () async {
      final collection = await nft.create(nftData1);
      expect(collection.uuid, isNotNull);
      expect(collection.contractAddress, isNotNull);
      expect(collection.symbol, 'SDKT');
      expect(collection.name, 'SDK Test isAutoIncrement=false');
      expect(collection.description, 'Created from SDK tests');
      expect(collection.isAutoIncrement, isFalse);

      collectionUuid = collection.uuid;
    });

    test('mints new nfts with custom IDs', () async {
      final collection = nft.collection(collectionUuid);
      final res = await collection.mint(IMintNftData(
          receivingAddress: receivingAddress,
          quantity: 2,
          idsToMint: [10, 20]));
      expect(res.success, isTrue);
      expect(res.transactionHash, isNotNull);
    });
  });
}
