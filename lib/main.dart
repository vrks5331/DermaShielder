import 'package:DermaShielder/pages/auth_page.dart';
import "package:flutter/material.dart";
import 'package:firebase_core/firebase_core.dart';
import 'auth/firebase_options.dart';

//test

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,

  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
    );
  }
}
