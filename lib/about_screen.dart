import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Color g = const Color(0xFF0D6B58);
    Color h = const Color(0xFFE2F3E8);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Column(
                      children: [
                        Text('EcoBin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: h, shape: BoxShape.circle),
                          child: Icon(Icons.track_changes, color: g, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Text('Our Mission', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'EcoBin is revolutionizing waste management by making recycling rewarding and accessible. We believe that every small action counts in building a sustainable future for our planet.',
                      style: TextStyle(height: 1.6, color: Colors.black87, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text('How It Works', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    _s(h, g, '1', 'Create Your Account', 'Sign up and get your unique QR code instantly'),
                    const SizedBox(height: 24),
                    _s(h, g, '2', 'Find a Smart Bin', 'Locate nearby EcoBins using our bin status map'),
                    const SizedBox(height: 24),
                    _s(h, g, '3', 'Scan & Deposit', 'Scan your QR code and deposit your recyclables'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _s(Color bg, Color tc, String n, String t, String d) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: bg,
          radius: 18,
          child: Text(n, style: TextStyle(color: tc, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Text(d, style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}