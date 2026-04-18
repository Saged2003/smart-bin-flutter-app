import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  Color g = const Color(0xFF0D6B58);
  Color h = const Color(0xFFE2F3E8);
  int userPoints = 0;
  List<dynamic> rewards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => userPoints = prefs.getInt('points') ?? 0);

    try {
      var response = await http.get(Uri.parse('http://10.0.2.2:8000/api/rewards/'));
      if (response.statusCode == 200) {
        setState(() {
          rewards = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  IconData _getRewardIcon(String title) {
    String t = title.toLowerCase();
    if (t.contains('coffee')) return Icons.local_cafe_outlined;
    if (t.contains('voucher')) return Icons.shopping_cart_outlined;
    if (t.contains('movie')) return Icons.confirmation_num_outlined;
    if (t.contains('grocery') || t.contains('groceries')) return Icons.shopping_bag_outlined;
    return Icons.card_giftcard;
  }

  @override
  Widget build(BuildContext c) {
    double progress = (userPoints / 1000).clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rewards',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: g),
              ),
              const SizedBox(height: 4),
              const Text(
                'Redeem your eco-points',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: g,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Available Points', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Icon(Icons.card_giftcard, color: Colors.white, size: 28),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('$userPoints', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Next milestone', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('1000 pts', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Available Rewards',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: g),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: g))
                    : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: rewards.length,
                  itemBuilder: (c, i) {
                    var x = rewards[i];
                    bool canRedeem = userPoints >= (x['v'] ?? 0);
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: g,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: h,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_getRewardIcon(x['n'] ?? ''), color: g, size: 28),
                          ),
                          const Spacer(),
                          Text(x['n'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(x['s'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${x['v']} pts', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: canRedeem ? h : Colors.white24,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  canRedeem ? 'Redeem' : 'Locked',
                                  style: TextStyle(
                                    color: canRedeem ? g : Colors.white38,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}