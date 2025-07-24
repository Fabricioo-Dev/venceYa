// lib/core/theme.dart
import 'package:flutter/material.dart';

/// Centraliza la configuración de diseño para asegurar una UI consistente.
/// Usar una clase de tema evita repetir código de estilo y facilita
/// realizar cambios de diseño en toda la app desde un solo lugar.
class AppTheme {
  // --- PALETA DE COLORES ---
  // Se definen como `static const` para poder acceder a ellos desde cualquier
  // parte de la app (ej: `AppTheme.primaryBlue`) sin crear una instancia.

  // Colores de Marca
  static const Color primaryBlue = Color(0xFF3F51B5);
  static const Color accentBlue = Color(0xFF4285F4);

  // Colores de UI
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color inputFillColor = Color(0xFFE0E0E0);

  // Colores de Texto
  static const Color textDark = Color(0xFF212121);
  static const Color textMedium = Color(0xFF757575);

  // Colores de Estado o Categoría
  static const Color statusError = Color(0xFFF44336);
  static const Color categoryBlue = Color(0xFF2196F3);
  static const Color categoryGreen = Color(0xFF4CAF50);
  static const Color categoryPurple = Color(0xFF9C27B0);
  static const Color categoryLightGrey = Color(0xFF9E9E9E);

  /// Define el tema principal de la aplicación para el modo claro.
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Inter', // Fuente por defecto para toda la app.

    // El `colorScheme` es la forma moderna de definir la paleta de colores.
    // Usar `ColorScheme.fromSeed` es una buena práctica porque genera
    // automáticamente una paleta armoniosa de colores relacionados
    // (tonos más claros, más oscuros, etc.) a partir de un solo color semilla.
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
      secondary: accentBlue,
      error: statusError,
      onSurface: textDark,
    ),

    // --- ESTILOS GLOBALES PARA WIDGETS ---

    scaffoldBackgroundColor: backgroundLight,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: textDark,
    ),

    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      // AJUSTE: Quitamos el margen del tema. Es mejor práctica controlar
      // el espaciado en la lista (ListView) que en el tema del Card.
      // Esto da más flexibilidad al diseño de cada pantalla.
      margin:
          const EdgeInsets.symmetric(vertical: 6.0), // Margen vertical sutil
      color: Colors.white,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          // La fuente 'Inter' y el color ya son heredados, no hace falta repetirlos.
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: inputFillColor,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      labelStyle: const TextStyle(color: textMedium),
      hintStyle: const TextStyle(color: textMedium),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: accentBlue, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: statusError, width: 2.0),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentBlue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryBlue,
      unselectedItemColor: textMedium,
      elevation: 8,
      // `fixed` asegura que todos los ítems de la barra tengan su label
      // visible siempre, incluso si no están seleccionados.
      type: BottomNavigationBarType.fixed,
    ),

    datePickerTheme: const DatePickerThemeData(
      backgroundColor: Colors.white,
      headerBackgroundColor: primaryBlue,
      headerForegroundColor: Colors.white,
      todayForegroundColor: MaterialStatePropertyAll(primaryBlue),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
    ),

    timePickerTheme: const TimePickerThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      hourMinuteShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      dayPeriodBorderSide: BorderSide(color: primaryBlue),
      dialHandColor: primaryBlue,
    ),

    textTheme: const TextTheme(
      displayLarge:
          TextStyle(fontSize: 57, fontWeight: FontWeight.bold, color: textDark),
      headlineMedium:
          TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
      titleLarge:
          TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark),
      titleMedium:
          TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
      bodyLarge: TextStyle(fontSize: 16, color: textDark),
      bodyMedium: TextStyle(fontSize: 14, color: textDark),
      bodySmall: TextStyle(fontSize: 12, color: textMedium),
      labelLarge: TextStyle(
          fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}
