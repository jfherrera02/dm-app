import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  // Properties for customization
  final String hintText; // Placeholder text for the input field
  final bool obscureText; // Determines if text should be hidden (for passwords)
  final TextEditingController controller; // Controls text input
  final FocusNode? focusNode; // Optional: Manages focus behavior
  final TextInputType
      keyboardType; // Determines the keyboard type (e.g., email, text, password)

  const MyTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text, // Default to regular text input
  });

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  // Keeps track of whether the text is obscured or visible
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText; // Set initial obscure state
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 25.0), // Adds padding around the text field
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: widget.obscureText
            ? _isObscured
            : false, // Only obscure if the flag is true
        keyboardType:
            widget.keyboardType, // Set the keyboard type based on input
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .tertiary), // Border color when not focused
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .tertiary), // Border color when focused
          ),
          fillColor: Theme.of(context)
              .colorScheme
              .secondary, // Background color of the input field
          filled: true, // Ensures the background is filled
          hintText: widget.hintText, // Placeholder text
          hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary), // Hint text color

          // Password visibility toggle (only shown for password fields)
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _isObscured
                        ? Icons.visibility_off
                        : Icons.visibility, // Change icon based on state
                    color: Theme.of(context)
                        .colorScheme
                        .primary, // Matches theme color
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured; // Toggle visibility state
                    });
                  },
                )
              : null, // No icon for non-password fields
        ),
      ),
    );
  }
}
