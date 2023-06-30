// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loction_taxi/Screens/home_screen.dart';
import 'package:loction_taxi/Screens/register.dart';
import 'controllers/dependencies.dart' as dep;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dep.init();
  runApp(Home());
}

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);
  FirebaseAuth fAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: fAuth.currentUser == null ? RegisterScreen() : HomeScreen(),
    );
  }
}
