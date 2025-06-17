import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/dashboard/saku_screen.dart';

class MenuIkonWidget extends StatelessWidget {
  const MenuIkonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        mainAxisSpacing: 13,
        crossAxisSpacing: 13,
        children: [
          _buildMenuIkon(
            Icons.account_balance_wallet,
            'Uang Saku',
            Colors.green,
            () async {
              final prefs = await SharedPreferences.getInstance();
              final userId = prefs.getInt('userId');
              
              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UangSakuScreen(userId: userId),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User ID tidak ditemukan')),
                );
              }
            },
          ),
          _buildMenuIkon(
            Icons.health_and_safety,
            'Kesehatan',
            Colors.blue,
            () => _navigateToKesehatan(context),
          ),
          _buildMenuIkon(
            Icons.fastfood,
            'Kantin',
            Colors.orange,
            () => _navigateToKantin(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuIkon(IconData ikon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              ikon, 
              size: 28, 
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToKesehatan(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigasi ke Kesehatan')),
    );
  }

  void _navigateToKantin(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigasi ke Kantin')),
    );
  }
}