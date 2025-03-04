import 'package:dmessages/components/my_drawer.dart';
import 'package:dmessages/components/user_tile.dart';
import 'package:dmessages/pages/chat_page.dart';
import 'package:dmessages/services/auth/auth_service.dart';
import 'package:dmessages/services/chat/chat_services.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget{
  HomePage({super.key});

// Get the chat and authentication (auth) services
final ChatService _chatService = ChatService();
final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // can edit app bar UI later
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      // little menu bar (change for a modern menu later)
      drawer: MyDrawer(),
      body: _buildUserList(),
    );
  }

  // build the list of users 
  // EXCEPT: for the current user

  Widget  _buildUserList () {
    return StreamBuilder(
      stream: _chatService.getUsersStream(), 
      builder: (context, snapshot) {
        // error check
        if (snapshot.hasError){
          return const Text("Error");
        }
        // loading...
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Text("Loading user view...");
        }
        // finally, return the list view
        return ListView(
          children: snapshot.data!.map<Widget>((userData) => _buildUserListItem(userData, context)).toList(),
        );
      },
    );
  }

  // now build the individual list tile for the user
  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    // Here, display every user except for the current user at use
    if(userData["email"] != _authService.getCurrentUser()!.email) {
      return UserTile(
      text: userData["email"],
      onTap: () {
        // There was a tap on a user so --> go to the coresponding chat page
        Navigator.push(
          context,
           MaterialPageRoute(
          builder: (context) => ChatPage(
            receiverEmail: userData["email"], 
            receiverID: userData['uid'],
          )
          )
        );
      },
    );
    }
    else{
      // **check** 
      return Container();
    }
  }


}