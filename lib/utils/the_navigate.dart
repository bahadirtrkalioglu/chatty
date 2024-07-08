import 'package:flutter/material.dart';

class TheNavigate {
  void pushIt(BuildContext context, final page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  void pushReplaceIt(BuildContext context, final page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }
}
