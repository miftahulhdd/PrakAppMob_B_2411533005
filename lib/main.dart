import 'package:flutter/material.dart';
import 'user_registration_form.dart';

// Entry point App
void main() {
  runApp(const MyApp());
}

// Root widget aplikasi, use MaterialApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Registration Form',
      debugShowCheckedModeBanner: false,
      home: const UserRegistrationForm(),
    );
  }
}