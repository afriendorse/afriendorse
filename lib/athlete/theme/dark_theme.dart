import 'package:flutter/material.dart';

import 'custom_theme_colors.dart';

ThemeData dark = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: const Color(0xFF045F25),
  primaryColorLight: const Color(0xFFCBCACA),
  primaryColorDark: const Color(0xFF045F25),
  scaffoldBackgroundColor: const Color(0xFF010d15),
  cardColor: const Color(0xff0c131e),

  shadowColor: const Color(0xFF4a5361),
  canvasColor: const Color(0xFF045F25),

  secondaryHeaderColor: const Color(0xFF8797AB),
  disabledColor: const Color(0xFF484848),
  brightness: Brightness.dark,
  hintColor: const Color(0xFF7F7C7C),
  focusColor: const Color(0xFF383838),
  hoverColor: const Color(0xFFABA9A7),
  timePickerTheme: const TimePickerThemeData(
    backgroundColor: Color(0xFF10324a),
  ),
  datePickerTheme: const DatePickerThemeData(
    backgroundColor: Color(0xFF10324a),
  ),
  extensions: <ThemeExtension<CustomThemeColors>>[CustomThemeColors.dark()],
  colorScheme:
      const ColorScheme.dark(
            primary: Color(0xFF045F25),
            secondary: Color(0xFF045F25),
            onSecondaryContainer: Color(0xFF3E9665),
            tertiary: Color(0xffe78c35),
            onTertiary: Color(0xffe8b41d),
          )
          .copyWith(surface: const Color(0xFF010d15))
          .copyWith(error: const Color(0xFFdd3135)),

  dividerTheme: const DividerThemeData(thickness: 0.5),
);
