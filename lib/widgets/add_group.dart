import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddGroup extends StatelessWidget {
  final void Function()? onPressed;
  const AddGroup({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: "Add Group",
      onPressed: onPressed,
      backgroundColor: Colors.orange.shade400,
      child: const FaIcon(
        FontAwesomeIcons.userGroup,
        size: 22,
      ),
    );
  }
}
