
import 'package:flutter/material.dart';

// Paleta de colores basada en el logo de CordoPlan
const Color primaryColor = Color(0xFF0D253F); // Un azul oscuro y profundo
const Color secondaryColor = Color(0xFF00AEEF); // Azul cian brillante
const Color accentColor = Color(0xFF88C941); // Verde fresco
const Color backgroundColor = Color(0xFFF5F5F5); // Un fondo gris claro y limpio
const Color textColor = Color(0xFF333333); // Color de texto principal

// Definición del tema de la aplicación
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: backgroundColor,

  // Esquema de colores
  colorScheme: const ColorScheme(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: Colors.white,
    background: backgroundColor,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: textColor,
    onBackground: textColor,
    onError: Colors.white,
    brightness: Brightness.light,
  ),

  // Tema para AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 4,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  // Tema para botones elevados
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: secondaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),

  // Tema para campos de texto
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
  ),

  // Tema para tarjetas (Cards)
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
  ),

  // Tipografía
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
    headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
    bodyLarge: TextStyle(fontSize: 16, color: textColor),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.grey),
  ),
);
