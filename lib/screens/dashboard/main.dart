import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'saku_screen.dart';
import 'pemeriksaan_screen.dart';

class MainScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> murrobyData;

  const MainScreen({
    Key? key,
    required this.userId,
    required this.murrobyData,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; 

  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_wallet),
      label: 'Uang Saku',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.local_hospital),
      label: 'Kesehatan',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return UangSakuScreen(userId: widget.userId);
      case 1:
        return DashboardScreen(); 
      case 2:
        return PemeriksaanScreen();
      default:
        return DashboardScreen(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: Colors.black,
              unselectedItemColor: const Color(0xFF7B9080),
              selectedFontSize: 12,
              unselectedFontSize: 11,
              elevation: 0,
              items: _navItems,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}