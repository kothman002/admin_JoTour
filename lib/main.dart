import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'home_page.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
            apiKey: "AIzaSyBCMQ5amCD8-kK-dvfZD4sGnF8Tn2xLxxI",    
            authDomain: "jotourr.firebaseapp.com",
            projectId: "jotourr",
            storageBucket: "jotourr.appspot.com",
            messagingSenderId: "639856314017",
            appId: "1:639856314017:web:11fc673397bee9065892e0",    ),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future getUserInfo() async {
    await getUser();
    setState(() {});
    print(uid);
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin JoTour',
      theme: ThemeData(brightness: Brightness.light),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}