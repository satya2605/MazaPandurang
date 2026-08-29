import 'package:flutter/material.dart';

/// Central color palette for the Maza Pandurang application.
abstract class AppColors {
  /// Primary warm orange action color (Saffron/Devotional Theme)
  static const Color primary = Color(0xFFE65100);
  static const Color primaryLight = Color(0xFFFF9800);
  static const Color primaryDark = Color(0xFFBF360C);

  /// Surface & Backgrounds
  static const Color background = Color(0xFFFAF9F6);
  static const Color surface = Color(0xFFFFFFFF);

  /// Borders & Dividers
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  /// Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textMuted = Color(0xFF9E9E9E);

  /// Role Card Accent Palette
  static const Color pilgrimAccent = Color(0xFFE65100);
  static const Color dindiAccent = Color(0xFFD84315);
  static const Color ngoAccent = Color(0xFF2E7D32);
  static const Color policeAccent = Color(0xFF1565C0);
  static const Color citizenAccent = Color(0xFF6A1B9A);
}
