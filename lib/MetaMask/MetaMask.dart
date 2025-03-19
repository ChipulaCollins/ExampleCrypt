import 'package:flutter/material.dart';
import 'package:flutter_web3/flutter_web3.dart';

class MetaMaskProviderScreen extends StatefulWidget {
  const MetaMaskProviderScreen({super.key});

  @override
  MetaMaskProviderScreenState createState() => MetaMaskProviderScreenState();
}

class MetaMaskProviderScreenState extends State<MetaMaskProviderScreen> {
  String _accountAddress = 'Not connected';
  String _networkName = 'Unknown network';
  bool _isConnected = false;
  String _errorMessage = '';

  Future<void> _connectWallet() async {
    try {
      if (Ethereum.isSupported) {
        final accounts = await ethereum!.requestAccount();
        if (accounts.isNotEmpty) {
          setState(() {
            _accountAddress = accounts.first;
            _isConnected = true;
          });
          await _getNetwork();
        } else {
          setState(() {
            _errorMessage = 'No accounts found in MetaMask.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'MetaMask is not installed or supported.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect: $e';
      });
    }
  }

  Future<void> _getNetwork() async {
    try {
      final chainId = await ethereum!.getChainId();
      String networkName;
      switch (chainId) {
        case 1:
          networkName = 'Ethereum Mainnet';
          break;
        case 3:
          networkName = 'Ropsten Testnet';
          break;
        case 4:
          networkName = 'Rinkeby Testnet';
          break;
        case 5:
          networkName = 'Goerli Testnet';
          break;
        case 42:
          networkName = 'Kovan Testnet';
          break;
        case 1337:
          networkName = 'Ganache/Localhost';
          break;
        default:
          networkName = 'Unknown Network (Chain ID: $chainId)';
      }
      setState(() {
        _networkName = networkName;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get network: $e';
      });
    }
  }

  Future<void> _disconnectWallet() async {
    setState(() {
      _accountAddress = 'Not connected';
      _networkName = 'Unknown network';
      _isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MetaMask Provider'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Account: $_accountAddress'),
            Text('Network: $_networkName'),
            if (_errorMessage.isNotEmpty)
              Text(
                'Error: $_errorMessage',
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            if (!_isConnected)
              ElevatedButton(
                onPressed: _connectWallet,
                child: const Text('Connect MetaMask'),
              )
            else
              ElevatedButton(
                onPressed: _disconnectWallet,
                child: const Text('Disconnect MetaMask'),
              ),
          ],
        ),
      ),
    );
  }
}