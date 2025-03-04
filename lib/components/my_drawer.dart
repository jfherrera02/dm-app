import 'package:dmessages/pages/settings_page.dart';
import 'package:dmessages/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget  {
  const MyDrawer ({super.key});

  void logout(){
    // obtain the authentication service
    final auth = AuthService();
    // then just sign out
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // App logo

          // home drawer tile 
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              title: const Text("Dmessages Home"),
              leading: const Icon(Icons.home),
              onTap: () {
                // pop the drawer
                Navigator.pop(context);
              },
            ),
          ),
          // settings drawer tile 
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              title: const Text("Settings"),
              leading: const Icon(Icons.settings),
              onTap: () {
                // pop drawer
                Navigator.pop(context);
                // go to settings page ->
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                 );
              },
            ),
          ),

          // logout drawer tile
          // can further edit with a column to give logout
          // padding so it is at the bottom
          // NOT YET IMPLEMENTED
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              title: const Text("Logout"),
              leading: const Icon(Icons.logout),
              onTap: logout,
            ),
          ),
        ],
      )
    );    
  }
}