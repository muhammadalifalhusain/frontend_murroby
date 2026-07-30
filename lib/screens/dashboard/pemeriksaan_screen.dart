import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/pemeriksaan_model.dart';
import '../../services/pemeriksaan_service.dart';
import 'detail_pemeriksaan_screen.dart';

class PemeriksaanScreen extends StatefulWidget {
  const PemeriksaanScreen({Key? key}) : super(key: key);

  @override
  State<PemeriksaanScreen> createState() => _PemeriksaanScreenState();
}

class _PemeriksaanScreenState extends State<PemeriksaanScreen> {
  late Future<PemeriksaanResponse> _pemeriksaanFuture;

  @override
  void initState() {
    super.initState();
    _pemeriksaanFuture = PemeriksaanService.getPemeriksaanData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _pemeriksaanFuture = PemeriksaanService.getPemeriksaanData();
    });

    await _pemeriksaanFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pemeriksaan',
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: FutureBuilder<PemeriksaanResponse>(
        future: _pemeriksaanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingWidget();
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return _buildEmptyDataWidget();
          }

          final santriList = snapshot.data!.data.dataSantri;

          if (santriList.isEmpty) {
            return _buildEmptyDataWidget();
          }

          return RefreshIndicator(
            color: const Color(0xFF43A047),
            onRefresh: _refreshData,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                100,
              ),
              itemCount: santriList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _buildSantriItem(santriList[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSantriItem(DataSantri santri) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE7E7E7),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(
            Icons.person_outline_rounded,
            color: Colors.grey[600],
            size: 25,
          ),
          title: Text(
            santri.nama,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              'NIS: ${santri.noInduk}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
          children: [
            const Divider(
              height: 1,
              color: Color(0xFFEDEDED),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Tanggal Pemeriksaan',
              santri.tanggalPemeriksaanFormatted ?? 'Belum diperiksa',
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.height_rounded,
              'Tinggi Badan',
              '${santri.tinggiBadan?.toString() ?? '-'} cm',
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              Icons.monitor_weight_outlined,
              'Berat Badan',
              '${santri.beratBadan?.toString() ?? '-'} kg',
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPemeriksaanScreen(
                        noInduk: santri.noInduk,
                        namaSantri: santri.nama,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                ),
                label: Text(
                  'Lihat Detail Pemeriksaan',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF43A047),
                  side: const BorderSide(
                    color: Color(0xFF43A047),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF43A047),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Memuat data...',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: Colors.grey[500],
            ),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _refreshData,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF43A047),
                side: const BorderSide(
                  color: Color(0xFF43A047),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Coba Lagi',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDataWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 46,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 14),
            Text(
              'Tidak ada data pemeriksaan',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Belum terdapat data santri yang dapat ditampilkan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
