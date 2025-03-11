import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/Login/login.dart';
import 'package:untitled/View/message/chat/chats.dart';
import 'home.dart';
import 'Profile/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
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
      home: MainScreen(user: FirebaseAuth.instance.currentUser!),
      routes: {
        '/upload': (context) => RouteScreen(routeName: 'Route 1'),
        '/details': (context) => RouteScreen(routeName: 'Route 2'),
        '/audit': (context) => RouteScreen(routeName: 'Route 3'),
        '/verification': (context) => RouteScreen(routeName: 'Route 4'),
        '/messages': (context) => Chats (),
        '/profile': (context) => Profile(user: FirebaseAuth.instance.currentUser!),
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
    _fetchAdditionalData(); //fetch additional data when the mainScreen is loaded.
  }

  Future<void> _fetchAdditionalData() async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('Users/${widget.user.uid}'); //example of realtime database usage.

    try{
      DatabaseEvent event = await userRef.once();
      DataSnapshot snapshot = event.snapshot;
      if(snapshot.value != null){
        setState(() {
          additionalData = snapshot.value.toString();
        });
      }
    } catch(e){
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
            /*Text('Logged in as: ${widget.user.email}'),
            if(additionalData != null)
              Text('Additional Data: $additionalData'),*/

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
              child: Text('Document Details'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/audit');
              },
              child: Text('Audit Trail'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/verification');
              },
              child: Text('Verification'),
            ),
            SizedBox(height: 16),
            /*ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/messages');
              },
              child: Text('Messages'),
            ),
            SizedBox(height: 16),*/
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile(user: FirebaseAuth.instance.currentUser!)),
                );
              },
              child: Text('Profile'),
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