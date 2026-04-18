import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  Color g = const Color(0xFF0D6B58);
  Color h = const Color(0xFFE2F3E8);

  int totalPoints = 0;
  double totalWeight = 0.0;
  List<dynamic> activities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userName = prefs.getString('username') ?? '';
    setState(() {
      totalPoints = prefs.getInt('points') ?? 0;
      totalWeight = prefs.getDouble('weight') ?? 0.0;
    });

    try {
      var response = await http.get(Uri.parse('http://10.0.2.2:8000/api/activities/?username=$userName'));
      if (response.statusCode == 200) {
        setState(() {
          activities = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String _getImage(String type) {
    String t = type.toLowerCase();
    if(t.contains('plastic')) return 'lib/assets/images/Plastic Bottle.png';
    if(t.contains('aluminum')) return 'lib/assets/images/Aluminum Can.png';
    if(t.contains('glass')) return 'lib/assets/images/Glass Bottle.png';
    if(t.contains('cardboard')) return 'lib/assets/images/Cardboard Box.png';
    if(t.contains('newspaper')) return 'lib/assets/images/Newspaper.png';
    return 'lib/assets/images/Plastic Bottle.png';
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activity History',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: g),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track your recycling journey',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: g,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.trending_up, color: Colors.white, size: 28),
                          const SizedBox(height: 12),
                          Text('$totalPoints', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w500)),
                          const Text('Total Points Earned', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: g,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 28),
                          const SizedBox(height: 12),
                          Text('${totalWeight.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w500)),
                          const Text('Total Weight', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'All Deposits',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: g),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: g))
                    : activities.isEmpty
                    ? const Center(child: Text('No activities yet', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (c, i) {
                    var x = activities[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: h,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Image.asset(_getImage(x['t'] ?? ''), width: 35, height: 35),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(x['t'].toString().toUpperCase(), style: TextStyle(fontWeight: FontWeight.w600, color: g, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(x['q'] != null ? x['q'].toString().substring(0, 10) : '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('+${x['v']} pts', style: TextStyle(fontWeight: FontWeight.w600, color: g, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text('${x['w']} kg', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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