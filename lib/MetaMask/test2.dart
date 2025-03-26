import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import 'RPC.dart'; // Assuming you have RPC.dart with apiUrl and httpClient

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
    return EtherAmount.zero();
  }
}

class BalanceDisplayWidget2 extends StatefulWidget {
  @override
  _BalanceDisplayWidget2State createState() => _BalanceDisplayWidget2State();
}

class _BalanceDisplayWidget2State extends State<BalanceDisplayWidget2> {
  double? balanceInEth;
  final TextEditingController _privateKeyController = TextEditingController();
  final TextEditingController _apiUrlController = TextEditingController();

  Future<void> _fetchBalance() async {
    String privateKey = _privateKeyController.text;
    String apiUrl = _apiUrlController.text;

    try {
      EtherAmount balance = await getAccountBalance(privateKey, apiUrl);
      setState(() {
        balanceInEth = balance.getInEther.toDouble();
      });
    } catch (e) {
      print('Error fetching balance: $e');
      setState(() {
        balanceInEth = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balance Display'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _privateKeyController,
              decoration: InputDecoration(labelText: 'Private Key'),
            ),
            TextField(
              controller: _apiUrlController,
              decoration: InputDecoration(labelText: 'API URL'),
            ),
            SizedBox(height: 20),
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