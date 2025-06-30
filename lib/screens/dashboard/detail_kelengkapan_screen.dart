import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'form_kelengkapan_screen.dart';
import '../../models/kelengkapan_model.dart';
import '../../services/kelengkapan_service.dart';

class DetailKelengkapanScreen extends StatefulWidget {
  final int noInduk;

  const DetailKelengkapanScreen({Key? key, required this.noInduk}) : super(key: key);

  @override
  State<DetailKelengkapanScreen> createState() => _DetailKelengkapanScreenState();
}

class _DetailKelengkapanScreenState extends State<DetailKelengkapanScreen> {
  late Future<DetailKelengkapanResponse> _futureDetail;

  @override
  void initState() {
    super.initState();
    _futureDetail = KelengkapanService.fetchDetailKelengkapan(widget.noInduk);
  }

  Color getBackgroundColor(String value) {
    switch (value.toLowerCase()) {
      case 'lengkap & baik':
        return Colors.green.shade400;
      case 'lengkap & kurang baik':
        return Colors.orange.shade400;
      case 'tidak lengkap':
        return const Color.fromARGB(255, 216, 46, 33);
      default:
        return Colors.grey.shade300;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
              onPressed: () => Navigator.of(context).pop(true),
              padding: const EdgeInsets.only(left: 8, right: 4),
              constraints: const BoxConstraints(),
            ),
            Text(
              'Detail Kelengkapan',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<DetailKelengkapanResponse>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat data: ${snapshot.error}'),
            );
          }

          final data = snapshot.data!;
          final kelengkapanList = data.data.dataKelengkapan;
          final namaSantri = data.data.namaSantri;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nama Santri',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  namaSantri,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.assignment_rounded, size: 16, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              '${kelengkapanList.length} Catatan Kelengkapan',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: kelengkapanList.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Riwayat Catatan Kelengkapan',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...kelengkapanList.map((item) => _buildKelengkapanCard(item)).toList(),
                            const SizedBox(height: 80), // Tambahan agar tidak ketutup FAB
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF667EEA),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final snapshot = await _futureDetail;
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormKelengkapanScreen(
                noInduk: widget.noInduk,
                namaSantri: snapshot.data.namaSantri,
              ),
            ),
          );
          if (result == true) {
            setState(() {
              _futureDetail = KelengkapanService.fetchDetailKelengkapan(widget.noInduk);
            });
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Catatan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Catatan Kelengkapan santri akan muncul di sini ketika sudah tersedia',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildKelengkapanCard(ItemKelengkapan item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Catatan Kelengkapan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      item.tanggal,
                      style: const TextStyle(
                        color: Color(0xFF4A5568),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(
                                  'Konfirmasi Hapus',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            content: Text(
                              'Apakah kamu yakin ingin menghapus data kelengkapan ini?',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: Text(
                                  'Batal',
                                  style: GoogleFonts.poppins(color: Colors.grey.shade600),
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.delete_outline, size: 18),
                                label: Text(
                                  'Hapus',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                ),
                                onPressed: () => Navigator.of(ctx).pop(true),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          final success = await KelengkapanService.deleteKelengkapan(item.id);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.green.shade600,
                                content: Text(
                                  'Data berhasil dihapus',
                                  style: GoogleFonts.poppins(color: Colors.white),
                                ),
                              ),
                            );
                            setState(() {
                              _futureDetail = KelengkapanService.fetchDetailKelengkapan(widget.noInduk);
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red.shade600,
                                content: Text(
                                  'Gagal menghapus data',
                                  style: GoogleFonts.poppins(color: Colors.white),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    )


                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Column(
                children: [
                  _buildScoreRow(
                    Icons.shower,
                    "Mandi",
                    item.perlengkapanMandi,
                    getBackgroundColor(item.perlengkapanMandi),
                    item.catatanMandi,
                  ),
                  const SizedBox(height: 8),
                  _buildScoreRow(
                    Icons.school,
                    "Alat Sekolah",
                    item.peralatanSekolah,
                    getBackgroundColor(item.peralatanSekolah),
                    item.catatanSekolah,
                  ),
                  const SizedBox(height: 8),
                  _buildScoreRow(
                    Icons.checkroom,
                    "Perlengkapan Diri",
                    item.perlengkapanDiri,
                    getBackgroundColor(item.perlengkapanDiri),
                    item.catatanDiri,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildScoreRow(IconData icon, String label, String score, Color color, String catatan) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF4A5568),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                score,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (catatan.trim().isNotEmpty && catatan != "-")
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    catatan,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  

}