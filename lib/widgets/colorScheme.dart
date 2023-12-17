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


const Color textfieldGrey = Color.fromRGBO(209, 209, 209, 1);
const Color fontGrey = Color.fromRGBO(107, 115, 119, 1);
const Color darkFontGrey = Color.fromRGBO(62, 68, 71, 1);
const Color whiteColor = Color.fromRGBO(255, 255, 255, 1);
const Color lightGrey = Color.fromRGBO(239, 239, 239, 1);
const Color redColor = Color.fromRGBO(230, 46, 4, 1);
const Color golden = Color.fromRGBO(255, 203, 99, 1);
const Color lightGolden = Color.fromRGBO(244, 216, 161, 0.652);

