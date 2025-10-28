import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFFFFFFFF); // white color
  static const secondaryColor = Color(0xFF000000); // black color
  static const button = Color(0xFFFF9B17); // yellow
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2855AE), // #2855AE
      Color(0xFF7292CF), // #7292CF
    ],
  );
}
