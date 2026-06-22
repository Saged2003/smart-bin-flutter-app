import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('username', data['username']);
      await prefs.setBool('is_employee', data['is_employee']);
      return data;
    } else {
      throw Exception('Login failed');
    }
  }

  Future<Map<String, dynamic>> register(String username, String password, String email, bool isEmployee) async {
    final response = await http.post(
      Uri.parse('${baseUrl}register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
        'is_employee': isEmployee,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('username', data['username']);
      return data;
    } else {
      throw Exception('Registration failed');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final response = await http.get(
      Uri.parse('${baseUrl}profile/?username=$username'),
      headers: await getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<List<dynamic>> getBins(double lat, double lng) async {
    final response = await http.get(
      Uri.parse('${baseUrl}bins/?lat=$lat&lng=$lng'),
      headers: await getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load bins');
    }
  }

  Future<Map<String, dynamic>> getRewards() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final response = await http.get(
      Uri.parse('${baseUrl}rewards/?username=$username'),
      headers: await getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load rewards');
    }
  }

  Future<Map<String, dynamic>> redeemReward(int rewardId, double originalPrice) async {
    final response = await http.post(
      Uri.parse('${baseUrl}redeem-reward/'),
      headers: await getHeaders(),
      body: jsonEncode({
        'reward_id': rewardId,
        'original_price': originalPrice,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to redeem reward');
    }
  }

  Future<Map<String, dynamic>> scanQr(String code) async {
    final response = await http.post(
      Uri.parse('${baseUrl}user/scan-qr/'),
      headers: await getHeaders(),
      body: jsonEncode({'code': code}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to scan QR');
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    final response = await http.post(
      Uri.parse('${baseUrl}update-fcm-token/'),
      headers: await getHeaders(),
      body: jsonEncode({'fcm_token': fcmToken}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update FCM token');
    }
  }
}