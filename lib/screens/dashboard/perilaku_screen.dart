
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'detail_perilaku_screen.dart';
import '../../models/perilaku_model.dart';
import '../../services/perilaku_service.dart';

class PerilakuScreen extends StatefulWidget {
  const PerilakuScreen({super.key});

  @override
  State<PerilakuScreen> createState() => _PerilakuScreenState();
}

class _PerilakuScreenState extends State<PerilakuScreen> {
  late Future<PerilakuResponse> _futurePerilaku;

  static const Color primaryColor = Color(0xFF43A047);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color borderColor = Color(0xFFE7E7E7);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futurePerilaku = PerilakuService.fetchPerilakuData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });

    await _futurePerilaku;
  }

  Color _getScoreColor(String value) {
    switch (value.toLowerCase()) {
      case 'baik':
        return primaryColor;
      case 'cukup':
        return const Color(0xFFE89B00);
      case 'kurang baik':
        return const Color(0xFFD64545);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
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
          'Perilaku',
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: FutureBuilder<PerilakuResponse>(
        future: _futurePerilaku,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return _buildEmptyState();
          }

          final perilaku = snapshot.data!;
          final santriList = perilaku.data.dataSantri;

          return RefreshIndicator(
            color: primaryColor,
            onRefresh: _refreshData,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                24,
              ),
              children: [
                _buildSummary(santriList),
                const SizedBox(height: 20),
                Text(
                  'Daftar Santri',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                if (santriList.isEmpty)
                  _buildNoSantriState()
                else
                  ...santriList.asMap().entries.map(
                    (entry) => _buildSantriItem(
                      entry.value,
                      entry.key,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummary(List<DataSantri> santriList) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.people_outline_rounded,
              label: 'Total Santri',
              value: '${santriList.length}',
            ),
          ),
          Container(
            width: 1,
            height: 38,
            color: borderColor,
          ),
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.assessment_outlined,
              label: 'Aspek Penilaian',
              value: '6',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 21,
          color: primaryColor,
        ),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSantriItem(
    DataSantri santri,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      santri.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      santri.tanggal,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPerilakuScreen(
                        noInduk: santri.noInduk,
                      ),
                    ),
                  );

                  if (result == true && mounted) {
                    setState(() {
                      _loadData();
                    });
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: const BorderSide(
                    color: primaryColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                ),
                label: Text(
                  'Detail',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Divider(
            height: 1,
            color: Color(0xFFEDEDED),
          ),
          const SizedBox(height: 10),
          _buildScoreGrid(santri),
        ],
      ),
    );
  }

  Widget _buildScoreGrid(DataSantri santri) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 10,
      childAspectRatio: 3.7,
      children: [
        _buildScoreItem(
          Icons.rule_rounded,
          'Ketertiban',
          santri.ketertiban,
        ),
        _buildScoreItem(
          Icons.timer_outlined,
          'Kedisiplinan',
          santri.kedisiplinan,
        ),
        _buildScoreItem(
          Icons.checkroom_outlined,
          'Kerapian',
          santri.kerapian,
        ),
        _buildScoreItem(
          Icons.waving_hand_outlined,
          'Kesopanan',
          santri.kesopanan,
        ),
        _buildScoreItem(
          Icons.nature_people_outlined,
          'Kepekaan Lingkungan',
          santri.kepekaanLingkungan,
        ),
        _buildScoreItem(
          Icons.gavel_outlined,
          'Ketaatan Peraturan',
          santri.ketaatanPeraturan,
        ),
      ],
    );
  }

  Widget _buildScoreItem(
    IconData icon,
    String label,
    String score,
  ) {
    final color = _getScoreColor(score);

    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: color,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 1),
              Text(
                score,
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
    );
  }

  Widget _buildNoSantriState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 60,
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 44,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Belum Ada Data Santri',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Data perilaku santri belum tersedia.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
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
                primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Memuat data perilaku...',
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
                foregroundColor: primaryColor,
                side: const BorderSide(
                  color: primaryColor,
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
              Icons.inbox_outlined,
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
              'Tidak ada data perilaku yang ditemukan.',
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
