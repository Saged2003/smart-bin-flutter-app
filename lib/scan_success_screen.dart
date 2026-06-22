import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:async';

class ScanSuccessScreen extends StatefulWidget {
  const ScanSuccessScreen({super.key});
  @override
  State<ScanSuccessScreen> createState() => _ScanSuccessScreenState();
}

class _ScanSuccessScreenState extends State<ScanSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      if (mounted) Navigator.pop(context);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('lib/assets/animations/after_scan_qr_code_succesfully.json', fit: BoxFit.contain, width: MediaQuery.of(context).size.width * 0.8),
            const SizedBox(height: 20),
            Text('bin_unlocked'.tr(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D6B58))),
          ],
        ),
      ),
    );
  }
}