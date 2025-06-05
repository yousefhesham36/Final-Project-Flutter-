import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'constants/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tanta Shop',
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryBlue,
          secondary: AppColors.secondaryBlue,
        ),
        scaffoldBackgroundColor: AppColors.black87,
      ),
      home: const SplashScreen(),
    );
  }
}
