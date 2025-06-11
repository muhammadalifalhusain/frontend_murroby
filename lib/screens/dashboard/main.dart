import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'saku_screen.dart';
import 'kesehatan_screen.dart';

class MainScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> murrobyData;

  const MainScreen({
    Key? key,
    required this.userId,
    required this.murrobyData,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.account_balance_wallet,
      'label': 'Uang Saku',
      'isAvailable': true, 
    },
    {
      'icon': Icons.dashboard,
      'label': 'Dashboard',
      'isAvailable': true, 
    },
    {
      'icon': Icons.local_hospital,
      'label': 'Kesehatan',
      'isAvailable': true, 
    },
  ];

  void _onItemTapped(int index) {
    // Check if menu is available
    if (!_menuItems[index]['isAvailable']) {
      _showComingSoonDialog(_menuItems[index]['label']);
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _showComingSoonDialog(String menuName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.construction,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Menu "$menuName" sedang dalam pengembangan.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'tim pengembang mo liburan dlu!',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.teal[50],
                foregroundColor: Colors.teal[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Mengerti',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0: // Uang Saku
        return UangSakuScreen(userId: widget.userId);
      case 1: // Dashboari
        return DashboardMurrobyScreen(
          userId: widget.userId,
          murrobyData: widget.murrobyData,
        );
      case 2: // Kesehatan
        return KesehatanScreen();
      default:
        return DashboardMurrobyScreen(
          userId: widget.userId,
          murrobyData: widget.murrobyData,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.teal[600],
          unselectedItemColor: Colors.grey[500],
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 0,
          items: _menuItems.map((item) {
            final int index = _menuItems.indexOf(item);
            return BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _selectedIndex == index
                          ? Colors.teal[50]
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'],
                      color: !item['isAvailable']
                          ? Colors.grey[400]
                          : (_selectedIndex == index
                              ? Colors.teal[600]
                              : Colors.grey[500]),
                    ),
                  ),
                  if (!item['isAvailable'])
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock,
                          size: 8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              label: item['label'],
            );
          }).toList(),
        ),
      ),
    );
  }
}