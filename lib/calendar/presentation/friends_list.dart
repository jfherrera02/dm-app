// Create a list of all users (except self) 
import 'package:dmessages/calendar/data/calendar_repository.dart';
import 'package:dmessages/calendar/domain/calendar_cubit.dart';
import 'package:dmessages/calendar/presentation/friends_calendar.dart';
import 'package:dmessages/components/user_tile.dart';
import 'package:dmessages/services/auth/auth_service.dart';
import 'package:dmessages/services/chat/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendsList extends StatefulWidget {
  const FriendsList(BuildContext context, {super.key});

  @override
  State<FriendsList> createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Navigate to Your Shared Calendars"),
        actions: [

        ],
      ),
      body: Column(
        children: [
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
                              : AssetImage('assets/images/default_avatar.png')
                                  as ImageProvider,
                        ),
                        title: Text(user['username']),
                        subtitle: Text(user['email']),
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
          return const Center(
              child: Text("Something went wrong. Please try again."));
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
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    final currentUserEmail = _authService.getCurrentUser()?.email;

    final currentUserUid = _authService.getCurrentUser()?.uid;
    final otherUserUid = userData["uid"] as String;
    final otherUsername = userData["username"] as String;
    
    // determine the shared calendar ID based on the user data
    final ids = [currentUserUid, otherUserUid]..sort();
    final sharedCalenderID = ids.join("_");

    if (userData["email"] == currentUserEmail || userData["uid"] == currentUserUid) {
      return Container(); // Skip current user
    }

    return UserTile(
      text: userData["username"],
      onTap: () {
        // Navigate to the chat page when tapping a user
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider<CalendarCubit>(
              create: (context) => CalendarCubit(
                calendarId: sharedCalenderID, 
                repository: CalendarRepository(),
                participants: ids.whereType<String>().toList(),
              ),
              child: SharedCalendarPage(
                friendUid: otherUserUid,
                friendUsername: otherUsername,
              ),
            ),
          ),
        );
      },
    );
  }
}
