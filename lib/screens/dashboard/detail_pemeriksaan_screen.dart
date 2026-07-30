
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/pemeriksaan_model.dart';
import '../../services/pemeriksaan_service.dart';
import 'form_pemeriksaan.dart';

class DetailPemeriksaanScreen extends StatefulWidget {
  final int noInduk;
  final String namaSantri;

  const DetailPemeriksaanScreen({
    Key? key,
    required this.noInduk,
    required this.namaSantri,
  }) : super(key: key);

  @override
  State<DetailPemeriksaanScreen> createState() =>
      _DetailPemeriksaanScreenState();
}

class _DetailPemeriksaanScreenState
    extends State<DetailPemeriksaanScreen> {
  late Future<PemeriksaanDetailResponse> _detailFuture;

  static const Color primaryColor = Color(0xFF43A047);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color borderColor = Color(0xFFE7E7E7);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _detailFuture =
        PemeriksaanService.getPemeriksaanDetail(widget.noInduk);
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });

    await _detailFuture;
  }

  Future<void> _addPemeriksaan(
    int noInduk,
    String namaSantri,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PemeriksaanFormScreen(
          noInduk: noInduk.toString(),
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

  Future<void> _editPemeriksaan(
    dynamic pemeriksaan,
  ) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Edit Pemeriksaan',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: Text(
            'Fitur edit pemeriksaan belum tersedia.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePemeriksaan(
    DataPemeriksaan pemeriksaan,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Hapus pemeriksaan?',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: Text(
            'Data pemeriksaan ini akan dihapus dan tidak dapat dikembalikan.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                'Hapus',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final success =
          await PemeriksaanService.deletePemeriksaan(
        pemeriksaan.id,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pemeriksaan berhasil dihapus',
              style: GoogleFonts.poppins(
                fontSize: 13,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        setState(() {
          _loadData();
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus pemeriksaan: $e',
            style: GoogleFonts.poppins(
              fontSize: 13,
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Detail Pemeriksaan',
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: FutureBuilder<PemeriksaanDetailResponse>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
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

          final response = snapshot.data!;
          final santri = response.data.dataSantri;
          final pemeriksaanList =
              response.data.dataPemeriksaan;

          return Stack(
            children: [
              RefreshIndicator(
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
                    _buildSantriHeader(santri),
                    const SizedBox(height: 20),
                    Text(
                      'Riwayat Pemeriksaan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (pemeriksaanList.isEmpty)
                      _buildNoPemeriksaanState()
                    else
                      ...pemeriksaanList.asMap().entries.map(
                        (entry) {
                          return _buildPemeriksaanItem(
                            entry.value,
                            entry.key,
                          );
                        },
                      ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    _addPemeriksaan(
                      santri.noInduk,
                      santri.nama,
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSantriHeader(
    DataSantriDetail santri,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            santri.nama,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No. Induk : ${santri.noInduk}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPemeriksaanItem(
    DataPemeriksaan pemeriksaan,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.fromLTRB(
        16,
        15,
        10,
        16,
      ),
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
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pemeriksaan ${index + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatDate(
                            pemeriksaan.tanggalPemeriksaanDate,
                          ),
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
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.grey[600],
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editPemeriksaan(
                        pemeriksaan,
                      );
                      break;
                    case 'delete':
                      _deletePemeriksaan(
                        pemeriksaan,
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Edit',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.red[500],
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Hapus',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.red[500],
                          ),
                        ),
                      ],
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
          _buildInfoRow(
            'Tinggi Badan',
            pemeriksaan.tinggiBadan != null
                ? '${pemeriksaan.tinggiBadan} cm'
                : '-',
          ),
          _buildInfoRow(
            'Berat Badan',
            pemeriksaan.beratBadan != null
                ? '${pemeriksaan.beratBadan} kg'
                : '-',
          ),
          _buildInfoRow(
            'Lingkar Pinggul',
            pemeriksaan.lingkarPinggul != null
                ? '${pemeriksaan.lingkarPinggul} cm'
                : '-',
          ),
          _buildInfoRow(
            'Lingkar Dada',
            pemeriksaan.lingkarDada != null
                ? '${pemeriksaan.lingkarDada} cm'
                : '-',
          ),
          _buildInfoRow(
            'Kondisi Gigi',
            pemeriksaan.kondisiGigi ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 12),
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
      ),
    );
  }

  Widget _buildNoPemeriksaanState() {
    return Container(
      margin: const EdgeInsets.only(
        top: 4,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 42,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Belum Ada Pemeriksaan',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Belum terdapat riwayat pemeriksaan untuk santri ini.',
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
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Memuat data pemeriksaan...',
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
                  borderRadius:
                      BorderRadius.circular(8),
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
              'Tidak ada data pemeriksaan yang ditemukan.',
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

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '-';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
