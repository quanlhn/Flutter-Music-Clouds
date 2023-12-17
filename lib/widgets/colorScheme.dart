import 'package:flutter/material.dart';

class MyColorScheme {
  static const ColorScheme lightColorScheme = ColorScheme(
    primary: Color(0xFF261D1D),
    secondary: Color(0xFFD9534F),
    surface: Colors.white,
    background: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  );

  static final ColorScheme darkColorScheme = ColorScheme(
    primary: const Color(0xFF261D1D),
    secondary: const Color(0xFFD9534F),
    surface: Colors.grey[800]!,
    // background: Colors.grey[900]!,
    background: const Color(0xFF261D1D),
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: const Color.fromARGB(255, 220, 75, 13),
    onSurface: Colors.white,
    onBackground: Colors.white,
    onError: Colors.white,
    brightness: Brightness.dark,
  );

  static final ThemeData lightTheme = ThemeData.from(colorScheme: lightColorScheme);

  static final ThemeData darkTheme = ThemeData.from(colorScheme: darkColorScheme);

}