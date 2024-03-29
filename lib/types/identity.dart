class WalletIdentityData {
  /// @docs [Polkadot Identity Info DTO](https://github.com/polkadot-js/api/blob/c73c26d13324a6211a7cf4e401aa032c87f7aa10/packages/types-augment/src/lookup/types-substrate.ts#L3331)
  final dynamic polkadot;

  /// @docs [Subsocial SpaceData DTO](https://docs.subsocial.network/js-docs/js-sdk/modules/dto.html#spacedata)
  final dynamic subsocial;

  WalletIdentityData({required this.polkadot, required this.subsocial});

  factory WalletIdentityData.fromJson(Map<String, dynamic> json) {
    return WalletIdentityData(
        polkadot: json['polkadot'], subsocial: json['subsocial']);
  }
}

/// Represents the parameters for checking validity of a signed message from an EVM wallet address.
class IValidateEvmWalletSignature extends IValidateSignatureTimestamp {
  /// The message that has been signed by the wallet.
  final String message;

  /// The wallet's signature for the given message
  final String signature;

  /// (Optional) Wallet address parameter, used to check if address obtained from signature matches the parameter address
  final String? walletAddress;

  IValidateEvmWalletSignature({
    required this.message,
    required this.signature,
    this.walletAddress,
    super.timestamp,
    super.signatureValidityMinutes,
  });
}

/// Represents the parameters for checking validity of a signed message from a Polkadot wallet address.
class IValidatePolkadotWalletSignature extends IValidateSignatureTimestamp {
  // note string | Uint8Array types are allowed
  /// The message that has been signed by the wallet.
  final dynamic message;

  /// The wallet's signature for the given message
  final dynamic signature;

  /// Wallet address parameter, used to check if address obtained from signature matches the parameter address
  final dynamic walletAddress;

  IValidatePolkadotWalletSignature({
    required this.message,
    required this.signature,
    required this.walletAddress,
    super.timestamp,
    super.signatureValidityMinutes,
  });
}

class IValidateSignatureTimestamp {
  /// The timestamp when the message was generated, for added security (optional).
  ///
  /// If you are generating the message yourself and you wish to validate the timestamp,
  /// append `\n${timestamp}` to the end of the message with your own timestamp.
  final int? timestamp;

  /// For how many minutes the wallet signature is valid (default 10).
  final int? signatureValidityMinutes;

  IValidateSignatureTimestamp({
    this.timestamp,
    this.signatureValidityMinutes,
  });
}

/// Represents the result of checking the validity of a signed message.
class VerifySignedMessageResult {
  /// Indicates whether the message signature is valid.
  final bool isValid;

  /// The wallet address associated with the signature.
  final String address;

  VerifySignedMessageResult({
    required this.isValid,
    required this.address,
  });
}
