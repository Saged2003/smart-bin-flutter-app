import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences s = await SharedPreferences.getInstance();
  String? t = s.getString('token');

  runApp(MyApp(l: t != null));
}

class MyApp extends StatelessWidget {
  final bool l;

  const MyApp({super.key, required this.l});

  @override
  Widget build(BuildContext c) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Waste Bin',
      theme: ThemeData(fontFamily: 'Arial'),
      home: l ? const MainScreen() : const LoginScreen(),
    );
  }
}