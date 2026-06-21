import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  Color g = const Color(0xFF0D6B58);
  Color h = const Color(0xFFE2F3E8);
  int userPoints = 0;
  int nextMilestone = 1000;
  int pointsLeft = 1000;
  List<dynamic> rewards = [];
  bool isLoading = true;
  final TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String un = prefs.getString('username') ?? "";

    try {
      var response = await http.get(Uri.parse('${ApiConstants.baseUrl}/rewards/?username=$un'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          rewards = data['rewards'] ?? [];
          userPoints = data['user_points'] ?? 0;
          nextMilestone = data['next_milestone'] ?? 1000;
          pointsLeft = data['points_left'] ?? 1000;
          isLoading = false;
        });
        await prefs.setInt('points', userPoints);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  IconData _getRewardIcon(String title) {
    String t = title.toLowerCase();
    if (t.contains('coffee')) return Icons.local_cafe_outlined;
    if (t.contains('voucher')) return Icons.shopping_cart_outlined;
    if (t.contains('ticket') || t.contains('movie')) return Icons.confirmation_num_outlined;
    if (t.contains('grocery') || t.contains('groceries')) return Icons.shopping_bag_outlined;
    return Icons.card_giftcard;
  }

  Future<void> _redeemReward(int rewardId, int cost) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Item Price', style: TextStyle(color: g)),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'e.g. 500',
              filled: true,
              fillColor: h,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                priceController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                String priceStr = priceController.text;
                Navigator.pop(context);
                if (priceStr.isEmpty) return;

                try {
                  var response = await http.post(
                    Uri.parse('${ApiConstants.baseUrl}/redeem-reward/'),
                    headers: {
                      "Content-Type": "application/json",
                      "Authorization": "Token $token"
                    },
                    body: jsonEncode({
                      "reward_id": rewardId,
                      "original_price": double.parse(priceStr)
                    }),
                  );

                  if (response.statusCode == 200) {
                    var respData = jsonDecode(response.body);
                    await prefs.setInt('points', respData['new_points']);
                    priceController.clear();
                    _fetchData();

                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Success!', style: TextStyle(color: Colors.green)),
                          content: Text('Discount applied.\nOriginal: ${respData['original_price']} EGP\nFinal Price: ${respData['final_price']} EGP'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
                          ],
                        ),
                      );
                    }
                  } else {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to redeem')));
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: g),
              child: const Text('Apply Discount', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext c) {
    double prg = 0.0;
    if (nextMilestone > 0) {
      int prevMilestone = nextMilestone - 1000;
      int pointsInCurrentLevel = userPoints - prevMilestone;
      prg = (pointsInCurrentLevel / 1000).clamp(0.0, 1.0);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rewards', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: g)),
              const SizedBox(height: 4),
              const Text('Redeem your eco-points', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: g, borderRadius: BorderRadius.circular(16)),
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
                      children: [
                        const Text('Next milestone', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('$nextMilestone pts', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: prg,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 12),
                    Text('$pointsLeft points left until the next 1000 milestone', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Available Rewards', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: g)),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: g))
                    : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: rewards.length,
                  itemBuilder: (c, i) {
                    var x = rewards[i];
                    int cost = x['cost'] ?? 0;
                    int reqPoints = x['required_points'] ?? 0;
                    bool isUnlocked = x['status'] == 'redeem';

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: g, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: h, borderRadius: BorderRadius.circular(12)),
                            child: Icon(_getRewardIcon(x['name'] ?? ''), color: g, size: 28),
                          ),
                          const Spacer(),
                          Text(x['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(x['description'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$cost pts', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              GestureDetector(
                                onTap: isUnlocked ? () => _redeemReward(x['id'], cost) : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isUnlocked ? h : Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isUnlocked ? 'Redeem' : 'Locked',
                                    style: TextStyle(
                                      color: isUnlocked ? g : Colors.white54,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
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