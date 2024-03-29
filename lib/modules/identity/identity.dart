import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:eth_sig_util/model/typed_data.dart';
import 'package:eth_sig_util/util/bytes.dart';

import '../../libs/apillon-api.dart';
import '../../libs/apillon.dart';
import '../../types/identity.dart';

class Identity extends ApillonModule {
  /// Base API url for identity.
  String apiPrefix = '/wallet-identity';

  Identity(super.config);

  /// Get a wallet's on-chain identity data, including Subsocial and Polkadot Identity data
  /// @param {string} walletAddress - Wallet address to retreive data for
  /// @returns Identity data fetched from Polkadot Identity and Subsocial
  Future<WalletIdentityData> getWalletIdentity(String walletAddress) async {
    return await ApillonApi.get<WalletIdentityData>(
        '$apiPrefix?address=$walletAddress',
        mapper: WalletIdentityData.fromJson);
  }

  /// Generate a message presented to the user when requested to sign using their wallet
  /// @param {string} [customText='Please sign this message']
  /// @returns Generated message and timestamp
  Map<String, dynamic> generateSigningMessage(
      [String customText = 'Please sign this message']) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final message = '$customText\n$timestamp';
    return {'message': message, 'timestamp': timestamp};
  }

  /// Check if a signed message from an EVM wallet address is valid
  /// @param {IValidateWalletSignature} data - The data used to validate the EVM signature
  /// @returns {VerifySignedMessageResult}
  VerifySignedMessageResult validateEvmWalletSignature(
      IValidateEvmWalletSignature data) {
    final messageParts = data.message.split('\n');
    final messageTimestamp = messageParts.last;

    // Check if the timestamp is within the valid time range (default 10 minutes)
    if (data.timestamp != null &&
        messageTimestamp != data.timestamp.toString()) {
      throw Exception('Message does not contain a valid timestamp');
    }

    final isValidTimestamp = data.timestamp != null
        ? DateTime.now().millisecondsSinceEpoch - data.timestamp! <=
            (data.signatureValidityMinutes ?? 10) * 60000
        : true;

    // Convert message to typed message
    final List<Map<String, dynamic>> rawTypedData = [
      {"type": "string", "name": "message", "value": data.message}
    ];
    final typedData =
        rawTypedData.map((e) => EIP712TypedData.fromJson(e)).toList();

    // Recover public Key from signature
    final recovered = TypedDataUtil.recoverPublicKey(
        typedData, data.signature, TypedDataVersion.V1);

    // Get address from public key
    final address = bufferToHex(SignatureUtil.publicKeyToAddress(recovered!));

    final isValidAddress = data.walletAddress != null
        ? address.toLowerCase() == data.walletAddress?.toLowerCase()
        : true;

    return VerifySignedMessageResult(
        isValid: isValidTimestamp && isValidAddress, address: address);
  }
}
