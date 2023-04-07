import 'package:flutter/material.dart';

void showSnackBar(BuildContext context,String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.teal,
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }