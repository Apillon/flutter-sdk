import 'dart:convert';

import 'package:apillon_flutter/modules/identity/identity.dart';
import 'package:apillon_flutter/types/identity.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/helper.dart';

void main() {
  late Identity identity;

  setUpAll(() async {
    identity = Identity(getConfig());
  });

  group('EVM wallet signature tests', () {
    test('Validate EVM wallet signature', () async {
      const customMessage = 'Identity EVM SDK test';
      String message =
          identity.generateSigningMessage(customMessage)["message"];
      final firstPart = message.substring(0, customMessage.length);
      final secondPart = int.parse(message.substring(customMessage.length + 1));
      expect(firstPart, customMessage);
      expect(
          secondPart, lessThanOrEqualTo(DateTime.now().millisecondsSinceEpoch));

      final (walletAddress, signature) =
          await generateEvmWalletAndSignature(message);

      final result =
          identity.validateEvmWalletSignature(IValidateEvmWalletSignature(
        walletAddress: walletAddress,
        message: message,
        signature: signature,
      ));

      expect(result.isValid, true);
      expect(result.address.toLowerCase(), walletAddress.toLowerCase());
    });

    test('Validate EVM wallet signature with timestamp', () async {
      const customMessage = 'Identity EVM SDK test';
      String message =
          identity.generateSigningMessage(customMessage)["message"];
      final timestamp = int.parse(message.substring(customMessage.length + 1));
      expect(
          timestamp, lessThanOrEqualTo(DateTime.now().millisecondsSinceEpoch));

      final (walletAddress, signature) =
          await generateEvmWalletAndSignature(message);

      final result =
          identity.validateEvmWalletSignature(IValidateEvmWalletSignature(
        message: message,
        signature: signature,
        timestamp: timestamp,
        signatureValidityMinutes: 1,
      ));

      expect(result.isValid, true);
      expect(result.address.toLowerCase(), walletAddress.toLowerCase());
    });
    //
    test('Validate EVM wallet signature with invalid timestamp', () async {
      const customMessage = 'Identity EVM SDK test';
      String message =
          identity.generateSigningMessage(customMessage)["message"];

      final (walletAddress, signature) =
          await generateEvmWalletAndSignature(message);

      var dateTime= DateTime.now();
      final thirtyMinEarlier = dateTime.millisecondsSinceEpoch - 30 * 60000;
      expect(
          () => identity.validateEvmWalletSignature(IValidateEvmWalletSignature(
                walletAddress: walletAddress,
                message: message,
                signature: signature,
                timestamp: thirtyMinEarlier,
              )),
          throwsA(isA<Exception>()));
    });

    test('Get wallet identity profile', () async {
      final result1 = await identity.getWalletIdentity(
        '3rJriA6MiYj7oFXv5hgxvSuacenm8fk76Kb5TEEHcWWQVvii',
      );
      expect(result1.subsocial['content']['name'], 'dev only');
      expect(result1.subsocial['content']['summary'], isNotNull);
      expect(result1.subsocial['content']['about'], isNotNull);

      final result2 = await identity.getWalletIdentity(
        '5HqHQDGcHqSQELAyr5PbJNAcQJew4vsoNCf5kkSpXcUGMtCK',
      );
      expect(result2.polkadot['display']['Raw'],
          'Web 3.0 Technologies Foundation');
      expect(result2.polkadot['web']['Raw'], 'https://web3.foundation/');
    });
  });
}

Future<(String, String)> generateEvmWalletAndSignature(String message) async {
  final List<Map<String, dynamic>> rawTypedData = [
    {"type": "string", "name": "message", "value": message}
  ];
  final jsonData = jsonEncode(rawTypedData);
  const address = '0x29c76e6ad8f28bb1004902578fb108c507be341b';
  const privateKeyHex =
      '4af1bceebf7f3634ec3cff8a2c38e51178d5d4ce585c52d6043e5e2cc3418bb0';
  final signature = EthSigUtil.signTypedData(
      privateKey: privateKeyHex,
      jsonData: jsonData,
      version: TypedDataVersion.V1);

  return (address, signature);
}
