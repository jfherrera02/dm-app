import 'package:dmessages/auth/auth_service.dart';
import 'package:dmessages/components/my_button.dart';
import 'package:flutter/material.dart';
import 'package:dmessages/components/my_textfield.dart';

class LoginPage extends StatelessWidget{
  // controllers for the email and password
  // username to be integrated in future versions
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // changed to non-constant from constant due to error 
  // touch to go to register
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});
  
  // method for logging in
  void login(BuildContext context) async {
    // authentication service:
    final authService = AuthService();

    // login method
    try{
      await authService.signinWithEmailPassword(_emailController.text, _passwordController.text);
    }
    // catch errors 
    catch(e){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text(e.toString()),
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
              "Welcome to Dmessages!",
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

            const SizedBox(height: 25),

            // login button
            MyButton(
              text: "Login",
              onTap: () => login(context),
            ),

            // register button
            GestureDetector(
              onTap: onTap,
              child: Text(
                "Click to Register",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}