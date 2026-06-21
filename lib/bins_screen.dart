import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

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
      var response = await http.get(Uri.parse('${ApiConstants.baseUrl}/bins/'));
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

  @override
  Widget build(BuildContext c) {
    int total = bins.length;
    int avail = bins.where((b) => b['status'] == 'idle').length;
    int low = bins.where((b) => (b['capacity'] ?? 0.0) < 50).length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bins Location', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: g)),
              const SizedBox(height: 4),
              const Text('Find nearby bins and check status', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: g, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Icon(Icons.near_me_outlined, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Location', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('Downtown Area', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: h, foregroundColor: g, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: const Text('Change', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _b(total.toString(), 'Total Bins'),
                  const SizedBox(width: 12),
                  _b(avail.toString(), 'Available'),
                  const SizedBox(width: 12),
                  _b(low.toString(), 'Low Crowd'),
                ],
              ),
              const SizedBox(height: 24),
              Text('Nearby Bins', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: g)),
              const SizedBox(height: 16),
              isLoading
                  ? Center(child: CircularProgressIndicator(color: g))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bins.length,
                itemBuilder: (ctx, i) {
                  var x = bins[i];
                  String status = x['status'] ?? 'idle';
                  double cap = (x['capacity'] ?? 0.0).toDouble();
                  bool isLow = cap < 50;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: h, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Bin ${x['bin_id'] ?? ''}', style: TextStyle(fontWeight: FontWeight.bold, color: g, fontSize: 15)),
                            const Text('0.2 km', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: Colors.grey, size: 14),
                            const SizedBox(width: 4),
                            Text('Lat: ${x['lat'] ?? 0.0}, Lng: ${x['lng'] ?? 0.0}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Bin Capacity', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text('${cap.toInt()}%', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: cap / 100,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(isLow ? Colors.green : Colors.amber),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _c(status == 'idle' ? 'Available' : 'Busy', status == 'idle' ? Colors.green : Colors.red),
                            const SizedBox(width: 8),
                            _c(isLow ? 'Low Crowd' : 'Medium Crowd', isLow ? Colors.green : Colors.amber, isDot: true),
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
    );
  }

  Widget _b(String n, String t) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: g, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text(n, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(t, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _c(String t, Color c, {bool isDot = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          if (isDot) ...[
            Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          Text(t, style: TextStyle(color: isDot ? Colors.black87 : c, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}