import 'package:flutter/material.dart';

class AppTheme {
  static const Color laranjaVibrante = Color(0xFFF84B03);
  static const Color laranja = Color(0xFFFB8200);
  static const Color cinzaEscuro = Color(0xFF4B4C51);
  static const Color branco = Color(0xFFFFFFFF);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: laranjaVibrante,
      scaffoldBackgroundColor: branco,
      fontFamily: 'Montserrat',
      appBarTheme: const AppBarTheme(
        backgroundColor: laranjaVibrante,
        foregroundColor: branco,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: laranjaVibrante,
          foregroundColor: branco,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
