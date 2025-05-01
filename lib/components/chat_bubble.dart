import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String? imageURL;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.imageURL,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: isCurrentUser
              ? Colors.amber
              : const Color.fromARGB(255, 207, 207, 207),
          borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(color: Colors.black),
          ),
          if (imageURL != null)
            Image.network(
              imageURL!,
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
        ],
      ),
    );
  }
}
