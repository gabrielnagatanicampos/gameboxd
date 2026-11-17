import 'package:flutter/material.dart';

/// Rosa-pastel das estrelinhas de avaliação.
const corEstrela = Color(0xFFFF7EB6);

class AppTheme {
  static const seed = Color(0xFF5B3FD0);

  static ThemeData get claro => _montar(Brightness.light);
  static ThemeData get escuro => _montar(Brightness.dark);

  static ThemeData _montar(Brightness brilho) => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        brightness: brilho,
        appBarTheme: const AppBarTheme(centerTitle: false),
        snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
}
