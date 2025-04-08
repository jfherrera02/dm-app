import 'package:flutter/material.dart';

// Bio widget that will show the text in a box 
class Bio extends StatelessWidget {
  final String text;

  const Bio({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    // create the UI for the box
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
      ),

      width: double.infinity,
      child: Text(text.isNotEmpty ? text : "This bio is empty! :("),
    );
  }
}