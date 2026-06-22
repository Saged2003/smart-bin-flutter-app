import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';

class RewardsProvider extends ChangeNotifier {
  int userPoints = 0;
  int nextMilestone = 1000;
  int pointsLeft = 1000;
  List<dynamic> rewards = [];
  bool isLoading = true;
  bool isOffline = false;
  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? "";
    String? cachedRewards = prefs.getString('cached_rewards');
    if (cachedRewards != null) {
      var data = jsonDecode(cachedRewards);
      rewards = data['rewards'] ?? [];
      userPoints = data['user_points'] ?? prefs.getInt('points') ?? 0;
      nextMilestone = data['next_milestone'] ?? 1000;
      pointsLeft = data['points_left'] ?? 1000;
      notifyListeners();
    }
    try {
      var response = await http.get(Uri.parse('${ApiConstants.baseUrl}/rewards/?username=$username')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        prefs.setString('cached_rewards', response.body);
        rewards = data['rewards'] ?? [];
        userPoints = data['user_points'] ?? 0;
        nextMilestone = data['next_milestone'] ?? 1000;
        pointsLeft = data['points_left'] ?? 1000;
        isLoading = false;
        isOffline = false;
        await prefs.setInt('points', userPoints);
      } else {
        isLoading = false;
        isOffline = true;
      }
    } catch (error) {
      isLoading = false;
      isOffline = true;
    }
    notifyListeners();
  }
  Future<bool> redeemReward(int rewardId, int cost) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      var response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/redeem-reward/'),
        headers: {"Content-Type": "application/json", "Authorization": "Token $token"},
        body: jsonEncode({"reward_id": rewardId, "original_price": 100}),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        var respData = jsonDecode(response.body);
        await prefs.setInt('points', respData['new_points']);
        await fetchData();
        return true;
      }
    } catch (error) {
      throw Exception('Network Error');
    }
    return false;
  }
}