import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shimmer/shimmer.dart';
import 'providers/bins_provider.dart';
import 'bin_map_screen.dart';
import 'animated_button.dart';

class BinsScreen extends StatefulWidget {
  const BinsScreen({super.key});
  @override
  State<BinsScreen> createState() => _BinsScreenState();
}

class _BinsScreenState extends State<BinsScreen> {
  final Color primaryColor = const Color(0xFF0D6B58);
  final Color secondaryColor = const Color(0xFFE2F3E8);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BinsProvider>().loadCachedBins();
      context.read<BinsProvider>().getCurrentLocation();
    });
  }
  void _showLocationDialog(BinsProvider binsProvider) {
    TextEditingController latController = TextEditingController(text: binsProvider.currentLat.toString());
    TextEditingController lngController = TextEditingController(text: binsProvider.currentLng.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('manual_location'.tr(), style: TextStyle(color: primaryColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: latController, decoration: InputDecoration(labelText: 'latitude'.tr())),
            TextField(controller: lngController, decoration: InputDecoration(labelText: 'longitude'.tr())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () {
              Navigator.pop(context);
              binsProvider.updateManualLocation(double.tryParse(latController.text) ?? binsProvider.currentLat, double.tryParse(lngController.text) ?? binsProvider.currentLng);
            },
            child: Text('update'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  Widget _buildShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(margin: const EdgeInsets.only(bottom: 16), height: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final binsProvider = context.watch<BinsProvider>();
    int total = binsProvider.bins.length;
    int avail = binsProvider.bins.where((bin) => bin['status'] == 'idle').length;
    int low = binsProvider.bins.where((bin) => (bin['capacity'] ?? 0.0) < 50).length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: () => binsProvider.getCurrentLocation(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('bins_location'.tr(), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: primaryColor)),
                    if (binsProvider.isOffline) const Icon(Icons.cloud_off, color: Colors.orange),
                  ],
                ),
                const SizedBox(height: 4),
                Text('find_nearby_bins'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 24),
                AnimatedButton(
                  onTap: () => binsProvider.getCurrentLocation(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        const Icon(Icons.near_me_outlined, color: Colors.white, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('current_location'.tr(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              Text(binsProvider.currentLocationName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showLocationDialog(binsProvider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(20)),
                            child: Text('change'.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryColor)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatBox(total.toString(), 'total_bins'.tr()),
                    const SizedBox(width: 12),
                    _buildStatBox(avail.toString(), 'available'.tr()),
                    const SizedBox(width: 12),
                    _buildStatBox(low.toString(), 'low_crowd'.tr()),
                  ],
                ),
                const SizedBox(height: 30),
                Text('nearby_bins'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 16),
                binsProvider.isLoading && binsProvider.bins.isEmpty 
                    ? _buildShimmer()
                    : binsProvider.bins.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(Icons.location_off, size: 60, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('no_bins_found'.tr(), style: const TextStyle(color: Colors.grey)),
                            if (binsProvider.isOffline)
                              TextButton(onPressed: () => binsProvider.getCurrentLocation(), child: Text('try_again'.tr(), style: TextStyle(color: primaryColor))),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: binsProvider.bins.length,
                        itemBuilder: (context, index) {
                          var binData = binsProvider.bins[index];
                          String status = binData['status'] ?? 'idle';
                          double capacity = (binData['capacity'] ?? 0.0).toDouble();
                          bool isLow = capacity < 50;
                          bool isMedium = capacity >= 50 && capacity < 80;
                          String crowdText = isLow ? 'low_crowd'.tr() : (isMedium ? 'medium_crowd'.tr() : 'high_crowd'.tr());
                          Color crowdColor = isLow ? Colors.green : (isMedium ? Colors.amber : Colors.red);
                          double distance = binData['distance_km'] ?? 0.0;
                          return AnimatedButton(
                            onTap: () {
                              if (binData['lat'] != null && binData['lng'] != null) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => BinMapScreen(binId: binData['bin_id'], lat: binData['lat'], lng: binData['lng'], status: status, capacity: capacity)));
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text('${'bin'.tr()} ${binData['bin_id'] ?? ''}', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 16)),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.circle, size: 8, color: Colors.pinkAccent),
                                        ],
                                      ),
                                      Text('${distance.toStringAsFixed(1)} km', style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${'lat'.tr()}: ${binData['lat'] ?? 0.0}, ${'lng'.tr()}: ${binData['lng'] ?? 0.0}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('bin_capacity'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                                      Text('${capacity.toInt()}%', style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: capacity / 100,
                                      backgroundColor: Colors.white,
                                      valueColor: AlwaysStoppedAnimation<Color>(crowdColor),
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      _buildStatusChip(status == 'idle' ? 'available'.tr() : 'busy'.tr(), status == 'idle' ? Colors.green : Colors.red, false),
                                      const SizedBox(width: 10),
                                      _buildStatusChip(crowdText, crowdColor, true),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildStatBox(String count, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Text(count, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
  Widget _buildStatusChip(String text, Color color, bool isDot) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          if (isDot) ...[
            Icon(Icons.circle, color: color, size: 10),
            const SizedBox(width: 6),
          ],
          Text(text, style: TextStyle(color: isDot ? Colors.black87 : color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}