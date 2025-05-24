// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // For localization
import 'package:untitled1/screens/home_screen.dart'; // Or your actual project name if different

void main() {
  // Ensure that widget binding is initialized if you need to perform
  // async operations before runApp, though not strictly needed here.
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Championnat', // The title of your application
      theme: ThemeData(
        primarySwatch: Colors.indigo, // You can choose any MaterialColor
        // You can customize other theme properties here:
        // visualDensity: VisualDensity.adaptivePlatformDensity,
        // appBarTheme: AppBarTheme(
        //   backgroundColor: Colors.teal,
        //   elevation: 4.0,
        // ),
        // floatingActionButtonTheme: FloatingActionButtonThemeData(
        //   backgroundColor: Colors.orange,
        // ),
        // elevatedButtonTheme: ElevatedButtonThemeData(
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.indigoAccent,
        //     foregroundColor: Colors.white,
        //   ),
        // ),
      ),
      debugShowCheckedModeBanner: false, // Set to true if you want the debug banner

      // --- Localization Setup (for DatePicker in French, etc.) ---
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English, no country code
        const Locale('fr', ''), // French, no country code
        // Add other locales your app supports
      ],
      // Optionally, set a default locale if needed, though Flutter usually picks
      // the system locale if it's in supportedLocales.
      // locale: Locale('fr', ''),

      // --- Initial Screen ---
      home: HomeScreen(), // This is the first screen your app will show
    );
  }
}