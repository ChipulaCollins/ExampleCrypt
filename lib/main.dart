import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:untitled/Login/login.dart';
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
      home: LoginPage(),
      routes: {
        '/route1': (context) => RouteScreen(routeName: 'Route 1'),
        '/route2': (context) => RouteScreen(routeName: 'Route 2'),
        '/route3': (context) => RouteScreen(routeName: 'Route 3'),
        '/route4': (context) => RouteScreen(routeName: 'Route 4'),
        '/route5': (context) => Profile (context: 'Route 5'),
      },
    );
  }
}

class MainScreen extends StatelessWidget {
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
                Navigator.pushNamed(context, '/route1');
              },
              child: Text('Document Upload'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/route2');
              },
              child: Text('Document Details'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/route3');
              },
              child: Text('Audit Trail'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/route4');
              },
              child: Text('Verification'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/route5');
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