// credits to Mitch Koko on YT for the tutorial

import 'package:DermaShielder/components/textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text editing controllers

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea( // avoids notch
        child: Center(
          child: Column(
              children: [
            // logo
                const SizedBox(height: 50),
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
                const SizedBox(height: 50),

                Text(
                    'Welcome back, you\'ve been missed!',
                     style: TextStyle(
                         color: Colors.grey[700],
                         fontSize: 16,
                     ),
                ),

                const SizedBox(height: 25),

            // username text field
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
            // password text field
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

            // forgot password

            // sign in button

            // or continue with

            // google + apple (?) sign in buttons

            // not a member? register now!
          ]),
        ),
      ),
    );
  }
}