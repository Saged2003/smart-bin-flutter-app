import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'about_screen.dart';
import 'employee_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Color g = const Color(0xFF0D6B58);
  Color h = const Color(0xFFE2F3E8);

  String userName = "User";
  String fullName = "";
  String email = "";
  String phone = "";
  String address = "";
  String? profilePicUrl;
  int totalPoints = 0;
  int deposits = 0;
  double weight = 0.0;
  bool isEmployee = false;
  bool isApprovedEmployee = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username');
    if (user == null) return;

    try {
      var response = await http.get(Uri.parse('${ApiConstants.baseUrl}/profile/?username=$user'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          userName = user;
          totalPoints = data['points'] ?? 0;
          weight = (data['weight'] ?? 0.0).toDouble();
          deposits = data['deposits'] ?? 0;
          fullName = data['full_name'] ?? "";
          email = data['email'] ?? "";
          phone = data['phone'] ?? "";
          address = data['address'] ?? "";
          profilePicUrl = data['profile_picture'];
          isEmployee = data['is_employee'] ?? false;
          isApprovedEmployee = data['is_approved_employee'] ?? false;
        });

        await prefs.setInt('points', totalPoints);
        await prefs.setDouble('weight', weight);
        await prefs.setInt('deposits', deposits);
        await prefs.setBool('is_employee', isEmployee);
        await prefs.setBool('is_approved_employee', isApprovedEmployee);
        await prefs.setString('full_name', fullName);
      }
    } catch (e) {}
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext c) {
    bool showEmp = (email == 'sagedryan775@gmail.com') || (isEmployee && isApprovedEmployee);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _fetchProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Stack(
            children: [
              Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: g,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white70,
                      backgroundImage: profilePicUrl != null ? NetworkImage('${ApiConstants.mediaUrl}$profilePicUrl') : null,
                      child: profilePicUrl == null ? const Icon(Icons.person, size: 70, color: Colors.grey) : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      fullName.isNotEmpty ? fullName : userName,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email.isNotEmpty ? email : 'ID: ECO-USER-12345',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 260, left: 20, right: 20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _s(h, g, Icons.military_tech_outlined, '$totalPoints', 'Total Points'),
                          _s(Colors.purple.shade50, Colors.purple.shade300, Icons.check_box_outlined, '$deposits', 'Deposits'),
                          _s(Colors.blue.shade50, Colors.blue.shade400, Icons.bolt_outlined, weight.toStringAsFixed(1), 'Kg Recycled'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (showEmp) ...[
                      _o(Icons.admin_panel_settings, 'Employee Dashboard', Colors.amber.shade50, Colors.amber.shade800, false, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const EmployeeScreen()));
                      }),
                      const SizedBox(height: 16),
                    ],
                    _o(Icons.person_outline, 'Edit Profile', Colors.grey.shade50, Colors.black87, false, () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(
                        currentName: fullName,
                        currentEmail: email,
                        currentPhone: phone,
                        currentAddress: address,
                        profilePicUrl: profilePicUrl,
                      )));
                      _fetchProfileData();
                    }),
                    const SizedBox(height: 16),
                    _o(Icons.info_outline, 'About EcoBin', Colors.grey.shade50, Colors.black87, false, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
                    }),
                    const SizedBox(height: 16),
                    _o(Icons.logout, 'Log Out', h, g, true, _logout),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _s(Color b, Color c, IconData i, String v, String t) {
    return Column(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: b, borderRadius: BorderRadius.circular(12)), child: Icon(i, color: c, size: 26)),
        const SizedBox(height: 12),
        Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(t, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _o(IconData i, String t, Color b, Color c, bool isLogout, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: b, borderRadius: BorderRadius.circular(10)), child: Icon(i, color: isLogout ? c : Colors.grey.shade600, size: 22)),
            const SizedBox(width: 16),
            Expanded(child: Text(t, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: c))),
            if (!isLogout) const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}