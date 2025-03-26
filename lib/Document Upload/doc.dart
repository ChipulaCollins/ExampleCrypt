import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class DocumentVerificationService {
  late Web3Client _client;
  late EthereumAddress _contractAddress;
  late DeployedContract _contract;
  late Credentials _credentials;

  DocumentVerificationService(String rpcUrl, String privateKey, String contractAddress) {
    _client = Web3Client(rpcUrl, Client());
    _credentials = EthPrivateKey.fromHex(privateKey);
    _contractAddress = EthereumAddress.fromHex(contractAddress);
  }

  Future<void> loadContract() async {
    String abi = await rootBundle.loadString("lib/Document Upload/JSONs/DocumentVerifier.json");
    _contract = DeployedContract(
      ContractAbi.fromJson(abi, "DocumentVerifier"),
      _contractAddress,
    );
  }

  Future<String> verifyDocument(String digest, Uint8List signature, String userAddress) async {
    final function = _contract.function("verifySignature");

    final txHash = await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [
          BigInt.parse(digest), // SHA-256 digest in bytes
          signature,            // Signature in bytes
          EthereumAddress.fromHex(userAddress),
        ],
      ),
      chainId: 1, // Change based on your network
    );

    return txHash;
  }
}
