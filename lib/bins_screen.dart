import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BinsScreen extends StatefulWidget {
  const BinsScreen({super.key});

  @override
  State<BinsScreen> createState() => _BinsScreenState();
}

class _BinsScreenState extends State<BinsScreen> {
  Color g = const Color(0xFF0D6B58);
  Color h = const Color(0xFFE2F3E8);
  List<dynamic> bins = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBins();
  }

  Future<void> _fetchBins() async {
    try {
      var response = await http.get(Uri.parse('http://10.0.2.2:8000/api/compounds/'));
      if (response.statusCode == 200) {
        setState(() {
          bins = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Color _getBinColor(double capacity) {
    if (capacity >= 0.8) return Colors.red;
    if (capacity >= 0.5) return Colors.amber;
    return Colors.green;
  }

  String _getStatus(double capacity) {
    if (capacity >= 0.8) return 'Almost Full';
    return 'Available';
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
                'Bins Location',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: g),
              ),
              const SizedBox(height: 4),
              const Text(
                'Find nearby bins and check status',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: g,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.near_me_outlined, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Current Location', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          SizedBox(height: 2),
                          Text('Downtown Area', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: h,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Change', style: TextStyle(color: g, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _s(g, bins.length.toString(), 'Total Bins'),
                  const SizedBox(width: 12),
                  _s(g, bins.where((b) => b['v'] < 0.8).length.toString(), 'Available'),
                  const SizedBox(width: 12),
                  _s(g, 'Low', 'Crowd'),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Nearby Bins',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: g),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: g))
                    : ListView.builder(
                  itemCount: bins.length,
                  itemBuilder: (c, i) {
                    var x = bins[i];
                    double cap = (x['v'] ?? 0.0).toDouble();
                    Color clr = _getBinColor(cap);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: h,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(x['n'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, color: g, fontSize: 15)),
                              const Text('0.5 km', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: Colors.grey, size: 14),
                              const SizedBox(width: 4),
                              Text(x['s'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Bin Capacity', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('${(cap * 100).toInt()}%', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: cap,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(clr),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(_getStatus(cap), style: TextStyle(color: clr, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(radius: 4, backgroundColor: clr),
                                    const SizedBox(width: 4),
                                    const Text('Normal', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
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

  Widget _s(Color g, String n, String t) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: g,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(n, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(t, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}