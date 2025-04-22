import 'package:country_picker/country_picker.dart';
import 'package:dmessages/responsive/constrained_scaffold.dart';
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
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmController = TextEditingController();
  // Using one controller for country is enough to display the selection
  final _countryController = TextEditingController();
  // final _countryDisplayController is kept if needed for future use
  final _countryDisplayController = TextEditingController();

  // method for registering account
  void register() {
    final String username = _usernameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmController = _confirmController.text;
    final String country = _countryController.text;

    // we need to obtain the authentication cubit to proceed
    final authCubit = context.read<AuthCubit>();

    // ensure that the fields are not empty for security:
    if (email.isNotEmpty &&
        username.isNotEmpty &&
        password.isNotEmpty &&
        confirmController.isNotEmpty &&
        country.isNotEmpty) {
      // now make sure that the passwords match before registering
      if (password == confirmController) {
        // proceed with registration
        authCubit.newRegister(username, email, password, country);
      }
      // passwords do not match so show error -->
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete every field available.")),
        );
      }
    } else {
      // empty fields
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all of the fields.")),
      );
    }
  }

  @override
  // now get rid of all used controllers ->
  void dispose() {
    _usernameController.dispose();
    _confirmController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _countryController.dispose();
    _countryDisplayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      body: Center(
        child: Container(
          // padding and margin just for breathing room
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(16),

          // this is your thin outline
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, // background color
            border: Border.all(
              color: Colors.grey.shade400, // outline color
              width: 1, // thinness of the line
            ),
            borderRadius: BorderRadius.circular(8), // rounded corners
          ),

          // now everything inside this box
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App logo
              Image.asset(
                'assets/images/tether_text_black.png',
                width: 200,
                height: 200,
              ),

              const SizedBox(height: 16),

              // Login Greeting Message
              Text(
                "Create Your Account",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              // Country picker button
              ButtonTheme(
                alignedDropdown: true,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: false, // optional-> Shows phone code before the country name.
                        onSelect: (Country country) {
                          // Update the country text field with the flag and country name
                          setState(() {
                            _countryController.text =
                                "${country.flagEmoji} ${country.displayName}";
                            _countryDisplayController.text =
                                "${country.flagEmoji} ${country.displayName}";
                            // print('Selected country: ${_countryController.text}');
                          });
                        },
                      );
                    },
                    child: AbsorbPointer(
                      child: MyTextField(
                        hintText: "Select Country",
                        obscureText: false,
                        controller: _countryController,
                        // readOnly: true,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

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

              // confirm password
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
              GestureDetector(
                onTap: widget.onTap,
                child: Text(
                  "Back to Login",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
