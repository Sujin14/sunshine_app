import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/sunshine_provider.dart';
import 'views/sunshine_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SunshineProvider()..fetchData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sunshine Insights',
      theme: ThemeData(
        primaryColor: const Color(0xFFFFD700),
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: 'Roboto',
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const SunshinePage(),
    );
  }
}