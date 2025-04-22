import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dmessages/post/domain/entities/post_comments.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  // likes
  final List<String> likes; // this is a list of user ids that liked the post
  final List<PostComments> comments; // this is a list of comments on the post

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.likes,
    required this.comments,
  });

  // change info
  Post copyWith({String? imageUrl}) {
    return Post(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      // images will be the class that can be changed
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp,
      likes: likes,
      comments: comments, // this is a list of comments on the post
    );
  }

  // convert post object ----> json file to store in firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': userName,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'comment': comments
          .map((comment) => comment.toJson())
          .toList(), // this is a list of comments on the post
    };
  }

  // REVERSE: from firebase, return json file ----> post object to use
  factory Post.fromJson(Map<String, dynamic> json) {
    // prepare comments
    final List<PostComments> comments = (json['comments'] as List<dynamic>?)
            ?.map((commentJson) => PostComments.fromJson(commentJson))
            .toList() ??
        [];

    return Post(
      id: json['id'],
      userId: json['userId'],
      userName: json['username'],
      text: json['text'],
      imageUrl: json['imageUrl'],
      // timestamp is a 'DateTime' object so we must convert it
      // timestamp: json['timestamp'], this will no work so we do -->
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(json['likes'] ??
          []), // this is a list of user ids that liked the post
      comments: comments, // this is a list of comments on the post
    );
  }
}
