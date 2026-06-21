import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'scanner_screen.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback onViewAll;
  const HomeTab({super.key, required this.onViewAll});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final Color darkGreen = const Color(0xFF0D6B58);
  final Color lightGreen = const Color(0xFFE2F3E8);
  final Color accentGreen = const Color(0xFFA6E037);
  final Color greyColor = const Color(0xFF9BABAB);

  String userName = "User";
  int currentBalance = 0;
  final TextEditingController binCodeController = TextEditingController();
  List<dynamic> recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user = prefs.getString('username') ?? "User";
    
    try {
      var profileRes = await http.get(Uri.parse('${ApiConstants.baseUrl}/profile/?username=$user'));
      if (profileRes.statusCode == 200) {
        var data = jsonDecode(profileRes.body);
        setState(() {
          String fn = data['full_name'] ?? "";
          userName = fn.isNotEmpty ? fn : user;
          currentBalance = data['points'] ?? 0;
        });
        await prefs.setInt('points', currentBalance);
        await prefs.setString('full_name', data['full_name'] ?? "");
      } else {
        setState(() {
          userName = prefs.getString('full_name') ?? user;
          currentBalance = prefs.getInt('points') ?? 0;
        });
      }
    } catch (e) {
      setState(() {
        userName = prefs.getString('full_name') ?? user;
        currentBalance = prefs.getInt('points') ?? 0;
      });
    }
    _fetchActivities(user);
  }

  Future<void> _fetchActivities(String user) async {
    try {
      var response = await http.get(Uri.parse('${ApiConstants.baseUrl}/activities/?username=$user'));
      if (response.statusCode == 200) {
        setState(() => recentActivities = jsonDecode(response.body).take(2).toList());
      }
    } catch (e) {}
  }

  IconData _getIcon(String t) {
    String s = t.toLowerCase();
    if (s.contains('plastic')) return Icons.local_drink_outlined;
    if (s.contains('aluminum')) return Icons.change_history;
    if (s.contains('glass')) return Icons.wine_bar;
    if (s.contains('cardboard')) return Icons.inventory_2_outlined;
    return Icons.recycling;
  }

  Future<void> _scanQR(String c) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      var response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/user/scan-qr/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token"
        },
        body: jsonEncode({"code": c}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scanned successfully! Bin is waiting.')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This QR code is invalid or wrong.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This QR code is invalid or wrong.')));
      }
    }
  }

  void _showScanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Bin Code', style: TextStyle(color: darkGreen)),
        content: TextField(
          controller: binCodeController,
          decoration: InputDecoration(hintText: 'e.g. 1234-5678', filled: true, fillColor: lightGreen, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: greyColor))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (binCodeController.text.isNotEmpty) {
                _scanQR(binCodeController.text);
                binCodeController.clear();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: darkGreen),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome,', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: darkGreen)),
            const SizedBox(height: 8),
            Text(userName, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: darkGreen)),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScannerScreen()),
                      );
                      if (result != null && result.toString().isNotEmpty) {
                        _scanQR(result.toString());
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: accentGreen, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
                    child: Text('Scanner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGreen)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showScanDialog,
                    style: ElevatedButton.styleFrom(backgroundColor: darkGreen, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
                    child: const Text('Enter Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text('Current Balance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkGreen)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(20)),
              child: Center(child: Text('$currentBalance points', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w500, color: Colors.white))),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Activity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkGreen)),
                GestureDetector(
                  onTap: widget.onViewAll,
                  child: Text('View All', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accentGreen)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            recentActivities.isEmpty
                ? Center(child: Text("No recent activities", style: TextStyle(color: greyColor)))
                : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentActivities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final a = recentActivities[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: lightGreen, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(_getIcon(a['t'] ?? ''), color: darkGreen)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a["t"].toString().toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGreen)),
                        const SizedBox(height: 4),
                        Text(a["q"] != null ? a["q"].toString().substring(0, 10) : "", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: greyColor)),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('+${a["v"]} pts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGreen)),
                        const SizedBox(height: 4),
                        Text('${a["w"]} kg', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: greyColor)),
                      ]),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}