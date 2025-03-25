import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import 'RPC.dart'; // Assuming you have RPC.dart with apiUrl and httpClient

// You can create Credentials from private keys
Credentials fromHex = EthPrivateKey.fromHex(
    "0xfd4fa61d75f823bab6b08b56e2a56a2c1241e6b9920b3e679d2d9f3346d0a74a");

Future<void> Profile() async {
  String privateKey =
      "0xfd4fa61d75f823bab6b08b56e2a56a2c1241e6b9920b3e679d2d9f3346d0a74a";
  String apiUrl = "http://127.0.0.1:7545"; // Corrected apiUrl (lowercase http)

  try {
    EtherAmount balance = await getAccountBalance(privateKey, apiUrl);
    print("Balance: ${balance.getInEther} ETH"); // Corrected line
  } catch (e) {
    print("Error in Profile function: $e"); //Added error handling.
  }
}

Future<EtherAmount> getAccountBalance(
    String privateKey, String apiUrl) async {
  try {
    var httpClient = Client();
    var ethClient = Web3Client(apiUrl, httpClient);

    var credentials = EthPrivateKey.fromHex(privateKey);
    var address = credentials.address;

    EtherAmount balance = await ethClient.getBalance(address);

    httpClient.close();
    ethClient.dispose();

    return balance;
  } catch (e) {
    print('Error getting balance: $e');
    return EtherAmount.zero(); // Or handle the error as needed
  }
}

// In either way, the library can derive the public key and the address
// from a private key: