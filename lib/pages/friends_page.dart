import 'package:dmessages/components/user_tile.dart';
import 'package:dmessages/pages/chat_page.dart';
import 'package:dmessages/services/auth/auth_service.dart';
import 'package:dmessages/services/chat/chat_services.dart';
import 'package:flutter/material.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  // Get the chat and authentication (auth) services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      
      // Build the list of users
      body: _buildUserList(),
    );
  }

  // Build the list of users except for the current user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong. Please try again."));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No friends available."));
        }

        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  // Build each user item, excluding the current user
  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    final currentUserEmail = _authService.getCurrentUser()?.email;

    if (userData["email"] == currentUserEmail) {
      return Container(); // Skip current user
    }

    return UserTile(
      text: userData["email"],
      onTap: () {
        // Navigate to the chat page when tapping a user
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverEmail: userData["email"],
              receiverID: userData['uid'],
            ),
          ),
        );
      },
    );
  }
}
