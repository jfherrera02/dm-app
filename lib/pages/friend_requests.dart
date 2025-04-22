import 'package:flutter/material.dart';
import 'package:dmessages/services/auth/auth_service.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _friendRequests = [];

  @override
  void initState() {
    super.initState();
    _loadFriendRequests();
  }

  void _loadFriendRequests() async {
    List<Map<String, dynamic>> requests =
        await _authService.getFriendRequests();
    setState(() {
      _friendRequests = requests;
    });
  }

  void _acceptFriend(String uid) async {
    await _authService.acceptFriendRequest(uid);
    _loadFriendRequests();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Friend request accepted!")),
    );
  }

  void _declineFriend(String uid) async {
    await _authService.declineFriendRequest(uid);
    _loadFriendRequests();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Friend request declined.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Friend Requests")),
      body: _friendRequests.isEmpty
          ? Center(child: Text("No friend requests."))
          : ListView.builder(
              itemCount: _friendRequests.length,
              itemBuilder: (context, index) {
                final request = _friendRequests[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: request['profileImageUrl'].isNotEmpty
                        ? NetworkImage(request['profileImageUrl'])
                        : AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                  ),
                  title: Text(request['username']),
                  subtitle: Text(request['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _acceptFriend(request['uid']),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _declineFriend(request['uid']),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
