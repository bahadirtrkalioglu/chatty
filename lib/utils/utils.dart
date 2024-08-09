import 'package:flutter/material.dart';

class Utils {
  var theBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.blueGrey, width: 2),
    borderRadius: BorderRadius.circular(15),
  );
  var focusedBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.blueGrey, width: 2),
    borderRadius: BorderRadius.circular(15),
  );
  var errorBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.redAccent, width: 2),
    borderRadius: BorderRadius.circular(15),
  );
}
