import 'package:dmessages/pages/settings_page.dart';
import 'package:dmessages/auth/auth_service.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget  {
  const MyDrawer ({super.key});

  void logout(){
    // obtain the authentication service
    final _auth = AuthService();
    // then just sign out
    _auth.signOut();
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
              title: Text("Dmessages Home"),
              leading: Icon(Icons.home),
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
              title: Text("Settings"),
              leading: Icon(Icons.settings),
              onTap: () {
                // pop drawer
                Navigator.pop(context);
                // go to settings page ->
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(),
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
              title: Text("Logout"),
              leading: Icon(Icons.logout),
              onTap: logout,
            ),
          ),
        ],
      )
    );    
  }
}