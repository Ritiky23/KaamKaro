import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaamkaro/screens/login.dart';
import 'package:kaamkaro/screens/signup.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid?
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCVLHKmngDZInkmR_5DkDG5u5tN5FpZ7og',
      appId:'1:841393183935:android:6bf3d6842b01e99bf5fa0a',
      messagingSenderId: '841393183935', 
      projectId: 'kaamkaro-b3a4c')
  )
  :await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KaamKaro',
      theme: ThemeData(
        textTheme: GoogleFonts.abelTextTheme(
          Theme.of(context).textTheme,
      
      ),),
      home: LoginScreen(),
    );
  }
}

