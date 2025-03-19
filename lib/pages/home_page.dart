import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isMenuOpen = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(_animationController);
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Home"),
            backgroundColor: Colors.grey[600],
            elevation: 0,
          ),
          drawer: Drawer(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(user?.displayName ?? "User"),
                  accountEmail: Text(user?.email ?? "No email"),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const AssetImage("assets/images/default_profile.jpg") as ImageProvider,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text("Home"),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Settings"),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.nightlight),
                  title: const Text("Dark Mode"),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Logout"),
                  onTap: () => FirebaseAuth.instance.signOut(),
                ),
              ],
            ),
          ),
          body: _buildBody(user),
          floatingActionButton: FloatingActionButton(
            onPressed: _toggleMenu,
            backgroundColor: Colors.lightBlue,
            child: const Icon(Icons.add, size: 32),
          ),
        ),

        // Dimmed background when menu is open
        if (_isMenuOpen)
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

        // Animated menu sliding out from the button
        Positioned(
          bottom: 90,
          right: 20,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMenuItem(Icons.upload, "Upload Image", () {
                    _toggleMenu();
                    // TODO: Implement image upload functionality
                  }),
                  const SizedBox(height: 10),
                  _buildMenuItem(Icons.camera_alt, "Take Photo", () {
                    _toggleMenu();
                    // TODO: Implement take photo functionality
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ✅ Extracted method for conditional rendering
  Widget _buildBody(User? user) {
    if (user == null) {
      return const Center(
        child: Text(
          "No user logged in",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_a_photo_sharp,
              size: 200, // Huge icon
              color: Colors.grey, // Slightly faded color
            ),
            const SizedBox(height: 20),
            Text(
              "Scan a photo to get started",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }
  }

  /// ✅ Extracted method for menu item buttons
  Widget _buildMenuItem(IconData icon, String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
