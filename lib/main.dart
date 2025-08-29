import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'models/sunshine_provider.dart';
import 'views/sunshine_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SunshineProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sunshine App',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme().apply(
          fontFamilyFallback: const ['NotoSans'],
        ),
        useMaterial3: true,
      ),
      home: const SunshinePage(),
    );
  }
}
