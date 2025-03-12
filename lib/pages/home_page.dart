import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: Center(
        child: Text(
          user != null ? "LOGGED IN! welcome, ${user.email}!" : "No user logged in",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary
          ),
        ),
      ),
    );
  }
}
