import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current authenticated user
  // Useful for ensuring users do not chat with themselves, etc.
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in an existing user with email and password
  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Ensure user document exists in Firestore (prevents overwriting existing data)
      DocumentReference userDoc =
          _firestore.collection("Users").doc(userCredential.user!.uid);
      DocumentSnapshot docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': userCredential.user!.uid,
          'email': email,
          'username': email.split('@')[0], // Default username if missing
          'profileImageUrl': '', // Default to empty until user updates
          'friends': [],
          'friendRequests': [],
          'bio': '',
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception("Sign-in failed: ${e.message}");
    }
  }

  // Register a new user with email, password, and username
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create Firestore document for the new user
      await _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'username': username,
        'profileImageUrl': '', // Default empty profile picture
        'friends': [], // Empty friends list
        'friendRequests': [], // Empty friend requests list
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception("Sign-up failed: ${e.message}");
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception("Sign-out failed: ${e.toString()}");
    }
  }

  // **Search Users** by username
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection("Users")
          .where("username", isGreaterThanOrEqualTo: query)
          .where("username", isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs
          .map((doc) => {
                'uid': doc['uid'],
                'username': doc['username'],
                'email': doc['email'],
                'profileImageUrl': doc['profileImageUrl'] ?? '',
              })
          .toList();
    } catch (e) {
      throw Exception("Error searching users: ${e.toString()}");
    }
  }

  // **Send a Friend Request**
  Future<void> sendFriendRequest(String receiverUid) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("User not logged in");

      DocumentReference receiverDoc =
          _firestore.collection("Users").doc(receiverUid);

      await receiverDoc.update({
        'friendRequests': FieldValue.arrayUnion([currentUser.uid])
      });
    } catch (e) {
      throw Exception("Error sending friend request: ${e.toString()}");
    }
  }

// Fetch friend requests for the current user
  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("User not logged in");

      DocumentSnapshot userDoc =
          await _firestore.collection("Users").doc(currentUser.uid).get();
      List<dynamic> friendRequests = userDoc['friendRequests'] ?? [];

      List<Map<String, dynamic>> requestUsers = [];
      for (String uid in friendRequests) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection("Users").doc(uid).get();
        requestUsers.add({
          'uid': uid,
          'username': userSnapshot['username'],
          'email': userSnapshot['email'],
          'profileImageUrl': userSnapshot['profileImageUrl'] ?? '',
        });
      }

      return requestUsers;
    } catch (e) {
      throw Exception("Error fetching friend requests: ${e.toString()}");
    }
  }

// Accept a friend request and create a chat room
  Future<void> acceptFriendRequest(String senderUid) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("User not logged in");

      DocumentReference currentUserDoc =
          _firestore.collection("Users").doc(currentUser.uid);
      DocumentReference senderDoc =
          _firestore.collection("Users").doc(senderUid);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot currentUserSnapshot =
            await transaction.get(currentUserDoc);
        DocumentSnapshot senderSnapshot = await transaction.get(senderDoc);

        List<dynamic> currentRequests =
            currentUserSnapshot['friendRequests'] ?? [];
        List<dynamic> currentFriends = currentUserSnapshot['friends'] ?? [];
        List<dynamic> senderFriends = senderSnapshot['friends'] ?? [];

        // Remove sender from friendRequests and add to friends
        currentRequests.remove(senderUid);
        currentFriends.add(senderUid);
        senderFriends.add(currentUser.uid);

        transaction.update(currentUserDoc, {
          'friendRequests': currentRequests,
          'friends': currentFriends,
        });

        transaction.update(senderDoc, {
          'friends': senderFriends,
        });

        // Create a new chat room between the two users
        _createChatRoom(currentUser.uid, senderUid);
      });
    } catch (e) {
      throw Exception("Error accepting friend request: ${e.toString()}");
    }
  }

// Decline a friend request (simply remove from friendRequests)
  Future<void> declineFriendRequest(String senderUid) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("User not logged in");

      DocumentReference currentUserDoc =
          _firestore.collection("Users").doc(currentUser.uid);
      await currentUserDoc.update({
        'friendRequests': FieldValue.arrayRemove([senderUid]),
      });
    } catch (e) {
      throw Exception("Error declining friend request: ${e.toString()}");
    }
  }

// Private method to create a chat room when a request is accepted
  Future<void> _createChatRoom(String user1, String user2) async {
    String chatRoomId = (user1.hashCode <= user2.hashCode)
        ? "${user1}_$user2"
        : "${user2}_$user1";

    DocumentReference chatRoomRef =
        _firestore.collection("chat_rooms").doc(chatRoomId);
    DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();

    if (!chatRoomSnapshot.exists) {
      await chatRoomRef.set({
        'participants': [user1, user2],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Fetch the list of friends for the current user
  Future<List<Map<String, String>>> getFriendsList(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Assuming a 'friends' field in the user document that contains a list of user IDs
      List<dynamic> friendsIds = userDoc['friends'] ?? [];
      List<Map<String, String>> friendsList = [];

      for (var friendId in friendsIds) {
        DocumentSnapshot friendDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .get();
        friendsList.add({
          'uid': friendDoc.id,
          'email': friendDoc['email'],
          'username': friendDoc['username'],
          'profileImageUrl': friendDoc['profileImageUrl'] ?? '',
        });
      }

      return friendsList;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
