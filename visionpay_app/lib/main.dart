import 'package:flutter/material.dart';
import 'theme/colors.dart';
import 'screens/landing_screen.dart';

void main() {
  runApp(const VisionPayApp());
}

class VisionPayApp extends StatelessWidget {
  const VisionPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VisionPay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          background: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const LandingScreen(),
    );
  }
}