import 'package:dmessages/pages/friend_requests.dart';
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
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  // Search for users when the query changes
  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    List<Map<String, dynamic>> results = await _authService.searchUsers(query);
    setState(() {
      _searchResults = results;
    });
  }

  // Send friend request
  void _sendFriendRequest(String receiverUid) async {
    await _authService.sendFriendRequest(receiverUid);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Friend request sent!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Find Friends"),
        actions: [
          // Friend Requests Button (Top Right)
          IconButton(
            icon: Icon(Icons.people),
            tooltip: "Friend Requests",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendRequestsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by username...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _searchUsers,
            ),
          ),

          // Display Search Results or User List
          Expanded(
            child: _searchResults.isEmpty
                ? _buildUserList() // Display the list of users if no search results
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user['profileImageUrl'] != null
                              ? NetworkImage(user['profileImageUrl'])
                              : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                        ),
                        title: Text(user['username']),
                        subtitle: Text(user['email']),
                        trailing: ElevatedButton(
                          onPressed: () => _sendFriendRequest(user['uid']),
                          child: Text("Add Friend"),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
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
              receiverName: userData['username'],
            ),
          ),
        );
      },
    );
  }
}