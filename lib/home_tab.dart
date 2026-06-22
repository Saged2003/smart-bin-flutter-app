import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shimmer/shimmer.dart';
import 'providers/user_provider.dart';
import 'scanner_screen.dart';
import 'animated_button.dart';
import 'scan_success_screen.dart';

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
  final TextEditingController binCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadLocalData();
      context.read<UserProvider>().fetchProfileData();
      context.read<UserProvider>().fetchActivities();
    });
  }
  IconData _getIcon(String type) {
    String typeString = type.toLowerCase();
    if (typeString.contains('plastic')) return Icons.local_drink_outlined;
    if (typeString.contains('aluminum')) return Icons.change_history;
    if (typeString.contains('glass')) return Icons.wine_bar;
    if (typeString.contains('cardboard')) return Icons.inventory_2_outlined;
    return Icons.recycling;
  }
  Future<void> _handleScanQR(String code) async {
    final userProvider = context.read<UserProvider>();
    bool success = await userProvider.scanQR(code);
    if (success && mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanSuccessScreen()));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('invalid_qr'.tr(), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    }
  }
  void _showScanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('enter_bin_code'.tr(), style: TextStyle(color: darkGreen)),
        content: TextField(
          controller: binCodeController,
          decoration: InputDecoration(hintText: 'e.g. 1234-5678', filled: true, fillColor: lightGreen, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr(), style: TextStyle(color: greyColor))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (binCodeController.text.isNotEmpty) {
                _handleScanQR(binCodeController.text);
                binCodeController.clear();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: darkGreen),
            child: Text('submit'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
          child: Container(height: 70, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    int pointsLeft = 1000 - userProvider.milestonePoints;
    double progress = userProvider.milestonePoints / 1000;
    String displayName = userProvider.fullName.isNotEmpty ? userProvider.fullName : userProvider.userName;

    return SafeArea(
      child: RefreshIndicator(
        color: darkGreen,
        onRefresh: () async {
          await userProvider.fetchProfileData();
          await userProvider.fetchActivities();
        },
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
                      Text('welcome_back'.tr(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: darkGreen)),
                      const SizedBox(height: 8),
                      Text(displayName, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: darkGreen)),
                    ],
                  ),
                  if (userProvider.isOffline) const Icon(Icons.cloud_off, color: Colors.orange),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: AnimatedButton(
                      onTap: () async {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen()));
                        if (result != null && result.toString().isNotEmpty) {
                          _handleScanQR(result.toString());
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(color: accentGreen, borderRadius: BorderRadius.circular(25)),
                        child: Center(child: Text('scanner'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGreen))),
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
                        child: Center(child: Text('enter_code'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text('current_balance'.tr(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkGreen)),
              const SizedBox(height: 8),
              AnimatedButton(
                onTap: widget.onViewAll,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      Text('${userProvider.currentBalance} ${'points'.tr()}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('premium_progress'.tr(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('$pointsLeft ${'pts_left'.tr()}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('recent_activity'.tr(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkGreen)),
                  GestureDetector(
                    onTap: widget.onViewAll,
                    child: Text('view_all'.tr(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accentGreen)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              userProvider.isLoading && userProvider.recentActivities.isEmpty
                  ? _buildShimmerActivities()
                  : userProvider.recentActivities.isEmpty
                  ? Center(child: Text("no_recent_activities".tr(), style: TextStyle(color: greyColor)))
                  : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userProvider.recentActivities.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final activity = userProvider.recentActivities[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: lightGreen, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(_getIcon(activity['t'] ?? ''), color: darkGreen)),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(activity["t"].toString().toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGreen)),
                          const SizedBox(height: 4),
                          Text(activity["date"] != null ? activity["date"].toString().substring(0, 10) : "", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: greyColor)),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('+${activity["points"] ?? activity["v"]} ${'pts'.tr()}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGreen)),
                          const SizedBox(height: 4),
                          Text('${activity["weight"] ?? activity["w"]} kg', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: greyColor)),
                        ]),
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
}