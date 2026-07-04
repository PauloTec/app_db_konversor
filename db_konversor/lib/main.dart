import 'package:flutter/material.dart';

import 'features/splash/splash_screen.dart';

void main() {
  runApp(const DbKonversorApp());
}

class DbKonversorApp extends StatelessWidget {
  const DbKonversorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'dB Konversor',

      theme: ThemeData(
        useMaterial3: true,
      ),

      home: const SplashScreen(),
    );
  }
}