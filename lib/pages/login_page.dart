import 'package:DermaShielder/components/button.dart';
import 'package:DermaShielder/components/textfield.dart';
import 'package:DermaShielder/components/square_tile.dart';
import 'package:flutter/material.dart';
//comment

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in
  void signUserIn() {
    // Add your sign-in logic here
  }

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start the animation after the page is loaded
    Future.delayed(Duration(milliseconds: 100), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView( // Use SingleChildScrollView for better handling on small screens
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSlideIn(50, SizedBox(
                  width: 100, // Set the desired width
                  height: 100, // Set the desired height
                  child: Image.asset("lib/assets/images/logo_transparent.png"),
                ))
                ,
                _buildSlideIn(100, SizedBox(height: 20)), // Added spacing
                _buildSlideIn(150, Text(
                  'Welcome back, you\'ve been missed!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                )),
                _buildSlideIn(200, SizedBox(height: 30)), // Added spacing
                _buildSlideIn(250, MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                )),
                _buildSlideIn(300, SizedBox(height: 20)), // Added spacing
                _buildSlideIn(350, MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                )),
                _buildSlideIn(400, SizedBox(height: 20)), // Added spacing
                _buildSlideIn(450, Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Forgot Password?', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )),
                _buildSlideIn(500, SizedBox(height: 30)), // Added spacing
                _buildSlideIn(550, MyButton(onTap: signUserIn)),
                _buildSlideIn(600, SizedBox(height: 30)), // Added spacing
                _buildSlideIn(650, Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('Or continue with', style: TextStyle(color: Colors.grey[700])),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      )
                    ],
                  ),
                )),
                _buildSlideIn(700, SizedBox(height: 30)), // Added spacing
                _buildSlideIn(750, Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(imagePath: 'lib/assets/images/google_logo.png'),
                    SizedBox(width: 25),
                    SquareTile(imagePath: 'lib/assets/images/DS_logo.jpeg')
                  ],
                )),
                _buildSlideIn(800, SizedBox(height: 30)), // Added spacing
                _buildSlideIn(850, Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Not a member?", style: TextStyle(color: Colors.grey[700])),
                    SizedBox(width: 4),
                    Text("Register now!", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlideIn(double delay, Widget child) {
    return SlideTransition(
      position: _slideAnimation,
      child: child,
    );
  }
}
