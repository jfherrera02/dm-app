import 'package:dmessages/services/auth/presentation/cubits/auth_cubits.dart';
import 'package:flutter/material.dart';
import 'package:dmessages/components/my_button.dart';
import 'package:dmessages/components/my_textfield.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  // go to login
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // controllers for the email and password
  // username to be integrated in future versions
  final _emailController = TextEditingController();
  final  _passwordController = TextEditingController();
  final  _usernameController = TextEditingController();
  final  _confirmController = TextEditingController();
  // method for regestering account
  
  void register() {
    final String username = _usernameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmController = _confirmController.text;

    // we need to obtain the authentication cubit to proceed
    final authCubit = context.read<AuthCubit>(); 

    // ensure that the files are not empty for security: 
    if (email.isNotEmpty && 
      username.isNotEmpty && 
      password.isNotEmpty && 
      confirmController.isNotEmpty){
      // now make sure that the passwords match before registering
      if (password == confirmController) {
        // proceed with registration
        authCubit.newRegister(username, email, password);
      }
      // passwords do not match so show error -->
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete every field available.")));
      }
    }
    else {
      // empty fields
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all of the fields.")));
    }
  }
    @override
    // now get rid of all used controllers ->
    void dispose() {
      _usernameController.dispose();
      _confirmController.dispose();
      _emailController.dispose();
      _passwordController.dispose();
      super.dispose();
    }

    /* OLD REGISTER METHOD: 
    // get the authentication service
    final auth = AuthService();

    // both passwords must match
    // for successful registration
    if (_passwordController.text == _confirmController.text) {
      try{
            auth.signUpWithEmailAndPassword(
      _emailController.text, 
      _passwordController.text,
      _usernameController.text,
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
    */
  
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

            // username entry
            MyTextField(
              hintText: "Username",
              obscureText: false,
              controller: _usernameController,
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

            // Register button
            MyButton(
              text: "Register", 
              onTap: register,
            ),
            
            const SizedBox(height: 25),

            // Back to Login button
            GestureDetector(onTap: widget.onTap,
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