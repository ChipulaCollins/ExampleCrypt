import 'dart:io';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/Document%20Upload/Result.dart';
import 'package:untitled/Login/login.dart';
import 'package:untitled/MetaMask/test2.dart';
import 'package:untitled/View/message/chat/chats.dart';
import 'package:untitled/Document Upload/Upload.dart';
import 'MetaMask/test.dart';
import 'home.dart';
import 'Profile/profile.dart';
//import 'package:flutter_web3/flutter_web3.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());


}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        '/upload': (context) => Upload(),
        '/details': (context) => ResultScreen(fileHash: '',),
        '/Signature': (context) => RouteScreen(routeName: 'Route 3'),
        '/verification': (context) => RouteScreen(routeName: 'Route 4'),
        '/Eth': (context) => BalanceDisplayWidget(),
        '/Eth2': (context) => BalanceDisplayWidget2(),
        '/messages': (context) => Chats(),
        '/profile': (context) => Profile(user: FirebaseAuth.instance.currentUser!),
        //'/metamask': (context) => MetaMaskProviderScreen(),
        //'/file_transfer': (context) => FileTransferScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final User user;

  const MainScreen({super.key, required this.user});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? additionalData;

  @override
  void initState() {
    super.initState();
    _fetchAdditionalData();
  }

  Future<void> _fetchAdditionalData() async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('Users/${widget.user.uid}');
    try {
      DatabaseEvent event = await userRef.once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        setState(() {
          additionalData = snapshot.value.toString();
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Satouce'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/upload');
              },
              child: Text('Document Upload'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/details');
              },
              child: Text('Hash Result'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/Signature');
              },
              child: Text('Signature'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/verification');
              },
              child: Text('Verification'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/Eth');
              },
              child: Text('Eth'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/Eth2');
              },
              child: Text('Eth2'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile(user: FirebaseAuth.instance.currentUser!)),
                );
              },
              child: Text('Profile'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/metamask');
              },
              child: Text('MetaMask Provider'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/file_transfer');
              },
              child: Text('File Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}

class RouteScreen extends StatelessWidget {
  final String routeName;

  RouteScreen({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(routeName),
      ),
      body: Center(
        child: Text('You are on $routeName'),
      ),
    );
  }
}

/*class MetaMaskProviderScreen extends StatefulWidget {
  const MetaMaskProviderScreen({super.key});

  @override
  MetaMaskProviderScreenState createState() => MetaMaskProviderScreenState();
}

class MetaMaskProviderScreenState extends State<MetaMaskProviderScreen> {
  // ... (MetaMask Provider code remains the same)
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

class PickerDemoApp extends StatefulWidget {
  const PickerDemoApp({Key? key}) : super(key: key);

  @override
  State<PickerDemoApp> createState() => _PickerDemoAppState();
}

class _PickerDemoAppState extends State<PickerDemoApp> {
  @override
  void initState() {
    super.initState();

    _prepareStore();
  }

  void _prepareStore() async {
    final Directory rootPath = await getTemporaryDirectory();

    // Create sample directory if not exists
    Directory sampleFolder = Directory('${rootPath.path}/Sample folder');
    if (!sampleFolder.existsSync()) {
      sampleFolder.createSync();
    }

    // Create sample file if not exists
    File sampleFile = File('${sampleFolder.path}/Sample.txt');
    if (!sampleFile.existsSync()) {
      sampleFile.writeAsStringSync('FileSystem Picker sample file.');
    }
  }
*/