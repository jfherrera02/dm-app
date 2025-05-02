import 'package:dmessages/calendar/data/calendar_repository.dart';
import 'package:dmessages/calendar/domain/calendar_cubit.dart';
import 'package:dmessages/calendar/presentation/friends_calendar.dart';
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
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Display Search Results or User List
            Expanded(
              child: _searchResults.isEmpty
                  ? _buildUserList() // Display the list of users if no search results
                  : ListView.separated(
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user['profileImageUrl'] != null
                                ? NetworkImage(user['profileImageUrl'])
                                : null,
                            child: user['profileImageUrl'] == null
                                ? Icon(Icons.person)
                                : null,
                          ),
                          title: Text(user['username']),
                          subtitle: Text(user['email']),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: Theme.of(context).colorScheme.surfaceVariant,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          trailing: Icon(Icons.chevron_right),
                        );
                      },
                    ),
            ),
          ],
        ),
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

        return ListView.separated(
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => SizedBox(height: 8),
          itemBuilder: (context, index) {
            final userData = snapshot.data![index];
            return _buildUserListItem(userData, context);
          },
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

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: userData['profileImageUrl'] != null
            ? NetworkImage(userData['profileImageUrl'])
            : null,
        child:
            userData['profileImageUrl'] == null ? Icon(Icons.person) : null,
      ),
      title: Text(userData["username"]),
      subtitle: Text(userData["email"]),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: Theme.of(context).colorScheme.surfaceVariant,
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      trailing: Icon(Icons.chevron_right),
      onTap: () {
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
