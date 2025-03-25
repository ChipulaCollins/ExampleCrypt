import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import 'RPC.dart'; // Assuming you have RPC.dart with apiUrl and httpClient

// You can create Credentials from private keys
Credentials fromHex = EthPrivateKey.fromHex(
    "0xfd4fa61d75f823bab6b08b56e2a56a2c1241e6b9920b3e679d2d9f3346d0a74a");

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

class BalanceDisplayWidget extends StatefulWidget {
  @override
  _BalanceDisplayWidgetState createState() => _BalanceDisplayWidgetState();
}

class _BalanceDisplayWidgetState extends State<BalanceDisplayWidget> {
  double? balanceInEth;
  String privateKey =
      "0xfd4fa61d75f823bab6b08b56e2a56a2c1241e6b9920b3e679d2d9f3346d0a74a";
  String apiUrl = "http://127.0.0.1:7545"; // Corrected apiUrl

  Future<void> _fetchBalance() async {
    try {
      EtherAmount balance = await getAccountBalance(privateKey, apiUrl);
      setState(() {
        balanceInEth = balance.getInEther.toDouble(); // Corrected line
      });
    } catch (e) {
      print('Error fetching balance: $e');
      setState(() {
        balanceInEth = null; // or 0.0, or some error value
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balance Display'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _fetchBalance,
              child: Text('Get Balance'),
            ),
            SizedBox(height: 20),
            if (balanceInEth != null)
              Text(
                'Balance: ${balanceInEth!.toStringAsFixed(6)} ETH',
                style: TextStyle(fontSize: 20),
              )
            else if (balanceInEth == null)
              Text("Balance: Error getting balance")
            else
              Text('Balance: Loading...'),
          ],
        ),
      ),
    );
  }
}