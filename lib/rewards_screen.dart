import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shimmer/shimmer.dart';
import 'api_constants.dart';
import 'animated_button.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  Color primaryColor = const Color(0xFF0D6B58);
  Color secondaryColor = const Color(0xFFE2F3E8);
  int userPoints = 0;
  int nextMilestone = 1000;
  int pointsLeft = 1000;
  List<dynamic> rewards = [];
  bool isLoading = true;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? "";

    String? cachedRewards = prefs.getString('cached_rewards');
    if (cachedRewards != null) {
      var data = jsonDecode(cachedRewards);
      setState(() {
        rewards = data['rewards'] ?? [];
        userPoints = data['user_points'] ?? prefs.getInt('points') ?? 0;
        nextMilestone = data['next_milestone'] ?? 1000;
        pointsLeft = data['points_left'] ?? 1000;
      });
    }

    try {
      var response = await http.get(Uri.parse('${ApiConstants.baseUrl}/rewards/?username=$username')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        prefs.setString('cached_rewards', response.body);

        setState(() {
          rewards = data['rewards'] ?? [];
          userPoints = data['user_points'] ?? 0;
          nextMilestone = data['next_milestone'] ?? 1000;
          pointsLeft = data['points_left'] ?? 1000;
          isLoading = false;
          isOffline = false;
        });
        await prefs.setInt('points', userPoints);
      } else {
        setState(() { isLoading = false; isOffline = true; });
      }
    } catch (error) {
      setState(() { isLoading = false; isOffline = true; });
    }
  }

  IconData _getRewardIcon(String title) {
    String titleString = title.toLowerCase();
    if (titleString.contains('coffee')) return Icons.local_cafe_outlined;
    if (titleString.contains('voucher') || titleString.contains('carrefour')) return Icons.shopping_cart_outlined;
    if (titleString.contains('ticket') || titleString.contains('movie')) return Icons.confirmation_num_outlined;
    if (titleString.contains('grocery') || titleString.contains('groceries')) return Icons.shopping_bag_outlined;
    return Icons.card_giftcard;
  }

  Future<void> _redeemReward(int rewardId, int cost) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      var response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/redeem-reward/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token"
        },
        body: jsonEncode({"reward_id": rewardId, "original_price": 100}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var respData = jsonDecode(response.body);
        await prefs.setInt('points', respData['new_points']);
        _fetchData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('reward_redeemed_successfully'.tr(), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('failed_to_redeem'.tr())));
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('network_error'.tr()), backgroundColor: Colors.orange));
    }
  }

  Widget _buildShimmerRewards() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = 0.0;
    if (nextMilestone > 0) {
      int prevMilestone = nextMilestone - 1000;
      int pointsInCurrentLevel = userPoints - prevMilestone;
      progress = (pointsInCurrentLevel / 1000).clamp(0.0, 1.0);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: _fetchData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('rewards'.tr(), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: primaryColor)),
                    if (isOffline) const Icon(Icons.cloud_off, color: Colors.orange),
                  ],
                ),
                const SizedBox(height: 4),
                Text('redeem_eco_points'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('available_points'.tr(), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          const Icon(Icons.card_giftcard, color: Colors.white, size: 30),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('$userPoints', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('next_milestone'.tr(), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          Text('$nextMilestone ${'pts'.tr()}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE2F3E8)),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('$pointsLeft ${'points_to_unlock'.tr()}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('available_rewards'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 16),

                isLoading && rewards.isEmpty
                    ? _buildShimmerRewards()
                    : rewards.isEmpty
                    ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("no_rewards_available".tr(), style: const TextStyle(color: Colors.grey))))
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    var rewardData = rewards[index];
                    int cost = rewardData['cost'] ?? 0;
                    bool isUnlocked = rewardData['status'] == 'redeem';

                    return AnimatedButton(
                      onTap: isUnlocked ? () => _redeemReward(rewardData['id'], cost) : () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('collect_more_points'.tr())));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(12)),
                              child: Icon(_getRewardIcon(rewardData['name'] ?? ''), color: primaryColor, size: 28),
                            ),
                            const Spacer(),
                            Text(rewardData['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(rewardData['subtitle'] ?? rewardData['description'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('$cost ${'pts'.tr()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isUnlocked ? secondaryColor : Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isUnlocked ? 'redeem'.tr() : 'locked'.tr(),
                                    style: TextStyle(
                                      color: isUnlocked ? primaryColor : Colors.white54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}