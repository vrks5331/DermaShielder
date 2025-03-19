import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    bool onDarkMode = false;

    return Scaffold(
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
      body: Center(
        child: Text(
          user != null ? "LOGGED IN! Welcome, ${user.email}!" : "No user logged in",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
