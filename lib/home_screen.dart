// Developer: SAGED RYAN
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'api_constants.dart';
import 'scanner_screen.dart';
import 'animated_button.dart'; // إضافة الـ AnimatedButton

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color darkGreen = const Color(0xFF006958);
  final Color lightGreen = const Color(0xFFD4F0DA);
  final Color accentGreen = const Color(0xFFA6E037);
  final Color greyColor = const Color(0xFF9BABAB);

  String userName = "User";
  int currentBalance = 0;
  int milestonePoints = 0; // إضافة لتتبع التقدم نحو الـ 1000 نقطة
  int _bottomNavIndex = 0;
  bool isLoading = true;
  bool isOffline = false;
  
  final TextEditingController binCodeController = TextEditingController();
  List<dynamic> recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // تحميل الداتا المحفوظة (Offline First)
    String? cachedActivities = prefs.getString('cached_recent_activities');
    if (cachedActivities != null) {
      setState(() {
        recentActivities = jsonDecode(cachedActivities);
      });
    }

    setState(() {
      userName = prefs.getString('username') ?? "User";
      currentBalance = prefs.getInt('points') ?? 0;
      milestonePoints = prefs.getInt('milestone_points') ?? currentBalance % 1000;
    });
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() => isLoading = true);
    try {
      var response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/activities/?username=$userName'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List activitiesList = data is Map ? data['data'] : data; // التعامل مع الـ Pagination لو مفعل
        
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('cached_recent_activities', jsonEncode(activitiesList.take(2).toList()));

        setState(() {
          recentActivities = activitiesList.take(2).toList();
          isLoading = false;
          isOffline = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isOffline = true;
      });
    }
  }

  IconData _getIcon(String type) {
    String t = type.toLowerCase();
    if (t.contains('plastic')) return Icons.local_drink_outlined;
    if (t.contains('aluminum')) return Icons.change_history;
    if (t.contains('glass')) return Icons.wine_bar;
    if (t.contains('cardboard')) return Icons.inventory_2_outlined;
    return Icons.recycling;
  }

  Future<void> _scanQR(String code) async {
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scanned successfully! Bin is waiting.'), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid code or bin is busy.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Check connection.'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  void _showScanDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Bin Code', style: TextStyle(color: darkGreen)),
          content: TextField(
            controller: binCodeController,
            decoration: InputDecoration(
              hintText: 'e.g. 1234-5678',
              filled: true,
              fillColor: lightGreen,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: greyColor)),
            ),
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
        );
      },
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
    });
  }

  Widget _buildShimmerActivities() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 70,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int pointsLeft = 1000 - milestonePoints;
    double progress = milestonePoints / 1000;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: darkGreen,
          onRefresh: _loadUserData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back,', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: darkGreen)),
                        const SizedBox(height: 8),
                        Text('$userName!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: darkGreen)),
                      ],
                    ),
                    if (isOffline) const Icon(Icons.cloud_off, color: Colors.orange),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedButton(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ScannerScreen()),
                          );
                          if (result != null && result.toString().isNotEmpty) {
                            _scanQR(result.toString());
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(color: accentGreen, borderRadius: BorderRadius.circular(25)),
                          child: Center(child: Text('Scanner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGreen))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedButton(
                        onTap: _showScanDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(25)),
                          child: const Center(child: Text('Enter Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text('Current Balance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkGreen)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      Text('$currentBalance points', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 20),
                      // إضافة: شريط التقدم للـ 1000 نقطة لفتح البريميوم
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Premium Progress', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('$pointsLeft pts left', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(accentGreen),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Activity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkGreen)),
                    GestureDetector(
                      onTap: () {}, // اربطها بشاشة الـ Activities لاحقاً في الـ MainScreen
                      child: Text('View All', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accentGreen)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                isLoading && recentActivities.isEmpty
                    ? _buildShimmerActivities()
                    : recentActivities.isEmpty
                        ? Center(child: Text("No recent activities", style: TextStyle(color: greyColor)))
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recentActivities.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final activity = recentActivities[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: lightGreen, borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                      child: Icon(_getIcon(activity['t'] ?? ''), color: darkGreen),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(activity["t"].toString().toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGreen)),
                                          const SizedBox(height: 4),
                                          Text(activity["date"] != null ? activity["date"].toString().substring(0, 10) : "", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: greyColor)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('+${activity["points"] ?? activity["v"]} pts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGreen)),
                                        const SizedBox(height: 4),
                                        Text('${activity["weight"] ?? activity["w"]} kg', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: greyColor)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: greyColor.withOpacity(0.3), width: 1)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: darkGreen,
          unselectedItemColor: greyColor,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          currentIndex: _bottomNavIndex,
          onTap: _onBottomNavTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Activity'),
            BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Rewards'),
            BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), activeIcon: Icon(Icons.location_on), label: 'Bins'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}