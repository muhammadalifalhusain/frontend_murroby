import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/dashboard/perilaku_screen.dart';
import '../screens/dashboard/saku_screen.dart';
import '../screens/dashboard/kelengkapan_screen.dart';
import '../screens/dashboard/pemeriksaan_screen.dart';

class MenuIkonWidget extends StatelessWidget {
  const MenuIkonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  'Menu Cepat',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 0.85,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildEnhancedMenuIkon(
                          Icons.account_balance_wallet_rounded,
                          'Uang Saku',
                          'Kelola keuangan',
                          const Color(0xFF4CAF50),
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
                        _buildEnhancedMenuIkon(
                          Icons.health_and_safety_rounded,
                          'Kesehatan',
                          'Status kesehatan',
                          const Color(0xFF2196F3),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PemeriksaanScreen()),
                            );
                          },
                        ),
                        _buildEnhancedMenuIkon(
                          Icons.rule_rounded,
                          'Perilaku',
                          'Catatan perilaku',
                          const Color(0xFFFF5722),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PerilakuScreen()),
                            );
                          },
                        ),
                        _buildEnhancedMenuIkon(
                          Icons.assignment_rounded,
                          'Kelengkapan',
                          'Tugas harian',
                          const Color(0xFF9C27B0),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const KelengkapanScreen()),
                            );
                          },
                        ),
                        _buildEnhancedMenuIkon(
                          Icons.book_rounded,
                          'Materi',
                          'Bahan belajar',
                          const Color(0xFF00BCD4),
                          () => _navigateToMateri(context),
                        ),
                        _buildEnhancedMenuIkon(
                          Icons.schedule_rounded,
                          'Jadwal',
                          'Jadwal kegiatan',
                          const Color(0xFFFF9800),
                          () => _navigateToJadwal(context),
                        ),
                      ],
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

  Widget _buildEnhancedMenuIkon(
    IconData ikon,
    String label,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    ikon,
                    size: 20,
                    color: color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),              
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToKesehatan(BuildContext context) {
    _showComingSoonDialog(context, 'Kesehatan');
  }

  void _navigateToKedisiplinan(BuildContext context) {
    _showComingSoonDialog(context, 'Kedisiplinan');
  }

  void _navigateToTugas(BuildContext context) {
    _showComingSoonDialog(context, 'Tugas');
  }

  void _navigateToMateri(BuildContext context) {
    _showComingSoonDialog(context, 'Materi');
  }

  void _navigateToJadwal(BuildContext context) {
    _showComingSoonDialog(context, 'Jadwal');
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Info',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            'Fitur $feature sedang dalam pengembangan dan akan segera tersedia.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Text(
                'Mengerti',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
