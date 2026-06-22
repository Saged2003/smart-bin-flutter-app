import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'home_tab.dart';
import 'activity_screen.dart';
import 'rewards_screen.dart';
import 'bins_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final Color primaryColor = const Color(0xFF006958);
  final Color greyColor = const Color(0xFF9BABAB);

  void _goToActivity() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeTab(onViewAll: _goToActivity),
      const ActivityScreen(),
      const RewardsScreen(),
      const BinsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: greyColor.withOpacity(0.3), width: 1)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: primaryColor,
          unselectedItemColor: greyColor,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: 'home'.tr()),
            BottomNavigationBarItem(icon: const Icon(Icons.show_chart), label: 'activity'.tr()),
            BottomNavigationBarItem(icon: const Icon(Icons.card_giftcard), label: 'rewards'.tr()),
            BottomNavigationBarItem(icon: const Icon(Icons.location_on_outlined), activeIcon: const Icon(Icons.location_on), label: 'bins'.tr()),
            BottomNavigationBarItem(icon: const Icon(Icons.person_outline), activeIcon: const Icon(Icons.person), label: 'profile'.tr()),
          ],
        ),
      ),
    );
  }
}