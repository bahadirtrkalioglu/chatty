import 'package:flutter/material.dart';

import '../utils/utils.dart';

class AuthTextField extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isObscured;
  AuthTextField(
      {super.key,
      required this.text,
      required this.controller,
      this.validator,
      required this.isObscured});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      obscureText: isObscured,
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blueGrey.withOpacity(0.2),
        enabledBorder: Utils().theBorder,
        focusedBorder: Utils().focusedBorder,
        errorBorder: Utils().errorBorder,
        focusedErrorBorder: Utils().errorBorder,
        hintText: text,
        hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500),
      ),
    );
  }
}
