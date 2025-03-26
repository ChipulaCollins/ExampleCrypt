import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pointycastle/export.dart'; // Import pointycastle
import 'package:untitled/Document%20Upload/sign.dart';
import 'ContDoc.dart';
import 'encrpData.dart';
import 'Upload.dart';
import 'package:basic_utils/basic_utils.dart'; // Import rsa_screen_no_classes.dart
import 'dart:convert';

class ResultScreen extends StatelessWidget {
  final String? fileHash;

  ResultScreen({super.key, required this.fileHash});

  @override
  Widget build(BuildContext context) {
    var decryptedData;
    var encryptedData;
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF333333),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SHA-256 Hash: ${fileHash ?? 'No hash calculated'}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    fileHash ?? 'No hash calculated',
                    style: TextStyle(
                      color: fileHash != null ? Colors.cyanAccent : Colors.grey,
                      fontSize: 14,
                      fontFamily: 'Courier New',
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.left,
                  )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 500)),
                  ElevatedButton(
                    onPressed: () {
                      if (public != null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Public Key'),
                            content: SelectableText(
                                CryptoUtils.encodeRSAPublicKeyToPem(public)),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Close'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: const Text('Show Public Key'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (private != null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Private Key'),
                            content: SelectableText(
                                CryptoUtils.encodeRSAPrivateKeyToPem(private)),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Close'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: const Text('Show Private Key'),
                  ),
                  if (encryptedData != null)
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Encrypted Data'),
                            content:
                                SelectableText(base64Encode(encryptedData!)),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Close'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Show Encrypted Data'),
                    ),
                  if (decryptedData != null)
                    ElevatedButton(
                      onPressed: () async {
                        DocumentVerificationService service =
                            DocumentVerificationService(
                          "https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID",
                          "YOUR_PRIVATE_KEY",
                          "YOUR_CONTRACT_ADDRESS",
                        );

                        await service.loadContract();

                        String digest =
                            "0xYourSha256Digest"; // Replace with real digest
                        Uint8List signature =
                            Uint8List.fromList([/* Your Signature Bytes */]);
                        String userAddress = "0xUserPublicAddress";

                        String txHash = await service.verifyDocument(
                            digest, signature, userAddress);
                        print("Transaction Hash: $txHash");
                      },
                      child: Text("Verify Document"),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Decrypted Data'),
                          content: SelectableText(utf8.decode(decryptedData!)),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Close'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Show Decrypted Data'),
                  ),
                ],
              ),
            ).animate().slideY(
                begin: 1, end: 0, duration: const Duration(milliseconds: 500)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (fileHash != null && private != null && public != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => buildSignatureScreen(
                        context,
                        private!,
                        public!,
                        fileHash!,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
