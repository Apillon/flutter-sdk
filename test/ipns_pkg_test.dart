import 'package:apillon_flutter/modules/storage/storage.dart';
import 'package:apillon_flutter/types/storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/helper.dart';

void main() {
  late Storage storage;
  late String bucketUuid;
  late String newIpnsUuid;

  setUpAll(() async {
    storage = Storage(getConfig());
    bucketUuid = getBucketUUID();
  });

  group('IPNS tests for StorageBucket', () {
    test('List IPNS records in a bucket', () async {
      final response = await storage.bucket(bucketUuid).listIpnsNames(null);
      // No need for type check since response items array is type of List<Ipns>
      // expect(response.items, isA<List<Ipns>>());
      expect(response.items.length, greaterThanOrEqualTo(0));
    });

    test('Create a new IPNS record', () async {
      const name = 'Test IPNS';
      const description = 'This is a test description';
      const cid = 'QmUxtfFfWFguxSWUUy2FiBsGuH6Px4KYFxJqNYJRiDpemj';
      final ipns = await storage.bucket(bucketUuid).createIpns(
          ICreateIpns(name: name, description: description, cid: cid));
      expect(ipns, isNotNull);
      expect(ipns.name, equals(name));
      expect(ipns.description, equals(description));
      expect(ipns.ipnsValue, equals('/ipfs/$cid'));
      newIpnsUuid =
          ipns.uuid; // Save the new IPNS UUID for later use in other tests
    });

    test('Get a specific IPNS record', () async {
      final ipns = await storage.bucket(bucketUuid).ipns(newIpnsUuid).get();
      expect(ipns, isNotNull);
      expect(ipns.name, equals('Test IPNS'));
      expect(ipns.uuid, equals(newIpnsUuid));
    });

    test('Publish an IPNS record', () async {
      const cid = 'Qmakf2aN7wzt5u9H3RadGjfotu62JsDfBq8hHzGsV2LZFx';
      final ipns =
          await storage.bucket(bucketUuid).ipns(newIpnsUuid).publish(cid);
      expect(ipns, isNotNull);
      expect(ipns.ipnsValue, equals('/ipfs/$cid'));
      expect(ipns.uuid, equals(newIpnsUuid));
    });

    test('Delete an IPNS record', () async {
      final ipns = await storage.bucket(bucketUuid).ipns(newIpnsUuid).delete();
      expect(ipns, isNotNull);
      expect(ipns.name, equals('Test IPNS'));
      expect(ipns.uuid, equals(newIpnsUuid));
    });
  });
}
