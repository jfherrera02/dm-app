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
    // Send a normal message
    if (imageURL == null) {
      return Container(
        decoration: BoxDecoration(
            color: isCurrentUser
                ? Colors.amber
                : const Color.fromARGB(255, 207, 207, 207),
            borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
        child: Text(
          message,
          style: TextStyle(color: Colors.black),
        ),
      );
    }
    // Send an image message
    else {
             return Container(
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? Colors.amber
                      : const Color.fromARGB(255, 207, 207, 207),
                  borderRadius: BorderRadius.circular(2),
                ),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
               child: Image.network(
                imageURL!,
                fit: BoxFit.cover,
                width: 200,
                height: 200,
              ),
             );
          }
  }
}
