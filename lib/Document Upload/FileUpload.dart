/*import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/random/src/platform_secure_random.dart';
import 'package:pointycastle/src/platform_check/platform_check.dart';
import 'package:pointycastle/src/utils.dart';

class FileHashScreen extends StatefulWidget {
  @override
  _FileHashScreenState createState() => _FileHashScreenState();
}

class _FileHashScreenState extends State<FileHashScreen> {
  File? _selectedFile;
  String? _fileHash;
  Uint8List? _fileBytes;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
      _hashFile();
    } else {
      // User canceled the picker
    }
  }

  Future<void> _hashFile() async {
    if (_selectedFile != null) {
      _fileBytes = await _selectedFile!.readAsBytes();
      final digest = sha256.convert(_fileBytes!);
      setState(() {
        _fileHash = digest.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Hash'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Pick File'),
            ),
            SizedBox(height: 20),
            if (_selectedFile != null)
              Text('Selected File: ${_selectedFile!.path}'),
            if (_fileHash != null) Text('File Hash: $_fileHash'),
            if(_fileBytes != null)
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => KeyGenScreen(fileBytes: _fileBytes!)));
              }, child: Text("Generate Keys"),)
          ],
        ),
      ),
    );
  }
}

class KeyGenScreen extends StatefulWidget {
  final Uint8List fileBytes;

  KeyGenScreen({required this.fileBytes});

  @override
  _KeyGenScreenState createState() => _KeyGenScreenState();
}

class _KeyGenScreenState extends State<KeyGenScreen> {
  String? _publicKeyString;
  String? _privateKeyString;

  @override
  void initState() {
    super.initState();
    _generateKeys();
  }

  Future<void> _generateKeys() async {
    final secureRandom = FortunaRandom();
    final seedSource = PlatformSecureRandom(); // Use PlatformSecureRandom
    final seeds = seedSource.seed(32);
    secureRandom.seed(new KeyParameter(seeds));

    final rsaParams = new RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 5);
    final params = new ParametersWithRandom(rsaParams, secureRandom);
    final keyGenerator = new RSAKeyGenerator();
    keyGenerator.init(params);

    final keyPair = keyGenerator.generateKeyPair();
    final publicKey = keyPair.publicKey as RSAPublicKey;
    final privateKey = keyPair.privateKey as RSAPrivateKey;

    setState(() {
      _publicKeyString = publicKey.modulus.toRadixString(16) + publicKey.exponent.toRadixString(16);
      _privateKeyString = privateKey.modulus.toRadixString(16) +
          privateKey.exponent.toRadixString(16) +
          privateKey.p!.toRadixString(16) +
          privateKey.q!.toRadixString(16);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Key Generation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_publicKeyString != null)
              Text('Public Key: $_publicKeyString'),
            if (_privateKeyString != null)
              Text('Private Key: $_privateKeyString'),
            ElevatedButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text("Go Back")),
          ],
        ),
      ),
    );
  }
}*/