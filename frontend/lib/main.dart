import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';

void main() {
  // TODO: Uygulama başlangıcında kullanıcının token'ını kontrol et.
  // Eğer geçerli bir token varsa doğrudan ana ekrana (HomeScreen) yönlendir.
  // Yoksa LoginScreen'e yönlendir.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yeşil Yol',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(), 
    );
  }
}
