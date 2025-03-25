import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

import '../MetaMask/RPC.dart'; // Import your balance fetching file

class Profile extends StatefulWidget {
  final User user;

  const Profile({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? userName;
  String? userAge;
  String? userProfilePic;
  String? userEmail;
  bool _isLoading = true;
  double? etherBalance;
  String privateKey =
      "0xfd4fa61d75f823bab6b08b56e2a56a2c1241e6b9920b3e679d2d9f3346d0a74a";
  String apiUrl = "http://127.0.0.1:7545";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchEtherBalance();
  }

  Future<void> _fetchUserData() async {
    DatabaseReference userRef =
    FirebaseDatabase.instance.ref().child('Users/${widget.user.uid}');

    try {
      DatabaseEvent event = await userRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          userName = userData['Name'];
          userAge = userData['Age']?.toString(); // Convert int to String
          userProfilePic = userData['Profile Pic'];
          userEmail = userData['Email'];
          _isLoading = false;
        });
        print("Profile Pic URL: $userProfilePic");
      } else {
        setState(() {
          _isLoading = false;
        });
        print('User data not found.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching data: $e");
    }
  }

  Future<void> _fetchEtherBalance() async {
    try {
      EtherAmount balance = await getAccountBalance(privateKey, apiUrl);
      setState(() {
        etherBalance = balance.getInEther.toDouble(); // Corrected line
      });
    } catch (e) {
      print('Error fetching Ether balance: $e');
      setState(() {
        etherBalance = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            flex: 2,
            child: _TopPortion(profilePicUrl: userProfilePic),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    userName ?? 'Name not found',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _WalletWidget(
                    balance: etherBalance ?? 0.0,
                    user: widget.user,
                    additionalData: 'Age: $userAge, Email: $userEmail',
                    name: userName,
                    age: userAge,
                    email: userEmail,
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletWidget extends StatelessWidget {
  final double balance;
  final User user;
  final String? additionalData;
  final String? name;
  final String? age;
  final String? email;

  const _WalletWidget({
    Key? key,
    required this.balance,
    required this.user,
    this.additionalData,
    this.name,
    this.age,
    this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (name != null) Text(name!),
          Text(user.email ?? 'Email not available'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.blue),
              const SizedBox(width: 8.0),
              Text(
                '${balance.toStringAsFixed(6)} ETH',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopPortion extends StatelessWidget {
  final String? profilePicUrl;

  const _TopPortion({Key? key, required this.profilePicUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xff977b56), Color(0xff006df1)]),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    image: profilePicUrl != null
                        ? DecorationImage(
                        fit: BoxFit.cover, image: NetworkImage(profilePicUrl!))
                        : const DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            'https://i.imgur.com/wG71ehD.png')),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}