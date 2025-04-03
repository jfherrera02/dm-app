import 'package:cloud_firestore/cloud_firestore.dart';

class Post{
  final String id;
  final String userId; 
  final String userName;
  final String text;
  final String imageUrl;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
  });

  // change info 
   Post copyWith ({String? imageUrl}) {
    return Post(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      // images will be the class that can be changed
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp,    
    );
   }

   // convert post object ----> json file to store in firebase
   Map<String, dynamic> toJson(){
    return{
      'id': id,
      'userId': userId,
      'username': userName,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
    };
   }
   // REVERSE: from firebase, return json file ----> post object to use
   factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      userName: json['username'],
      text: json['text'],
      imageUrl: json['imageUrl'],
      // timestamp is a 'DateTime' object so we must convert it
      // timestamp: json['timestamp'], this will no work so we do -->
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
   }
}