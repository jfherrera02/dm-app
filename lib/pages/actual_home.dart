import 'package:dmessages/components/my_drawer.dart';
import 'package:dmessages/pages/friends_page.dart';
import 'package:dmessages/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class ActualHome extends StatefulWidget {
  const ActualHome({super.key});

  @override
  State<ActualHome> createState() => _ActualHomeState();
}

class _ActualHomeState extends State<ActualHome> {
  // Current index for navigation
  int _selectedIndex = 0;

  // List of pages for navigation
  final List<Widget> _pages = [
    const Center(child: Text("Home Page")),  // Placeholder for Home
    FriendPage(),  // Friends Page (Previously labeled as "Messages")
    const Center(child: Text("Calendar Page")),  // Placeholder for Calendar
    UserProfilePage(),  // Profile Page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      // App Bar
      appBar: AppBar(
        title: const Text("Tether"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),

      // Drawer
      drawer: MyDrawer(),

      // Body - IndexedStack preserves state of pages
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: GNav(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        tabBackgroundColor: Theme.of(context).colorScheme.surface,
        gap: 8,
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        tabs: const [
          GButton(icon: Icons.home, text: 'Home'),   // Index 0
          GButton(icon: Icons.people, text: 'Friends'), // Index 1
          GButton(icon: Icons.event, text: 'Calendar'),  // Index 2
          GButton(icon: Icons.account_circle, text: 'Profile'),  // Index 3
        ],
      ),
    );
  }
}
