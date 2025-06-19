import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detail_kelengkapan_screen.dart';
import '../../models/kelengkapan_model.dart';
import '../../services/kelengkapan_service.dart';

class KelengkapanScreen extends StatefulWidget {
  const KelengkapanScreen({super.key});

  @override
  State<KelengkapanScreen> createState() => _KelengkapanScreenState();
}

class _KelengkapanScreenState extends State<KelengkapanScreen> {
  late Future<KelengkapanResponse> _futureKelengkapan;
  final KelengkapanService _service = KelengkapanService();

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
  void initState() {
    super.initState();
    _futureKelengkapan = _service.fetchKelengkapanData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 229, 229),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
        titleSpacing: 0, 
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
              onPressed: () => Navigator.of(context).pop(),
              padding: const EdgeInsets.only(left: 8, right: 4), 
              constraints: const BoxConstraints(), 
            ),
            Text(
              'Kelengkapan',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<KelengkapanResponse>(
        future: _futureKelengkapan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Terjadi kesalahan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${snapshot.error}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          final perilaku = snapshot.data!;
          final santriList = perilaku.data.dataSantri;

          return Column(
            children: [
              const SizedBox(height: 16),
              _buildStatsSummary(santriList),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: santriList.length,
                  itemBuilder: (context, index) {
                    final santri = santriList[index];
                    return _buildSantriCard(santri, index);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsSummary(List<DataSantri> santriList) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Total Santri", "${santriList.length}", Icons.people_rounded),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildStatItem("Penilaian", "3 Aspek", Icons.assessment_rounded),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSantriCard(DataSantri santri, int index) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      santri.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      santri.tanggal,
                      style: const TextStyle(
                        color: Color(0xFF4A5568),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailKelengkapanScreen(noInduk: santri.noInduk),
                    ),
                  );

                  if (result == true) {
                    // Refresh data
                    setState(() {
                      _futureKelengkapan = _service.fetchKelengkapanData();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  elevation: 2,
                ),
                icon: const Icon(Icons.visibility, size: 13, color: Colors.white),
                label: const Text(
                  'Detail',
                  style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Skor Kelengkapan
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 8,
            children: [
              _buildScoreRow(Icons.shower, "Mandi", santri.perlengkapanMandi, getBackgroundColor(santri.perlengkapanMandi)),
              _buildScoreRow(Icons.school, "Alat Sekolah", santri.peralatanSekolah, getBackgroundColor(santri.peralatanSekolah)),
              _buildScoreRow(Icons.checkroom, "Perlengkapan Diri", santri.perlengkapanDiri, getBackgroundColor(santri.perlengkapanDiri)),
            ],
          ),
        ],
      ),
    ),
  );
}


  Widget _buildScoreRow(IconData icon, String label, String score, Color color) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
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
              Flexible(
                child: Text(
                  score,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
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