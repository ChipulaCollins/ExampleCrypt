import 'dart:math'; //used for the random number generator
import 'package:http/http.dart'; //You can also import the browser version
import 'package:web3dart/web3dart.dart';

import 'RPC.dart'; // Assuming you have an RPC.dart file with apiUrl and httpClient

Future<void> sendEthTransaction(String apiUrl, Client httpClient) async { // Make the function async and return a Future
  try {
    final ethClient = Web3Client(apiUrl, httpClient);

    final credentials = EthPrivateKey.fromHex("0xfd4fa61d75f823bab6b08b56e2a56a2c1241e6b9920b3e679d2d9f3346d0a74a"); // Replace with your private key

    final tx = Transaction(
      to: EthereumAddress.fromHex('0x7d040b8940e38a65250925e1d155a0aed78e4b68065ace1b1e9dc3e112e06d21'), // Replace with the recipient address
      gasPrice: EtherAmount.inWei(BigInt.one),
      maxGas: 100000,
      value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1), // Use correct assignment
    );

    //Example of sending a Transaction.
    final txHash = await ethClient.sendTransaction(credentials, tx, chainId: 5777); //5777 is the network id. //chainId is important for some networks

    print('Transaction hash: $txHash');

    ethClient.dispose(); //Close the client when you are done.

  } catch (e) {
    print('Error sending transaction: $e');
  }
}

// Example usage:
// sendEthTransaction();