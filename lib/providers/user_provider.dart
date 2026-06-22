import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';

class UserProvider extends ChangeNotifier {
  String userName = "User";
  String fullName = "";
  String email = "";
  String phone = "";
  String address = "";
  String? profilePicUrl;
  int currentBalance = 0;
  int milestonePoints = 0;
  double totalWeight = 0.0;
  int deposits = 0;
  bool isEmployee = false; // تمت الإضافة
  bool isApprovedEmployee = false; // تمت الإضافة
  bool isOffline = false;
  bool isLoading = false;
  List<dynamic> recentActivities = [];

  Future<void> loadLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('username') ?? "User";
    fullName = prefs.getString('full_name') ?? "";
    email = prefs.getString('email') ?? "";
    phone = prefs.getString('phone') ?? "";
    address = prefs.getString('address') ?? "";
    profilePicUrl = prefs.getString('profile_picture');
    currentBalance = prefs.getInt('points') ?? 0;
    milestonePoints = prefs.getInt('milestone_points') ?? (currentBalance % 1000);
    totalWeight = prefs.getDouble('weight') ?? 0.0;
    deposits = prefs.getInt('deposits') ?? 0;
    isEmployee = prefs.getBool('is_employee') ?? false; // تمت الإضافة
    isApprovedEmployee = prefs.getBool('is_approved_employee') ?? false; // تمت الإضافة

    String? cachedActivities = prefs.getString('cached_recent_activities');
    if (cachedActivities != null) {
      recentActivities = jsonDecode(cachedActivities);
    }
    notifyListeners();
  }

  Future<void> fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    if (user == null) return;

    try {
      var response = await http.get(Uri.parse('${ApiConstants.baseUrl}/profile/?username=$user')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        userName = user;
        currentBalance = data['points'] ?? 0;
        milestonePoints = data['milestone_points'] ?? 0;
        totalWeight = (data['weight'] ?? 0.0).toDouble();
        deposits = data['deposits'] ?? 0;
        fullName = data['full_name'] ?? "";
        email = data['email'] ?? "";
        phone = data['phone'] ?? "";
        address = data['address'] ?? "";
        profilePicUrl = data['profile_picture'];
        isEmployee = data['is_employee'] ?? false; // تمت الإضافة
        isApprovedEmployee = data['is_approved_employee'] ?? false; // تمت الإضافة
        isOffline = false;

        await prefs.setInt('points', currentBalance);
        await prefs.setInt('milestone_points', milestonePoints);
        await prefs.setDouble('weight', totalWeight);
        await prefs.setInt('deposits', deposits);
        await prefs.setString('full_name', fullName);
        await prefs.setString('email', email);
        await prefs.setString('phone', phone);
        await prefs.setString('address', address);
        await prefs.setBool('is_employee', isEmployee); // تمت الإضافة
        await prefs.setBool('is_approved_employee', isApprovedEmployee); // تمت الإضافة

        if (profilePicUrl != null) {
          await prefs.setString('profile_picture', profilePicUrl!);
        }
      } else {
        isOffline = true;
      }
    } catch (error) {
      isOffline = true;
    }
    notifyListeners();
  }

  Future<void> fetchActivities() async {
    isLoading = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');

    try {
      var response = await http.get(Uri.parse('${ApiConstants.baseUrl}/activities/?username=$user')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List activitiesList = data is Map ? data['data'] : data;

        recentActivities = activitiesList.toList();
        await prefs.setString('cached_recent_activities', jsonEncode(recentActivities.take(2).toList()));
        isOffline = false;
      } else {
        isOffline = true;
      }
    } catch (error) {
      isOffline = true;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> scanQR(String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      var response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/user/scan-qr/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token"
        },
        body: jsonEncode({"code": code}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      }
    } catch (error) {
      throw Exception('Network Error');
    }
    return false;
  }
}