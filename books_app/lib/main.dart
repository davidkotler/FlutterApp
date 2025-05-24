import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // created by `flutterfire configure`
import 'package:supabase_flutter/supabase_flutter.dart';

/// db pass = David_Idan_android

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://zkaqetvfywfgztvnmjam.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprYXFldHZmeXdmZ3p0dm5tamFtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5NzU4MzUsImV4cCI6MjA2MzU1MTgzNX0.d99O2MDsiJTQvQPheKmgjhndfW75XT3A2kmTp_wMKDM',
  );

  runApp(const BookApp());
}

class BookApp extends StatelessWidget {
  const BookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const WelcomePage(),
    );
  }
}
