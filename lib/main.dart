import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learn_firestore/screens/chat_screen.dart';
import 'package:learn_firestore/screens/home_screen.dart';
import 'package:learn_firestore/screens/login_screen.dart';
import 'package:learn_firestore/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? hasDataIn;

  Future<void> checkSharedPreferencesData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      if (prefs.containsKey('email') &&
          prefs.containsKey('userName') &&
          prefs.containsKey('uid')) {
        // Data exists, return the home page route
        hasDataIn = true;
      } else {
        // Data doesn't exist, return the login page route
        hasDataIn = false;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkSharedPreferencesData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chatty",
      theme: ThemeData(primaryColor: Colors.orange.shade400),
      debugShowCheckedModeBanner: false,
      home: hasDataIn == true ? HomeScreen() : LoginScreen(),
    );
  }
}
