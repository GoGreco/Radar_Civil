import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const RadarCivilApp());
}

class RadarCivilApp extends StatelessWidget {
  const RadarCivilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radar Civil',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F8F63),
        ),

        scaffoldBackgroundColor: const Color(
          0xFFF8F8F8,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4F8F63),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),

        elevatedButtonTheme:
            ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      home: const HomeScreen(),
    );
  }
}