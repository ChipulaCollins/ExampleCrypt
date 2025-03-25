import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/export.dart';
import 'dart:convert';

Widget buildSignatureScreen(
    BuildContext context,
    RSAPrivateKey privateKey,
    RSAPublicKey publicKey,
    String digestString,
    ) {
  Uint8List? signature;
  bool verificationResult = false;

  Uint8List rsaSign(RSAPrivateKey privateKey, Uint8List dataToSign) {
    final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    final sig = signer.generateSignature(dataToSign);
    return sig.bytes;
  }

  bool rsaVerify(RSAPublicKey publicKey, Uint8List signedData, Uint8List signature) {
    final sig = RSASignature(signature);
    final verifier = RSASigner(SHA256Digest(), '0609608648016503040201');
    verifier.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));
    try {
      return verifier.verifySignature(signedData, sig);
    } on ArgumentError {
      return false;
    }
  }

  return Scaffold(
    appBar: AppBar(title: const Text('Signature Screen')),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Digest: $digestString'),
        ElevatedButton(
          onPressed: () {
            signature = rsaSign(
              privateKey,
              Uint8List.fromList(utf8.encode(digestString)),
            );
            // Rebuild the widget to reflect the new signature
            (context as Element).markNeedsBuild();
          },
          child: const Text('Sign Digest'),
        ),
        if (signature != null) ...[
          Text('Signature: ${base64Encode(signature!)}'),
          ElevatedButton(
            onPressed: () {
              verificationResult = rsaVerify(
                publicKey,
                Uint8List.fromList(utf8.encode(digestString)),
                signature!,
              );
              // Rebuild the widget to reflect the new verification result
              (context as Element).markNeedsBuild();
            },
            child: const Text('Verify Signature'),
          ),
          Text('Verification Result: ${verificationResult ? 'Valid' : 'Invalid'}'),
        ],
      ],
    ),
  );
}