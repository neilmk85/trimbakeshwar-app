import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryMedium = Color(0xFF1E88E5);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryLighter = Color(0xFF64B5F6);

  // Accent
  static const Color navyDeep = Color(0xFF1A237E);

  // Neutrals
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);

  // Splash Gradient
  static const List<Color> splashGradient = [
    primaryDark,
    primary,
    primaryMedium,
    primaryLight,
    primaryLighter,
  ];

  // AppBar / Drawer Gradient
  static const List<Color> appBarGradient = [primaryDark, primaryMedium];

  // Pooja Card Colors
  static const Color poojaBlue = Color(0xFF1565C0);
  static const Color poojaTeal = Color(0xFF00838F);
  static const Color poojaPurple = Color(0xFF4527A0);
  static const Color poojaGreen = Color(0xFF2E7D32);
  static const Color poojaRed = Color(0xFFC62828);
  static const Color poojaOrange = Color(0xFFEF6C00);
  static const Color poojaDeepPurple = Color(0xFF6A1B9A);
  static const Color poojaDarkTeal = Color(0xFF00695C);

  // Social
  static const Color whatsapp = Color(0xFF25D366);
  static const Color googleRed = Color(0xFFEA4335);
  static const Color googleYellow = Color(0xFFFBBC04);
  static const Color facebook = Color(0xFF1877F2);
  static const Color instagram = Color(0xFFE4405F);
  static const Color youtube = Color(0xFFFF0000);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color emailPurple = Color(0xFF7B1FA2);
  static const Color webBlue = Color(0xFF0288D1);
}
