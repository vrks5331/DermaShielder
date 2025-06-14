import 'package:DermaShielder/pages/auth_page.dart';
import "package:flutter/material.dart";
import 'package:firebase_core/firebase_core.dart';
import 'auth/firebase_options.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

const apiKey = redacted;


void main() async {
  Gemini.init(apiKey: apiKey);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,

  );
  runApp(
     MyApp()
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}
