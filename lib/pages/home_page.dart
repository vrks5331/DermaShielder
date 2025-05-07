import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
  List<Map<String, dynamic>> images = [];
  int _colorIndex = 0;
  int _imageCount = 0; // Keeps track of the number of images uploaded.

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

  Container _addImage(File file) {
    String filePath = file.path;
    Color barColor = _colorIndex % 2 == 0 ? Colors.lightBlue : Colors.pink.shade300;
    _colorIndex++;

    // Label and Timestamp
    String label = "Image #$_imageCount"; // Display the image number
    String timestamp = DateTime.now().toString(); // Current timestamp

    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text("$_imageCount", style: TextStyle(color: barColor)),
            ),
            const SizedBox(width: 10),
            Text(filePath, style: const TextStyle(color: Colors.white)),
          ],
        ),
        subtitle: Text(
          "Uploaded at: $timestamp",
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chat, color: Colors.white),
              onPressed: () => _openAIChatDialog(filePath),
            ),
            IconButton(
              icon: const Icon(Icons.analytics, color: Colors.white),
              onPressed: () => _openAnalyzeDialog(filePath),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAIChatDialog(String filePath) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: SizedBox(
            height: 400,
            width: 300,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue,
                  child: const Text(
                    "AI Chatbot",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text("File Path: $filePath", style: const TextStyle(fontSize: 16)),
                ),
                // TODO: Add the AI Chatbot interface here.
                // This can include a TextField, a list of chat messages, etc.
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to handle the Analyze dialog.
  Future<void> _openAnalyzeDialog(String filePath) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: SizedBox(
            height: 200,
            width: 300,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(height: 20),
                const Text("Analyzing image..."),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showErrorDialog();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Error dialog when analyzing image fails.
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Icon(Icons.error, color: Colors.red),
          content: const Text("Error: Failed to analyze image."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
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
          drawer: _buildDrawer(),
          body: _buildBody(user),
          floatingActionButton: FloatingActionButton(
            onPressed: _toggleMenu,
            backgroundColor: Colors.lightBlue,
            child: const Icon(Icons.add, size: 32),
          ),
        ),

        if (_isMenuOpen)
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

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
                  _buildMenuItem(Icons.upload, "Upload Image", () async {
                    _toggleMenu();
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      File file = File(result.files.single.path!);
                      setState(() {
                        _imageCount++; // Increment image count
                        images.add({"file": file});
                      });
                    }
                  }),
                  const SizedBox(height: 10),
                  _buildMenuItem(Icons.camera_alt, "Take Photo", () {
                    _toggleMenu();
                    // TODO: Implement Take Photo
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

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
        child: images.isEmpty
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_a_photo_sharp,
              size: 200,
              color: Colors.grey,
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
        )
            : Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: images.map((image) {
              return _addImage(image["file"] as File);
            }).toList(),
          ),
        ),
      );
    }
  }

  Widget _buildDrawer() {
    return Drawer(
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
    );
  }

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
