import 'package:dmessages/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:dmessages/components/my_button.dart';
import 'package:dmessages/components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  // controllers for the email and password
  // username to be integrated in future versions
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  
  // go to login
  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  // method for regestering account
  void register(BuildContext context){
    // get the authentication service
    final _auth = AuthService();

    // both passwords must match
    // for successful registration
    if (_passwordController.text == _confirmController.text) {
      try{
            _auth.signInWithEmailAndPassword(
      _emailController.text, 
      _passwordController.text,
      );
        } catch (e) {
          showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text(e.toString()),
      )
    );
        } 
    }
    // if passwords do not match -> advise user to fix
    else {
      showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text("The passwords do not match! Please make sure they are the same!"),
      )
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center
        (child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Icon(Icons.message,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
            ),
            // Login Greeting Message
            Text(
              "Create Your Account",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            // email entry
            MyTextField(
              hintText: "Email",
              obscureText: false,
              controller: _emailController,
            ),
            const SizedBox(height: 10),
            // password
            MyTextField(
              hintText: "Password",
              obscureText: true,
              controller: _passwordController,
            ),

            const SizedBox(height: 10),
            // password
            MyTextField(
              hintText: "Confirm Password",
              obscureText: true,
              controller: _confirmController,
            ),

            const SizedBox(height: 25),

            // login button
            MyButton(
              text: "Register",
              onTap: () => register(context),
            ),
            
            const SizedBox(height: 25),

            // register button
            GestureDetector( onTap: onTap,
              child: Text(
                "Back to Login",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary), 
              ),
            ),
          ]
        ),
      ),
    );
  }
}