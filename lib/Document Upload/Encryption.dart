/*import 'encr.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import "package:flutter/foundation.dart";
import 'package:flutter/services.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:path_provider/path_provider.dart';


class HashResultScreen extends StatefulWidget {
  final String hash;
  final File? selectedFile;

  const HashResultScreen({super.key, required this.hash, required this.selectedFile});

  @override
  _HashResultScreenState createState() => _HashResultScreenState();
}

class _HashResultScreenState extends State<HashResultScreen> {
  String? _privateKeyString;
  String? _publicKeyString;
  String? _encryptedData;
  bool _isGeneratingKeys = false;
  bool _isEncrypting = false;

  Future<void> _generateKeys() async {
    setState(() {
      _isGeneratingKeys = true;
      _privateKeyString = null;
      _publicKeyString = null;
    });
    try {
      final keyPair = await _generateRSAKeyPair();
      _privateKeyString = _encodePrivateKeyToPem(keyPair.privateKey as RSAPrivateKey);
      _publicKeyString = _encodePublicKeyToPem(keyPair.publicKey as RSAPublicKey);
    } catch (e) {
      print("Error generating keys: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating keys: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isGeneratingKeys = false;
      });
    }
  }

  Future<void> _encryptAndSave() async {
    if (_publicKeyString == null || widget.selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please generate keys and select a file first.')),
      );
      return;
    }
    setState(() {_isEncrypting = true; _encryptedData = null;});
    try{
      final publicKey = _parsePublicKeyFromPem(_publicKeyString!);
      final encryptedBytes = _encryptRSA(widget.hash, publicKey);
      _encryptedData = base64.encode(encryptedBytes);

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/encrypted_data.json');

      final originalFileBytes = await widget.selectedFile!.readAsBytes();
      final originalFileBase64 = base64.encode(originalFileBytes);

      final jsonData = {
        'encryptedData': _encryptedData,
        'publicKey': _publicKeyString,
        'originalDocument': originalFileBase64,
      };

      await file.writeAsString(jsonEncode(jsonData));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Encryption successful and data saved.')),
      );
    }catch (e){
      print("Error during encryption: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during encryption: ${e.toString()}')),
      );
    }finally{
      setState(() {_isEncrypting = false;});
    }
  }

  Future<AsymmetricKeyPair<PublicKey, PrivateKey>> _generateRSAKeyPair() async {
    final secureRandom = FortunaRandom();
    final random = crypto.SecureRandom('AES/CTR/AUTO-SEED-32');
    final seed = random.seed(KeyParameter(Uint8List(32)));
    secureRandom.seed(seed);
    final params = RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64);
    final keyGenerator = RSAKeyGenerator();
    keyGenerator.init(ParametersWithRandom(params, secureRandom));
    return keyGenerator.generateKeyPair();
  }

  String _encodePrivateKeyToPem(RSAPrivateKey privateKey) {
    final privateKeyDer = privateKey;
    final privateKeyPem = '-----BEGIN RSA PRIVATE KEY-----\n${base64.encode(privateKeyDer as List<int>)}\n-----END RSA PRIVATE KEY-----';
    return privateKeyPem;
  }

  String _encodePublicKeyToPem(RSAPublicKey publicKey) {
    final publicKeyDer = publicKey;
    final publicKeyPem = '-----BEGIN PUBLIC KEY-----\n${base64.encode(publicKeyDer as List<int>)}\n-----END PUBLIC KEY-----';
    return publicKeyPem;
  }

  RSAPublicKey _parsePublicKeyFromPem(String publicKeyPem) {
    final publicKeyDer = base64.decode(publicKeyPem.replaceAll('-----BEGIN PUBLIC KEY-----\n', '').replaceAll('\n-----END PUBLIC KEY-----', ''));
    return RSAPublicKey(publicKeyDer);
  }

  Uint8List _encryptRSA(String plainText, RSAPublicKey publicKey) {
    final plainTextBytes = Uint8List.fromList(utf8.encode(plainText));
    final encryptor = OAEPEncoding(crypto.Algorithm as AsymmetricBlockCipher);
    encryptor.init(PublicKeyParameter<RSAPublicKey>(publicKey) as bool);
    return encryptor.process(plainTextBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2027),
      appBar: AppBar(
        title: const Text('Hash Result', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2D3748),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: TextEditingController(text: widget.hash),
              readOnly: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(labelText: 'Hash', labelStyle: TextStyle(color: Colors.grey), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
            ),
            const SizedBox(height: 20),
            Stack(alignment: Alignment.center, children: [ElevatedButton(onPressed: _isGeneratingKeys ? null : _generateKeys, child: const Text('Generate Keys'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF64B5F6))), if(_isGeneratingKeys) const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 3,)]),
            const SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: _privateKeyString),
              readOnly: true,
              maxLines: 5,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(labelText: 'Private Key', labelStyle: TextStyle(color: Colors.grey), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: _publicKeyString),
              readOnly: true,
              maxLines: 5,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(labelText: 'Public Key', labelStyle: TextStyle(color: Colors.grey), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey))),
            ),
            const SizedBox(height: 20),
            Stack(alignment: Alignment.center, children: [ElevatedButton(onPressed: _isEncrypting ? null : _encryptAndSave, child: const Text('Encrypt and Save'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50))), if(_isEncrypting) const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 3,)]),
          ],
        ),
      ),
    );
  }
}*/