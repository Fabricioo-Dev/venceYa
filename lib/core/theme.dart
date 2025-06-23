// lib/core/theme.dart
import 'package:flutter/material.dart';

/// Clase que centraliza toda la configuración de diseño y estilo de la aplicación.
/// Tener un tema centralizado asegura una apariencia consistente en todas las pantallas.
class AppTheme {
  // --- PALETA DE COLORES PRINCIPAL ---
  // Se definen todos los colores de la app como constantes estáticas para poder
  // reutilizarlos fácilmente en cualquier parte del código.
  static const Color primaryBlue =
      Color(0xFF3F51B5); // El azul principal de la marca.
  static const Color accentBlue =
      Color(0xFF4285F4); // Un azul secundario para acentos y botones.

  // Colores de UI
  static const Color backgroundLight =
      Color(0xFFF5F5F5); // Fondo general de las pantallas.
  static const Color inputFillColor =
      Color(0xFFE0E0E0); // Fondo de los campos de texto.

  // Colores de Texto
  static const Color textDark =
      Color(0xFF212121); // Para títulos y texto principal (casi negro).
  static const Color textMedium =
      Color(0xFF757575); // Para subtítulos o texto secundario.

  // Colores de Categorías
  static const Color categoryRed = Color(0xFFF44336);
  static const Color categoryBlue = Color(0xFF2196F3);
  static const Color categoryGreen = Color(0xFF4CAF50);
  static const Color categoryPurple = Color(0xFF9C27B0);
  static const Color categoryLightGrey = Color(0xFF9E9E9E);

  /// El objeto ThemeData que contiene toda la configuración de estilo para el modo claro.
  static final ThemeData lightTheme = ThemeData(
    // Define el brillo general del tema.
    brightness: Brightness.light,

    // --- ESQUEMA DE COLOR (ColorScheme) ---
    // El `colorScheme` es la forma moderna de definir los colores principales.
    // Muchos widgets de Flutter usan estos valores por defecto.
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue, // Color principal (botones, appbars).
      secondary:
          accentBlue, // Color de acento (FloatingActionButtons, switches).
      error: categoryRed, // Color para mensajes de error.
      // `onSurface` es el color del texto sobre fondos como el del calendario.
      // El sistema le baja la opacidad automáticamente para los días deshabilitados,
      // logrando el efecto gris que querías.
      onSurface: textDark,
    ),

    // Define la fuente principal para toda la aplicación.
    // NOTA: Asegúrate de que la fuente 'Inter' esté configurada en `pubspec.yaml`.
    fontFamily: 'Inter',

    // Color de fondo por defecto para todas las pantallas (`Scaffold`).
    scaffoldBackgroundColor: backgroundLight,

    // --- ESTILOS ESPECÍFICOS PARA WIDGETS ---

    // Configuración para todas las AppBars.
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, // Fondo transparente por defecto.
      elevation: 0, // Sin sombra.
      foregroundColor: textDark, // Color para el título y los íconos.
    ),

    // Configuración para todos los ElevatedButton.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
    ),

    // Configuración para todos los campos de texto (TextFormField).
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
        borderSide: const BorderSide(color: categoryRed, width: 2.0),
      ),
    ),

    // Configuración para todas las Cards.
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
    ),

    // Configuración para el FloatingActionButton.
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentBlue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
    ),

    // Configuración para la BottomNavigationBar.
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryBlue,
      unselectedItemColor: textMedium,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    // Configuración para el selector de fecha (DatePicker).
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: Colors.white,
      headerBackgroundColor: primaryBlue,
      headerForegroundColor: Colors.white,
      todayForegroundColor: MaterialStatePropertyAll(primaryBlue),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
    ),

    // Configuración para el selector de hora (TimePicker).
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

    // Configuración de los estilos de texto.
    // Se hereda la fuente 'Inter' definida globalmente.
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
