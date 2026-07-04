import 'package:flutter/material.dart';

import '../features/converter/converter_screen.dart';
import 'app_theme.dart';

class DbKonversorApp extends StatelessWidget {
  const DbKonversorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dB Konversor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ConverterScreen(),
    );
  }
}