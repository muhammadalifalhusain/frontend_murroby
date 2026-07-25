import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/dashboard/izin_screen.dart';
import '../screens/dashboard/kelengkapan_screen.dart';
import '../screens/dashboard/pemeriksaan_screen.dart';
import '../screens/dashboard/perilaku_screen.dart';
import '../screens/dashboard/saku_screen.dart';

class MenuIkonWidget extends StatelessWidget {
  const MenuIkonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Menu Cepat',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: .82,
            crossAxisSpacing: 10,
            children: [
              _buildMenu(
                context,
                icon: Icons.account_balance_wallet_rounded,
                title: 'Uang Saku',
                color: const Color(0xFF43A047),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getInt('idUser');

                  if (userId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UangSakuScreen(userId: userId),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User ID tidak ditemukan'),
                      ),
                    );
                  }
                },
              ),
              _buildMenu(
                context,
                icon: Icons.health_and_safety_rounded,
                title: 'Pemeriksaan',
                color: const Color(0xFF1E88E5),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PemeriksaanScreen(),
                    ),
                  );
                },
              ),
              _buildMenu(
                context,
                icon: Icons.rule_rounded,
                title: 'Perilaku',
                color: const Color(0xFFE53935),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PerilakuScreen(),
                    ),
                  );
                },
              ),
              _buildMenu(
                context,
                icon: Icons.assignment_rounded,
                title: 'Kelengkapan',
                color: const Color(0xFF8E24AA),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KelengkapanScreen(),
                    ),
                  );
                },
              ),
              _buildMenu(
                context,
                icon: Icons.book_rounded,
                title: 'Izin',
                color: const Color(0xFF00ACC1),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IzinScreen(),
                    ),
                  );
                },
              ),
              _buildMenu(
                context,
                icon: Icons.inventory_2_rounded,
                title: 'Perlengkapan',
                color: const Color(0xFFFB8C00),
                onTap: () => _navigateToPerlengkapan(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Material(
            color: Colors.white,
            elevation: 3,
            shape: const CircleBorder(),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(.15),
                ),
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPerlengkapan(BuildContext context) {
    _showComingSoonDialog(context, 'Perlengkapan');
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Informasi',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Fitur $feature sedang dalam pengembangan.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tutup',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}