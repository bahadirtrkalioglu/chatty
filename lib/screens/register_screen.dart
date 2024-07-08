import 'package:flutter/material.dart';
import 'package:learn_firestore/screens/chat_screen.dart';
import 'package:learn_firestore/screens/login_screen.dart';
import 'package:learn_firestore/services/auth_services.dart';
import 'package:learn_firestore/utils/the_navigate.dart';
import 'package:learn_firestore/widgets/auth_text_field.dart';
import 'package:learn_firestore/widgets/submit_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  Future<bool> checkSharedPreferencesData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('email') && prefs.containsKey('userName')) {
      // Data exists, return the home page route
      return true;
    } else {
      // Data doesn't exist, return the login page route
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Chatty',
          style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Image.asset("assets/images/register.png"),
                ),
                SizedBox(
                  height: 12,
                ),
                AuthTextField(
                  isObscured: false,
                  text: "User Name",
                  controller: _usernameController,
                  validator: (value) {
                    if (value!.isEmpty || (value.length < 2)) {
                      return "Enter correct name";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                AuthTextField(
                  isObscured: false,
                  text: "E-mail",
                  controller: _emailController,
                  validator: (value) {
                    if (value!.isEmpty ||
                        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)) {
                      return "Enter correct e-mail address";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                AuthTextField(
                  isObscured: true,
                  text: "Password",
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || (value.length < 8)) {
                      return 'Enter at least 8 digit password';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                AuthTextField(
                  isObscured: true,
                  text: "Password Again",
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value!.isEmpty ||
                        _confirmPasswordController.text !=
                            _passwordController.text) {
                      return 'Passwords don\'t match';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                SubmitButton(
                    onTap: () async {
                      if (_formkey.currentState!.validate()) {
                        await AuthServices().register(
                            _usernameController.text,
                            _emailController.text,
                            _passwordController.text,
                            context);
                      }
                    },
                    text: "Register"),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500),
                    ),
                    GestureDetector(
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
