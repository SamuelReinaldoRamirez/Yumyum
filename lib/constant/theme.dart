import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundColor = Color(0xFFF1E8D2); // Blanc cassé
  static const Color primaryColor = Color(0xFFA3C8D9); // Bleu pastel
  static const Color secondaryColor = Color(0xFF3A7BB7); // Bleu foncé
  static const Color textColor = Color(0xFF4A4A4A); // Gris très clair

  // Couleurs pour les ombres
  static const Color shadowColor = Color(0xFF000000); // Noir

  // Couleurs pour les bordures
  static const Color borderColor = Color(0xFF000000); // Noir

  static const Color appBackground = Color(0xFFF1E8D2); // Nouveau nom
  static const Color appPrimary = Color(0xFFA3C8D9); // Nouveau nom
  static const Color appSecondary = Color(0xFF3A7BB7); // Nouveau nom
  static const Color appText = Color(0xFF4A4A4A); // Nouveau nom

  static const Color darkGrey = Color(0xFF646165);
}

class AppFonts {
  static const String titleFontFamily = 'PlayfairDisplay';
  static const String textFontFamily = 'SourceSansPro';
}

class AppButtonStyles {
  // Style de bouton pour les boutons Elevés
  static ButtonStyle elevatedButtonStyle = ButtonStyle(
    minimumSize: WidgetStateProperty.all<Size>(const Size(150, 40)),
    backgroundColor: WidgetStateProperty.all<Color>(AppColors.appSecondary),
    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
    textStyle: WidgetStateProperty.all<TextStyle>(
      const TextStyle(
        fontFamily: AppFonts.textFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    ),
    shape: WidgetStateProperty.all<OutlinedBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  );
}

class AppTextStyles {
  // Style de texte pour les titres (blanc et sombre)
  static const TextStyle titleWhiteStyle = TextStyle(
    fontFamily: AppFonts.titleFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle titleDarkStyle = TextStyle(
    fontFamily: AppFonts.titleFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.appSecondary,
  );

  static const TextStyle titleBlackStyle = TextStyle(
    fontFamily: AppFonts.titleFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.appText,
  );

  static TextStyle titleBlueStyle = TextStyle(
    color: Colors.blue,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // Style de texte pour les paragraphes (blanc et sombre)
  static const TextStyle paragraphWhiteStyle = TextStyle(
    fontFamily: AppFonts.textFontFamily,
    fontSize: 16,
    color: Colors.white,
  );

  static const TextStyle paragraphDarkStyle = TextStyle(
    fontFamily: AppFonts.textFontFamily,
    fontSize: 16,
    color: AppColors.appText,
  );

  // Style de texte pour les hints (blanc et sombre)
  static const TextStyle hintTextWhiteStyle = TextStyle(
    fontFamily: AppFonts.textFontFamily,
    fontSize: 13,
    color: Colors.white,
  );

  static const TextStyle hintTextDarkStyle = TextStyle(
    fontFamily: AppFonts.textFontFamily,
    fontSize: 13,
    color: AppColors.appSecondary,
  );

  // Style de texte pour les boutons (blanc et sombre)
  static const TextStyle buttonWhiteStyle = TextStyle(
    fontFamily: AppFonts.textFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle buttonDarkStyle = TextStyle(
    fontFamily: AppFonts.textFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.appSecondary,
  );

  static const double titleFontSize = 32.0; // Taille de police pour le titre
  static const double bodyFontSize =
      16.0; // Taille de police pour le corps du texte
}

class AppTheme {
  static ThemeData defaultTheme = ThemeData(
    primaryColor: AppColors.appPrimary,
    scaffoldBackgroundColor: AppColors.appBackground,
    colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: AppColors.appSecondary),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
          color: AppColors.appText,
          fontFamily: AppFonts.textFontFamily), // Texte principal
      bodyMedium: TextStyle(
          color: AppColors.appText,
          fontFamily: AppFonts.textFontFamily), // Texte secondaire
      titleLarge: TextStyle(
          color: AppColors.appPrimary,
          fontFamily: AppFonts.titleFontFamily), // Titre 1
      titleMedium: TextStyle(
          color: AppColors.appPrimary,
          fontFamily: AppFonts.titleFontFamily), // Titre 2
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.appPrimary,
      iconTheme: IconThemeData(color: AppColors.appText),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.appSecondary,
      textTheme: ButtonTextTheme.primary,
    ),
    // Ajoutez d'autres attributs de thème selon vos besoins
  );
}
