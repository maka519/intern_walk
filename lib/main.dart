import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home.dart';

final formatter = NumberFormat("#,###");
// --- アプリケーションのエントリーポイント ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
