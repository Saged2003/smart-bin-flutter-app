import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'scanner_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final Color darkGreen = const Color(0xFF006958);
  final Color lightGreen = const Color(0xFFD4F0DA);
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
    setState(() {
      userName = prefs.getString('username') ?? "User";
      currentBalance = prefs.getInt('points') ?? 0;
    });
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    try {
      var response = await http.get(Uri.parse('http://10.0.2.2:8000/api/activities/?username=$userName'));
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

  Future<void> _redeemPoints(String c) async {
    try {
      var response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/redeem/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": userName, "code": c}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() => currentBalance = data['total_points'] ?? currentBalance);
        await prefs.setInt('points', currentBalance);
        await prefs.setDouble('weight', (data['total_weight'] ?? 0.0).toDouble());
        await prefs.setInt('deposits', data['deposits'] ?? 0);
        _fetchActivities();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Success! Added ${data['added_points']} points')));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid code or used.')));
      }
    } catch (e) {}
  }

  void _showRedeemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Bin Code', style: TextStyle(color: darkGreen)),
        content: TextField(
          controller: binCodeController,
          decoration: InputDecoration(hintText: 'e.g. BIN-2026', filled: true, fillColor: lightGreen, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: greyColor))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (binCodeController.text.isNotEmpty) {
                _redeemPoints(binCodeController.text);
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back,', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: darkGreen)),
            const SizedBox(height: 8),
            Text('$userName!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: darkGreen)),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen())),
                    style: ElevatedButton.styleFrom(backgroundColor: accentGreen, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
                    child: Text('Scanner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGreen)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showRedeemDialog,
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
                Text('View All', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accentGreen)),
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