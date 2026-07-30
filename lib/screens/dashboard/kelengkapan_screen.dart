
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/kelengkapan_model.dart';
import '../../services/kelengkapan_service.dart';
import 'detail_kelengkapan_screen.dart';

class KelengkapanScreen extends StatefulWidget {
  const KelengkapanScreen({super.key});

  @override
  State<KelengkapanScreen> createState() => _KelengkapanScreenState();
}

class _KelengkapanScreenState extends State<KelengkapanScreen> {
  late Future<KelengkapanResponse> _futureKelengkapan;

  static const Color _primaryColor = Color(0xFF43A047);
  static const Color _backgroundColor = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureKelengkapan =
        KelengkapanService.fetchKelengkapanData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });

    await _futureKelengkapan;
  }

  Color _getStatusColor(String value) {
    switch (value.toLowerCase().trim()) {
      case 'lengkap & baik':
        return const Color(0xFF43A047);

      case 'lengkap & kurang baik':
        return const Color(0xFFFFA000);

      case 'tidak lengkap':
        return const Color(0xFFE53935);

      default:
        return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
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
          'Kelengkapan',
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: FutureBuilder<KelengkapanResponse>(
        future: _futureKelengkapan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(
              snapshot.error.toString(),
            );
          }

          if (!snapshot.hasData) {
            return _buildEmptyState();
          }

          final data = snapshot.data!;
          final santriList = data.data.dataSantri;

          if (santriList.isEmpty) {
            return RefreshIndicator(
              color: _primaryColor,
              onRefresh: _refreshData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  _buildEmptyState(),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: _primaryColor,
            onRefresh: _refreshData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                100,
              ),
              children: [
                _buildStatsSummary(santriList),
                const SizedBox(height: 20),
                Text(
                  'Data Kelengkapan Santri',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                ...santriList.asMap().entries.map(
                  (entry) {
                    return _buildSantriCard(
                      entry.value,
                      entry.key,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsSummary(List<DataSantri> santriList) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE7E7E7),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.people_alt_outlined,
              title: 'Total Santri',
              value: '${santriList.length}',
            ),
          ),
          Container(
            width: 1,
            height: 42,
            color: const Color(0xFFE7E7E7),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.inventory_2_outlined,
              title: 'Aspek',
              value: '3',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: _primaryColor,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSantriCard(
    DataSantri santri,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE7E7E7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      santri.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'No. Induk : ${santri.noInduk}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 11,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 5),
                        Text(
                          santri.tanggal,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => _openDetail(santri),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: const BorderSide(
                    color: _primaryColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 15,
                ),
                label: Text(
                  'Detail',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(
            height: 1,
            color: Color(0xFFEDEDED),
          ),
          const SizedBox(height: 12),
          _buildCompletenessGrid(santri),
        ],
      ),
    );
  }

  Widget _buildCompletenessGrid(DataSantri santri) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildScoreItem(
                icon: Icons.shower_outlined,
                label: 'Mandi',
                value: santri.perlengkapanMandi,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildScoreItem(
                icon: Icons.school_outlined,
                label: 'Alat Sekolah',
                value: santri.peralatanSekolah,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildScoreItem(
                icon: Icons.checkroom_outlined,
                label: 'Perlengkapan Diri',
                value: santri.perlengkapanDiri,
              ),
            ),
            const Expanded(
              child: SizedBox(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final color = _getStatusColor(value);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFEDEDED),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDetail(DataSantri santri) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailKelengkapanScreen(
          noInduk: santri.noInduk,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _loadData();
      });
    }
  }

  Widget _buildLoadingState() {
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
                _primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Memuat data kelengkapan...',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _loadData();
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: const BorderSide(
                  color: _primaryColor,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 44,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Data Tidak Tersedia',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Belum ada data kelengkapan santri yang tersedia.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

