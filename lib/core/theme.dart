// lib/core/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  
  static const Color primaryBlue = Color(0xFF3F51B5); // RGB: 63, 81, 181
  static const Color accentBlue =
      Color(0xFF4285F4); // RGB: 66, 133, 244 (Google Blue)
  // Fondo general de las pantallas (gris muy claro, casi blanco)
  static const Color backgroundLight = Color(0xFFF5F5F5); // RGB: 245, 245, 245
  // Fondo de los campos de texto y tarjetas claras
  static const Color inputFillColor =
      Color(0xFFE0E0E0); // RGB: 224, 224, 224 (Gris claro)
  // Colores para texto oscuro y títulos
  static const Color textDark =
      Color(0xFF212121); // RGB: 33, 33, 33 (Casi negro)
  // Colores para texto secundario o hints
  static const Color textMedium =
      Color(0xFF757575); // RGB: 117, 117, 117 (Gris medio)
  static const Color categoryOrange = Color(0xFFFF9800); // Naranja (ej: pagos)
  static const Color categoryBlue = Color(0xFF2196F3); // Azul (ej: servicios)
  static const Color categoryGreen =
      Color(0xFF4CAF50); // Verde (ej: documentos)
  static const Color categoryRed =
      Color(0xFFF44336); // Rojo (ej: alertas o gastos)
  static const Color categoryPurple =
      Color(0xFF9C27B0); // Morado (ej: personal)
  static const Color categoryLightGrey =
      Color(0xFF9E9E9E); // Gris para "otros" o iconos inactivos

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light, // Tema claro
    primaryColor: primaryBlue, // Color principal para AppBar, botones, etc.
    hintColor:
        accentBlue, // Color secundario para acentos (ej. FloatingActionButton)
    scaffoldBackgroundColor:
        backgroundLight, // Color de fondo predeterminado para Scaffold

    // Configuración de la AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors
          .transparent, // Transparente por defecto, se puede cambiar por pantalla
      elevation: 0, // Sin sombra
      foregroundColor:
          textDark, // Color del texto del título y los iconos de la app bar
      iconTheme:
          IconThemeData(color: textDark), // Color de los iconos de la app bar
    ),

    // Configuración de los botones elevados (ElevatedButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue, // Fondo azul principal
        foregroundColor: Colors.white, // Texto blanco
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Bordes redondeados
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0), // Padding generoso
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily:
              'Inter', // <--- ¡Asegúrate de que la fuente 'Inter' esté bien configurada en pubspec.yaml!
        ),
      ),
    ),

    // Configuración de los botones de texto (TextButton)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue, // Texto azul principal
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily:
              'Inter', // <--- ¡Asegúrate de que la fuente 'Inter' esté bien configurada en pubspec.yaml!
        ),
      ),
    ),

    // Configuración de los campos de entrada de texto (TextFormField, TextField)
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        // Borde general
        borderRadius: BorderRadius.circular(12.0), // Bordes redondeados
        borderSide:
            BorderSide.none, // Sin borde visible, ya que usaremos filled
      ),
      enabledBorder: OutlineInputBorder(
        // Borde cuando el campo está habilitado
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        // Borde cuando el campo está enfocado
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
            color: accentBlue, width: 2.0), // Borde azul más notorio al enfocar
      ),
      errorBorder: OutlineInputBorder(
        // Borde cuando hay un error
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: categoryRed, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        // Borde de error cuando enfocado
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: categoryRed, width: 2.0),
      ),
      filled: true, // Fondo para los campos de entrada
      fillColor: inputFillColor, // Color de fondo para los campos de entrada
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 20.0, vertical: 15.0), // Padding interno
      labelStyle: const TextStyle(
          color: textMedium, fontFamily: 'Inter'), // Estilo del label
      hintStyle: const TextStyle(
          color: textMedium, fontFamily: 'Inter'), // Estilo del hint
    ),

    // Configuración de las tarjetas (Card)
    cardTheme: CardTheme(
      elevation: 4, // Sombra sutil
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Bordes más redondeados
      ),
      margin: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 8.0), // Margen exterior
      color: Colors.white, // Fondo de las tarjetas
    ),

    // Configuración del FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentBlue, // Un azul de acento para el FAB
      foregroundColor: Colors.white, // Icono blanco
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(16.0)), // Bordes redondeados
      ),
    ),

    // Configuración de la barra de navegación inferior (BottomNavigationBar)
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white, // Fondo blanco
      selectedItemColor: primaryBlue, // Ítem seleccionado en azul
      unselectedItemColor: textMedium, // Ítem no seleccionado en gris
      elevation: 8, // Sombra
      type: BottomNavigationBarType.fixed, // Asegura que los ítems no se muevan
      selectedLabelStyle: TextStyle(
          fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
      unselectedLabelStyle: TextStyle(fontSize: 12, fontFamily: 'Inter'),
    ),

    // Configuración general de la tipografía (TextTheme)
    // Usamos 'copyWith' para asegurar que el TextTheme predeterminado de Material sea la base
    // y solo modificamos lo necesario, como la fuente y el color.
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Inter'),
      displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Inter'),
      displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Inter'),
      headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Inter'),
      headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Inter'),
      headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Inter'),
      titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Inter'),
      titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Inter'),
      titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textDark,
          fontFamily: 'Inter'),
      bodyLarge: TextStyle(fontSize: 16, color: textDark, fontFamily: 'Inter'),
      bodyMedium: TextStyle(fontSize: 14, color: textDark, fontFamily: 'Inter'),
      bodySmall:
          TextStyle(fontSize: 12, color: textMedium, fontFamily: 'Inter'),
      labelLarge: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter'),
      labelMedium:
          TextStyle(fontSize: 12, color: Colors.white, fontFamily: 'Inter'),
      labelSmall:
          TextStyle(fontSize: 11, color: textMedium, fontFamily: 'Inter'),
    ),
  );
}
