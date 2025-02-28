import 'package:elgumailer/color_theme.dart';
import 'package:elgumailer/ui/screens/login_screen.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eLGU Mailer',
      theme: ThemeData(
          primarySwatch: customThemePrimary,
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color(0xFF002091),
            selectionColor: Color(0xFF002091),
            selectionHandleColor: Color(0xFF002091),
          )
      ),
      home: const LoginScreen(),
    );
  }
}
