import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doa_roupa/tela/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kmkqkopnnkqwuffqgiay.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtta3Frb3Bubmtxd3VmZnFnaWF5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk1MDM0OTYsImV4cCI6MjA1NTA3OTQ5Nn0.zwsMaYcOILH2iIo2Qoh_hziGnhihbpmIhiExp9tuzIo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doação de Roupas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Login(),
    );
  }
}
