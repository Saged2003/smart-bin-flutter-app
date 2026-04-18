import 'package:flutter/material.dart';
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
  int _i = 0;
  final Color g = const Color(0xFF006958);
  final Color x = const Color(0xFF9BABAB);

  final List<Widget> _p = [
    const HomeTab(),
    const ActivityScreen(),
    const RewardsScreen(),
    const BinsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      body: _p[_i],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: x.withOpacity(0.3), width: 1)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: g,
          unselectedItemColor: x,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          currentIndex: _i,
          onTap: (n) => setState(() => _i = n),
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