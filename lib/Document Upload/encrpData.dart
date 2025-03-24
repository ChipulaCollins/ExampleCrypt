// rsa_screen_no_classes.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/src/platform_check/platform_check.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair(
    SecureRandom secureRandom,
    {int bitLength = 2048}) {
  final keyGen = RSAKeyGenerator();
  keyGen.init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
      secureRandom));
  final pair = keyGen.generateKeyPair();
  final myPublic = pair.publicKey as RSAPublicKey;
  final myPrivate = pair.privateKey as RSAPrivateKey;
  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
}

SecureRandom exampleSecureRandom() {
  final secureRandom = SecureRandom('Fortuna')
    ..seed(KeyParameter(Platform.instance.platformEntropySource().getBytes(32)));
  return secureRandom;
}

final pair = generateRSAkeyPair(exampleSecureRandom());
final public = pair.publicKey;
final private = pair.privateKey;

Uint8List rsaEncrypt(RSAPublicKey myPublic, Uint8List dataToEncrypt) {
  final encryptor = OAEPEncoding(RSAEngine())
    ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic));
  return _processInBlocks(encryptor, dataToEncrypt);
}

Uint8List rsaDecrypt(RSAPrivateKey myPrivate, Uint8List cipherText) {
  final decryptor = OAEPEncoding(RSAEngine())
    ..init(false, PrivateKeyParameter<RSAPrivateKey>(myPrivate));
  return _processInBlocks(decryptor, cipherText);
}

Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
  final numBlocks = input.length ~/ engine.inputBlockSize +
      ((input.length % engine.inputBlockSize != 0) ? 1 : 0);
  final output = Uint8List(numBlocks * engine.outputBlockSize);
  var inputOffset = 0;
  var outputOffset = 0;
  while (inputOffset < input.length) {
    final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
        ? engine.inputBlockSize
        : input.length - inputOffset;
    outputOffset += engine.processBlock(
        input, inputOffset, chunkSize, output, outputOffset);
    inputOffset += chunkSize;
  }
  return (output.length == outputOffset)
      ? output
      : output.sublist(0, outputOffset);
}

Widget buildRSAScreen(BuildContext context, String inputText,
    Function(String) onInputChanged, Function() onEncrypt, Function() onDecrypt,
    {Uint8List? encryptedData, Uint8List? decryptedData}) {
  return Scaffold(
    appBar: AppBar(title: Text('RSA Operations')),
    body: Column(
      children: <Widget>[
        TextField(
          decoration: InputDecoration(labelText: 'Input Text'),
          onChanged: onInputChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: onEncrypt,
              child: Text('Encrypt'),
            ),
            ElevatedButton(
              onPressed: onDecrypt,
              child: Text('Decrypt'),
            ),
          ],
        ),
        if (encryptedData != null)
          SelectableText('Encrypted: ${base64Encode(encryptedData)}'),
        if (decryptedData != null)
          SelectableText('Decrypted: ${utf8.decode(decryptedData)}'),
      ],
    ),
  );
}