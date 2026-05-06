import 'package:flutter/material.dart';
import 'package:little_forest/theme/app_theme.dart';
import 'package:little_forest/screens/main_screen.dart';

void main() {
  runApp(const LittleForestApp());
}

class LittleForestApp extends StatelessWidget {
  const LittleForestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Little Forest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainScreen(),
    );
  }
}