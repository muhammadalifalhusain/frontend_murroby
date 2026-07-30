
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pelanggaran_ketertiban_model.dart';
import '../../services/pelanggaran_ketertiban_service.dart';
import 'tambah_pelanggaran_ketertiban_screen.dart';

class PelanggaranKetertibanScreen extends StatefulWidget {
  const PelanggaranKetertibanScreen({super.key});

  @override
  State<PelanggaranKetertibanScreen> createState() =>
      _PelanggaranKetertibanScreenState();
}

class _PelanggaranKetertibanScreenState
    extends State<PelanggaranKetertibanScreen> {
  late Future<List<PelanggaranKetertiban>> _pelanggaranFuture;

  static const Color primaryColor = Color(0xFF004E92);
  static const Color backgroundColor = Color(0xFFF7F8FA);
  static const Color textColor = Color(0xFF1F2937);
  static const Color secondaryTextColor = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _pelanggaranFuture =
        PelanggaranKetertibanService.fetchAll();
  }

  void _refresh() {
    setState(() {
      _pelanggaranFuture =
          PelanggaranKetertibanService.fetchAll();
    });
  }

  Future<void> _hapus(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Hapus Data?',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          content: Text(
            'Data ketertiban ini akan dihapus secara permanen.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            12,
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: secondaryTextColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: Text(
                'Hapus',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await PelanggaranKetertibanService.delete(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Data berhasil dihapus',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      _refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus data',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _navigateToForm({int? id}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FormPelanggaranKetertibanScreen(idEdit: id),
      ),
    );

    if (mounted) {
      _refresh();
    }
  }

  Widget _buildStatusChip(String value) {
    final isGood = value.toLowerCase() == 'bagus';

    final Color color =
        isGood ? Colors.green : Colors.red;

    final IconData icon =
        isGood
            ? Icons.check_circle_outline_rounded
            : Icons.close_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: secondaryTextColor,
              ),
            ),
          ),
          _buildStatusChip(value),
        ],
      ),
    );
  }

  Widget _buildCard(PelanggaranKetertiban item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // Header
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius:
                        BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.rule_rounded,
                    color: primaryColor,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.tanggal,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: secondaryTextColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _navigateToForm(id: item.id);
                    } else if (value == 'delete') {
                      _hapus(item.id);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: primaryColor,
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
                          const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Hapus',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),

            const SizedBox(height: 7),

            // Section title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kondisi Ketertiban',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),

            const SizedBox(height: 4),

            _buildActivityItem(
              'Buang Sampah',
              item.buangSampah,
            ),

            _buildActivityItem(
              'Menata Peralatan',
              item.menataPeralatan,
            ),

            _buildActivityItem(
              'Tidak Berseragam',
              item.tidakBerseragam,
            ),

            const SizedBox(height: 5),

            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 14,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Diisi oleh ${item.namaPengisi}',
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
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
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rule_rounded,
                size: 30,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Data',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Data ketertiban santri belum tersedia.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => _navigateToForm(),
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
              ),
              label: Text(
                'Tambah Data',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(
                  color: primaryColor.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Terjadi kesalahan saat mengambil data ketertiban.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _refresh,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
              ),
              label: Text(
                'Coba Lagi',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: Colors.black87,
          ),
          onPressed: () =>
              Navigator.of(context).pop(),
        ),

        title: Text(
          'Ketertiban',
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 21,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: FutureBuilder<
          List<PelanggaranKetertiban>>(
        future: _pelanggaranFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(
                  primaryColor,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(
              snapshot.error!,
            );
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: primaryColor,
            onRefresh: () async {
              _refresh();
              await _pelanggaranFuture;
            },
            child: ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(
                16,
                14,
                16,
                90,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                return _buildCard(list[index]);
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        backgroundColor: const Color(0xFF43A047),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Tambah',
        ),
      ),
    );
  }
}