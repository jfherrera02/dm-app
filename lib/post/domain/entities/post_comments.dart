class PostComments {
  final String postId;
  final String id;
  final String username;
  final String text;
  final DateTime timestamp;

  PostComments({
    required this.postId,
    required this.id,
    required this.username,
    required this.text,
    required this.timestamp,
  });

  // convert post comments object ----> json file to store in firebase
  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'id': id,
      'username': username,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // REVERSE: from firebase, return json file ----> post comments object to use
  // this will be used to convert the json file to a post comments object
  factory PostComments.fromJson(Map<String, dynamic> json) {
    return PostComments(
      postId: json['postId'],
      id: json['id'],
      username: json['username'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}