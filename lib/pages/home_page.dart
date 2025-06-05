import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_interface.dart';
import 'package:image_picker/image_picker.dart';
import 'tflite_helper.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;

  bool _isDarkMode = false;
  bool _isMenuOpen = false;
  int _imageCount = 0;
  String _searchQuery = "";
  List<Map<String, dynamic>> images = [];

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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      _isMenuOpen ? _animationController.forward() : _animationController.reverse();
    });
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  Future<void> _pickImage() async {
    _toggleMenu();
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      // Extract filename from the path for display
      String fileName = file.path.split('/').last; // Gets the last part of the path

      setState(() {
        images.add({
          "file": file,
          "timestamp": DateTime.now().toString(),
          "label": fileName // Use filename for uploaded files
        });
        _imageCount++;
      });
    }
  }

  void _renameImage(int index) {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Rename Image"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "Enter new label"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  images[index]['label'] = _controller.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }


  Future<void> _openAnalyzeDialog(String filePath) async {
    String analysisResult = "Analyzing...";
    String? finalClassification; // Keep it nullable initially

    // Show dialog with a future that will update its content and then pop
    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing until analysis is done or user explicitly closes
      builder: (context) {
        // This is a State<StatefulBuilder> context, allowing setState for the dialog
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Function to run the model and update dialog
            _performAnalysisAndSetResult() async {
              try {
                // Await the classification directly here
                String classification = await TFLiteHelper.classifyImage(File(filePath));
                setState(() {
                  analysisResult = classification; // Update dialog content
                  finalClassification = classification; // Store the result
                });
                // After analysis is done, you might want to automatically close the dialog
                // or allow the user to close it. For now, we'll keep the close button.
              } catch (e) {
                setState(() {
                  analysisResult = "Error: $e";
                  finalClassification = "Error: $e"; // Store error message
                });
                print('Error during TFLite classification: $e');
              }
            }

            bool analysisStarted = false;
            if (!analysisStarted) {
              analysisStarted = true;
              _performAnalysisAndSetResult();
            }

            return AlertDialog(
              title: const Text("Image Analysis"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show CircularProgressIndicator only if still analyzing
                  if (analysisResult == "Analyzing...")
                    const CircularProgressIndicator()
                  else
                    const SizedBox.shrink(), // No indicator if done
                  const SizedBox(height: 20),
                  Text(analysisResult, textAlign: TextAlign.center),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("Close"),
                  onPressed: () {
                    // You might want to handle what happens if user closes
                    // before analysis is complete (finalClassification is still null)
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );

    // After the analysis dialog is closed (either by user or automatically), navigate
    if (finalClassification != null && !finalClassification!.startsWith("Error:")) {
      // Only navigate if analysis was successful and not an error
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatInterface(
            images: images,
            isDarkMode: _isDarkMode,
            initialClassification: finalClassification!,
          ),
        ),
      );
    } else if (finalClassification != null && finalClassification!.startsWith("Error:")) {
      // If there was an error in classification, show a generic error dialog
      _showErrorDialog(); // Using your existing error dialog
    }
    // If finalClassification is null here, it means the dialog was closed before
    // analysis completed. You can decide how to handle this (e.g., do nothing, show a message).
    // The barrierDismissible: false helps prevent this, but the Close button still works.
  }


  Future<void> _openPhotoDialog(String filePath) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: SizedBox(
            height: 400, // Increased height for better viewing
            width: 300,
            // Use Image.file for local file paths
            child: Image.file(
              File(filePath),
              fit: BoxFit.contain, // Ensures the whole image fits without cropping
              errorBuilder: (context, error, stackTrace) {
                return Center(child: Text('Could not load image: $error'));
              },
            ),
          )
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Icon(Icons.error, color: Colors.red),
            content: const Text("Error: Failed to analyze image."),
            actions: [
            TextButton(
            onPressed: () => Navigator.of(context).pop(),
    child: const Text("OK"),
    ),
    ]),
    );
  }

  Widget _buildImageTile(File file, int index) {
    String label = images[index]['label'] ?? "Image #$index";
    String timestamp = images[index]['timestamp'] ?? DateTime.now().toString();
    Color barColor = index % 2 == 0 ? Colors.lightBlue : Colors.pink.shade300;

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
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => _renameImage(index),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white))),
          ],
        ),
        subtitle: Text(
          "Uploaded at: ${timestamp.split('.')[0]}",
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.photo, color: Colors.white),
              onPressed: () => _openPhotoDialog(file.path), // Use file.path here
            ),
            IconButton(
                icon: const Icon(Icons.chat, color: Colors.white),
                onPressed: () {
                  _openAnalyzeDialog(file.path);
                }
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _deleteImage(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(User? user) {
    if (user == null) {
      return const Center(
        child: Text("No user logged in", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );
    }

    List<Widget> filteredImages = images.asMap().entries.where((entry) {
      String label = entry.value['label']?.toLowerCase() ?? "";
      return label.contains(_searchQuery);
    }).map((entry) {
      return _buildImageTile(entry.value['file'], entry.key);
    }).toList();

    return filteredImages.isEmpty
        ? Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_a_photo_sharp, size: 200, color: Colors.grey),
        const SizedBox(height: 20),
        Text(
          "Scan a photo to get started",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[500]),
        ),
      ],
    )
        : ListView(children: filteredImages);
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
            decoration: BoxDecoration(color: Colors.grey[600]),
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
            leading: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nightlight),
            title: Text(_isDarkMode ? "Light Mode" : "Dark Mode"),
            onTap: () {
              Navigator.pop(context);
              _toggleDarkMode();
            },
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: buildScaffold(),
    );
  }

  Widget buildScaffold() {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Home"),
            backgroundColor: Colors.grey[600],
            elevation: 0,
          ),
          drawer: _buildDrawer(),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "Search images...",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        // Optional: trigger search action
                      },
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildBody(user)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _toggleMenu,
            backgroundColor: Colors.lightBlue,
            child: const Icon(Icons.add, size: 32),
          ),
        ),
        if (_isMenuOpen)
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(color: Colors.black.withOpacity(0.5)),
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
                  _buildMenuItem(Icons.upload, "Upload Image", _pickImage),
                  const SizedBox(height: 10),
                  _buildMenuItem(Icons.camera_alt, "Take Photo", () async {
                    _toggleMenu();

                    final picker = ImagePicker();
                    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

                    if (photo != null) {
                      File file = File(photo.path);
                      setState(() {
                        images.add({
                          "file": file,
                          "timestamp": DateTime.now().toString(),
                          "label": "Image #$_imageCount" // Use generic label for camera photos
                        });
                        _imageCount++;
                      });
                    }
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}