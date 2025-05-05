import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pet_feeder_app/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(options: const FirebaseOptions(apiKey: "AIzaSyCoLwXMz04ou3MYfVUnKGwgcsaOjdfwTbU", authDomain: "pet-feeding-app.firebaseapp.com", projectId: "pet-feeding-app", storageBucket: "pet-feeding-app.firebasestorage.app", messagingSenderId: "636449180603", appId: "1:636449180603:web:62168e36f05d6c2b94d29e", measurementId: "G-G11D4Y0XVX"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Feeder App',
      // Use onGenerateRoute for dynamic route generation
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: AppRoutes.login, // Set the initial route
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.grey,
          onSecondary: Colors.black,
          background: Colors.white,
          onBackground: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
          error: Colors.red,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white, // For title and icons
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.black,
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(), // Add default border
        ),
        useMaterial3: true,
      ),
      // Remove the home property when using initialRoute and onGenerateRoute
      // home: const LoginScreen(),
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}

// Remove the default MyHomePage code

