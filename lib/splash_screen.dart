import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'main_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentIntro = 1;
  @override
  void initState() {
    super.initState();
    _startAnimations();
  }
  void _startAnimations() {
    Timer(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() {
          _currentIntro = 2;
        });
        Timer(const Duration(seconds: 5), _checkLoginStatus);
      }
    });
  }
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => token != null ? const MainScreen() : const LoginScreen(),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          _currentIntro == 1 ? 'lib/assets/animations/intro1.json' : 'lib/assets/animations/intro2.json',
          fit: BoxFit.contain,
          width: MediaQuery.of(context).size.width * 0.8,
        ),
      ),
    );
  }
}