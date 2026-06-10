import 'package:flutter/material.dart';

void main() {
  runApp(const MandiApp());
}

class MandiApp extends StatelessWidget {
  const MandiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mandi Intelligence',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mandi Intelligence'),
        ),
        body: const Center(
          child: Text(
            'Flutter Setup Successful 🚀',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}