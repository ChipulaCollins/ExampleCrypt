import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

Future<EtherAmount> getAccountBalance(String privateKey, String apiUrl) async {
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
    return EtherAmount.zero();
  }
}

Future<void> main() async {
  String privateKey = "0xfd4fa61d75f823bab6b08b56e2a56a2c1241e6b9920b3e679d2d9f3346d0a74a";
  String apiUrl = "http://127.0.0.1:7545";

  try {
    EtherAmount balance = await getAccountBalance(privateKey, apiUrl);
    print("Balance: ${balance.getInEther} ETH"); // Corrected line
  } catch (error) {
    print(error);
  }
}
// Example of how you would call it from another dart file.
// Assuming you have the private key and apiUrl available in your other file.

// Future<void> main() async { //Remove main in a non main dart file.
//     String privateKey = "0x8a21cc85088c808d92b05654c551cdd456cec8b5670a7c0dcf6604907333fdfd";
//     String apiUrl = "http://127.0.0.1:7545";
//
//     EtherAmount balance = await getAccountBalance(privateKey, apiUrl);
//     print("Balance: ${balance.getValueInEther()} ETH");
// }