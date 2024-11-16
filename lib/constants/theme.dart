import 'package:flutter/material.dart';

class AppColors {
  static const Color lightGreen = Color(0xFFDDFCAD);
  static const Color paleGreen = Color(0xFFC8E087);
  static const Color oliveGreen = Color(0xFF95A472);
  static const Color greenishGrey = Color(0xFF82846D);
  static const Color darkGrey = Color(0xFF646165);
  static Color orangeBG = Colors.orange.shade300;
  static Color orangeButton = Colors.orange.shade800;
}

class AppFonts {
  static const String titleFontFamily = 'Sifonn';
  static const String textFontFamily = 'Poppins';
}

class AppButtonStyles {
  // Style de bouton pour les boutons Elevés
  static ButtonStyle elevatedButtonStyle = ButtonStyle(
    minimumSize: WidgetStateProperty.all<Size>(const Size(150, 40)),
    backgroundColor: WidgetStateProperty.all<Color>(AppColors.darkGrey),
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
    color: AppColors.darkGrey,
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
    color: AppColors.darkGrey,
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
    color: AppColors.oliveGreen,
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
    color: AppColors.darkGrey,
  );
}

class AppTheme {
  static ThemeData defaultTheme = ThemeData(
    primaryColor: AppColors.lightGreen,
    highlightColor: AppColors.paleGreen,
    // Définissez d'autres attributs de thème selon vos besoins
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.titleDarkStyle,
      bodyLarge: AppTextStyles.paragraphDarkStyle,
      bodySmall: AppTextStyles.hintTextDarkStyle,
      labelLarge: AppTextStyles.buttonDarkStyle,
    ),
  );
}
