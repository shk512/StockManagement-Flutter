import 'package:flutter/material.dart';

void showSnackbar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14.0,
        ),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
    ),
  );
}