import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class EtherTransferService {
  late Web3Client _client;
  late EthereumAddress _contractAddress;
  late DeployedContract _contract;
  late Credentials _credentials;

  EtherTransferService(String rpcUrl, String privateKey, String contractAddress) {
    _client = Web3Client(rpcUrl, Client());
    _credentials = EthPrivateKey.fromHex(privateKey);
    _contractAddress = EthereumAddress.fromHex(contractAddress);
  }

  Future<void> loadContract() async {
    String abi = await rootBundle.loadString("assets/ether_transfer_abi.json");
    _contract = DeployedContract(
      ContractAbi.fromJson(abi, "EtherTransfer"),
      _contractAddress,
    );
  }

  Future<String> sendEther(String receiver, BigInt amount) async {
    final function = _contract.function("sendEther");
    final txHash = await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [EthereumAddress.fromHex(receiver)],
        value: EtherAmount.inWei(amount),
      ),
      chainId: 1, // Use your network chain ID
    );

    return txHash;
  }
}
