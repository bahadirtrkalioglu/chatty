import 'package:flutter/material.dart';

class CustomSnack {
  static final CustomSnack _instance = CustomSnack._internal();
  final List<SnackBar> _queue = [];

  factory CustomSnack() {
    return _instance;
  }

  CustomSnack._internal();

  static Future<void> showCustomSnackBar(
    BuildContext context,
    String message,
  ) async {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 2),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessengerState messengerState = ScaffoldMessenger.of(context);
      messengerState.hideCurrentSnackBar();
      messengerState.showSnackBar(snackBar);
    });
  }

  void _snackBarClosed(BuildContext context) {
    if (_queue.isNotEmpty) {
      final snackBar = _queue.removeAt(0);
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBar)
          .closed
          .then((_) => _snackBarClosed(context));
    }
  }
}
