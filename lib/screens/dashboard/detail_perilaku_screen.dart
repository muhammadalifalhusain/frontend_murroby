
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'form_perilaku_screen.dart';
import '../../models/perilaku_model.dart';
import '../../services/perilaku_service.dart';

class DetailPerilakuScreen extends StatefulWidget {
  final int noInduk;

  const DetailPerilakuScreen({
    Key? key,
    required this.noInduk,
  }) : super(key: key);

  @override
  State<DetailPerilakuScreen> createState() => _DetailPerilakuScreenState();
}

class _DetailPerilakuScreenState extends State<DetailPerilakuScreen> {
  late Future<DetailPerilakuResponse> _futureDetail;

  static const Color primaryColor = Color(0xFF43A047);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color borderColor = Color(0xFFE7E7E7);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureDetail =
        PerilakuService.fetchDetailPerilaku(widget.noInduk);
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });

    await _futureDetail;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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

  Future<void> _addPerilaku(String namaSantri) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormPerilakuScreen(
          noInduk: widget.noInduk,
          namaSantri: namaSantri,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _loadData();
      });
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
          onPressed: () => Navigator.of(context).pop(true),
        ),
        title: Text(
          'Detail Perilaku',
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: FutureBuilder<DetailPerilakuResponse>(
        future: _futureDetail,
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
            return _buildEmptyDataState();
          }

          final data = snapshot.data!;
          final perilakuList = data.data.dataPerilaku;
          final namaSantri = data.data.namaSantri;

          return RefreshIndicator(
            color: primaryColor,
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
                _buildSantriHeader(
                  namaSantri,
                  perilakuList.length,
                ),
                const SizedBox(height: 20),
                Text(
                  'Riwayat Perilaku',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                if (perilakuList.isEmpty)
                  _buildNoPerilakuState()
                else
                  ...perilakuList.map(
                    (item) => _buildPerilakuItem(item),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FutureBuilder<DetailPerilakuResponse>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed: () {
              _addPerilaku(
                snapshot.data!.data.namaSantri,
              );
            },
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            icon: const Icon(
              Icons.add_rounded,
            ),
            label: Text(
              'Tambah',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSantriHeader(
    String namaSantri,
    int jumlahCatatan,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaSantri,
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
                  '$jumlahCatatan catatan perilaku',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerilakuItem(ItemPerilaku item) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
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
            children: [
              Expanded(
                child: Text(
                  'Catatan Perilaku',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 5),
                  Text(
                    item.tanggal,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            color: Color(0xFFEDEDED),
          ),
          const SizedBox(height: 8),
          _buildScoreGrid(item),
        ],
      ),
    );
  }

  Widget _buildScoreGrid(ItemPerilaku item) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 4,
      childAspectRatio: 3.8,
      children: [
        _buildScoreItem(
          Icons.rule_rounded,
          'Ketertiban',
          item.ketertiban,
        ),
        _buildScoreItem(
          Icons.cleaning_services_outlined,
          'Kebersihan',
          item.kebersihan,
        ),
        _buildScoreItem(
          Icons.timer_outlined,
          'Kedisiplinan',
          item.kedisiplinan,
        ),
        _buildScoreItem(
          Icons.checkroom_outlined,
          'Kerapian',
          item.kerapian,
        ),
        _buildScoreItem(
          Icons.waving_hand_outlined,
          'Kesopanan',
          item.kesopanan,
        ),
        _buildScoreItem(
          Icons.nature_people_outlined,
          'Kepekaan Lingkungan',
          item.kepekaanLingkungan,
        ),
        _buildScoreItem(
          Icons.gavel_outlined,
          'Ketaatan Peraturan',
          item.ketaatanPeraturan,
        ),
      ],
    );
  }

  Widget _buildScoreItem(
    IconData icon,
    String label,
    String score,
  ) {
    final color = _getStatusColor(score);

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

  Widget _buildNoPerilakuState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 60,
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 44,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Belum Ada Catatan',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Catatan perilaku santri belum tersedia.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.4,
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

  Widget _buildEmptyDataState() {
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
              'Data perilaku santri tidak ditemukan.',
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
