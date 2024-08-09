import 'package:flutter/material.dart';
import 'package:learn_firestore/screens/register_screen.dart';
import 'package:learn_firestore/services/auth_services.dart';
import 'package:learn_firestore/widgets/auth_text_field.dart';
import 'package:learn_firestore/widgets/submit_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
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
                  child: Image.asset("assets/images/login.png"),
                ),
                const SizedBox(
                  height: 12,
                ),
                AuthTextField(
                  isObscured: false,
                  text: "E-mail",
                  controller: emailController,
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
                const SizedBox(
                  height: 20,
                ),
                AuthTextField(
                  isObscured: true,
                  text: "Password",
                  controller: passwordController,
                  validator: (value) {
                    if (value!.isEmpty || (value.length < 8)) {
                      return 'Enter at least 8 digit password';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                SubmitButton(
                    onTap: () async {
                      if (_formkey.currentState!.validate()) {
                        await AuthServices().login(emailController.text,
                            passwordController.text, context);
                      }
                    },
                    text: "Login"),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500),
                    ),
                    GestureDetector(
                      child: const Text(
                        "Register",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
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
