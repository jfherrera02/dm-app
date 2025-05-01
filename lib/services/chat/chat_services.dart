import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dmessages/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService {
  // Get the instance of Firestore + auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the instance of Firebase Storage
  // for sending images
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // obtain user  stream
  /*
    The function of this Stream<List><Map>... is as follows:
    // List of the following:
  [
    {
      'email': user@email.com,
      'id': wfoinag123,
       etc: etc...
    }
          // storing multiple user data
    {
      'email': other_user@email.com,
      'id': other_user3,
       etc: etc...
    }
  ]
  */

  // Goal to display all users at home page
  // alternatively, at the chat page (Not yet implemented)
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through every user
        final user = doc.data();

        // now return the user
        return user;
      }).toList();
    });
  }

  // send() messages
  Future<void> sendMessage(String receiverID, {required String message, String? imageURL}) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    // get the timestamp of the messages sent (each)
    final Timestamp timestamp = Timestamp.now();

    // creat new message to send
    Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp,
        imageURL: imageURL,
        );

    // cosntruct the chat room ID for the 2 users (unique)
    // group chats to be later implemented
    // chat room function:
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // ensure the chatroomID is the same for the people chatting
    String chatRoomID = ids.join('_');
    // now add new message to the database
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
    // add new message to the database (ensure they are not deleted every time)
  }

  // pick & upload an image, then send as a message
  Future<void> sendImage(String receiverID, File file) async {
    final String currentUserID = _auth.currentUser!.uid;
    List<String> ids = [currentUserID, receiverID]..sort();
    String chatRoomID = ids.join('_');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '$timestamp${file.path.split('/').last}';
    final ref = _storage.ref().child('chat_images/$chatRoomID/$fileName');
    final uploadTask = await ref.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    await sendMessage(
      receiverID,
      message: '',
      imageURL: downloadUrl,
    );
  }

  // receive() messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort(); // ensure the chatroomID is the same for the people chatting
    String chatRoomID = ids.join('_');
    // now add new message to the database
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages") // and get the images
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
