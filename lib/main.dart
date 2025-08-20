import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja Supabase
  await Supabase.initialize(
    url: 'https://bicxarcthyuwrehjsqny.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpY3hhcmN0aHl1d3JlaGpzcW55Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1NTM5MzIsImV4cCI6MjA2OTEyOTkzMn0.Cu3WoCTBLcXfUFrz5srVaqOBJBahXzHGz6PP8siHgE4',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitolongo',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
