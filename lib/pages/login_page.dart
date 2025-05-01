import 'package:dmessages/components/my_button.dart';
import 'package:dmessages/responsive/constrained_scaffold.dart';
import 'package:dmessages/services/auth/presentation/cubits/auth_cubits.dart';
import 'package:flutter/material.dart';
import 'package:dmessages/components/my_textfield.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  // create the state
  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  // Declare text controllers here:
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Clean up controllers when widget is disposed
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Create the login method for the button
  void login() {
    // Prep email and password by grabbing text from controllers ->
    final String email = emailController.text;
    final String password = passwordController.text;

    // Get auth cubit for logging in
    final authCubit = context.read<AuthCubit>();

    // Now check that both fields are not empty
    if (email.isNotEmpty && password.isNotEmpty) {
      // Log in the user
      authCubit.loging(email, password);
    }
    // Otherwise, display the proper error:
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Please enter both email and password before logging in!"),
        ),
      );
    }
  }

  // Begin building the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              children: [
                // Lock icon
                Image(image: AssetImage('assets/images/tether_text_black.png'),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                    ),
                const SizedBox(height: 25),
        
                // Personalized message (Greeting)
                Text(
                  "Welcome to Tether",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                  ),
                ),
        
                const SizedBox(height: 30),
        
                // Use custom text field (import):
                // Email text field:
                MyTextField(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController,
                ),
        
                const SizedBox(height: 12),
        
                // Password text field:
                MyTextField(
                  hintText: "Password",
                  obscureText: true,
                  controller: passwordController,
                ),
        
                const SizedBox(height: 25),
        
                // Make the login button
                MyButton(
                  text: "Login",
                  onTap: login,
                ),
        
                const SizedBox(height: 45),
        
                // Method to go to register page ->
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "New to Tether?",
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      // Make onTap into a widget so it can
                      // also be used in the register page / etc..
                      // onTap will serve as a toggle page
                      onTap: widget.onTap,
                      child: Text(
                        "Tap to Register",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* image
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center
        (child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Image(image: AssetImage('assets/images/tether-icon.png')),
            // Login Greeting Message
            Text(
              "Tether",
              style: TextStyle(
                color: Colors.black,
                fontSize: 32,
                fontStyle: FontStyle.italic,
              ),
            ), 
*/
