import 'package:flutter/material.dart';

const MaterialColor customThemePrimary = MaterialColor(_customThemePrimaryValue, <int, Color>{
  50: Color(0xFFE0E7FC),  // Lightest shade
  100: Color(0xFFB3C2F8), // Lighter shade
  200: Color(0xFF8098F3), // Light shade
  300: Color(0xFF4D6EED), // Light-medium shade
  400: Color(0xFF264DE9), // Medium shade
  500: Color(_customThemePrimaryValue), // Primary color
  600: Color(0xFF0136C2), // Slightly darker
  700: Color(0xFF012CAB), // Darker
  800: Color(0xFF012394), // Even darker
  900: Color(0xFF011773), // Darkest shade
});
const int _customThemePrimaryValue = 0xFF013DD6;

const MaterialColor customThemeAccent = MaterialColor(_customThemeAccentValue, <int, Color>{
  100: Color(0xFFD6E0FF), // Light accent shade
  200: Color(_customThemeAccentValue), // Accent color
  400: Color(0xFF8094FF), // Stronger accent
  700: Color(0xFF4D68FF), // Boldest accent
});
const int _customThemeAccentValue = 0xFFB3C6FF;
