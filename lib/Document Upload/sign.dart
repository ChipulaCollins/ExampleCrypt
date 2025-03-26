import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/export.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/main.dart'; // Import your main screen
import 'dart:convert'; // Import dart:convert for JSON encoding

Widget buildSignatureScreen(
    BuildContext context,
    RSAPrivateKey privateKey,
    RSAPublicKey publicKey,
    String digestString,
    ) {
  Uint8List? signature;
  bool verificationResult = false;
  String? savedSignature;

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

  Future<void> saveSignatureLocally(String signatureBase64) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/signature.txt');
    await file.writeAsString(signatureBase64);
  }

  Future<void> saveSignatureToPrefs(String signatureBase64) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedSignature', signatureBase64);
  }

  Future<String?> getSignatureFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('savedSignature');
  }

  Future<void> saveSignatureToJson(String signatureBase64, String digest) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/signature.json');

    final Map<String, dynamic> signatureData = {
      'digest': digest,
      'signature': signatureBase64,
    };

    final jsonString = jsonEncode(signatureData);
    await file.writeAsString(jsonString);
  }

  return Scaffold(
    appBar: AppBar(title: const Text('Signature Screen')),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Digest: $digestString'),
        ElevatedButton(
          onPressed: () async {
            signature = rsaSign(
              privateKey,
              Uint8List.fromList(utf8.encode(digestString)),
            );
            savedSignature = base64Encode(signature!);
            await saveSignatureLocally(savedSignature!);
            await saveSignatureToPrefs(savedSignature!);
            await saveSignatureToJson(savedSignature!, digestString); // Save to JSON
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
              (context as Element).markNeedsBuild();
            },
            child: const Text('Verify Signature'),

          ),
          Text('Verification Result: ${verificationResult ? 'Valid' : 'Invalid'}'),
        ],
        FutureBuilder<String?>(
          future: getSignatureFromPrefs(),
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.data != null) {
              return Text('Saved Signature (Prefs): ${snapshot.data}');
            } else {
              return const Text('No saved signature in prefs');
            }
          },
        ),
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyApp(), // Navigate to your main screen
                ),
              );
            },
            child: const Text('Home'),),
        if (savedSignature != null)
          Text('Saved Signature (local file): $savedSignature'),
      ],

    ),

  );

}