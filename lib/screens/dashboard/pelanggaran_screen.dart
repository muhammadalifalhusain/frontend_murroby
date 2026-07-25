import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
import '../../services/pelanggaran_service.dart';
import '../../models/pelanggaran_model.dart';
import 'tambah_pelanggaran_screen.dart';

class PelanggaranScreen extends StatefulWidget {
  const PelanggaranScreen({super.key});

  @override
  State<PelanggaranScreen> createState() => _PelanggaranScreenState();
}

class _PelanggaranScreenState extends State<PelanggaranScreen> {
  late Future<List<Pelanggaran>> _pelanggaranFuture;

  @override
  void initState() {
    super.initState();
    _loadPelanggaran();
  }

  void _loadPelanggaran() {
    setState(() {
      _pelanggaranFuture = PelanggaranService.fetchPelanggaran();
    });
  }

  Color _getSeverityColor(String? kategori) {
    final value = (kategori ?? '').toLowerCase();
    switch (value) {
      case 'ringan':
        return const Color.fromARGB(255, 233, 163, 106);
      case 'berat':
        return Colors.red;
      case '-':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade600;
    }
  }

  FaIconData _getSeverityIcon(String? kategori) {
    final value = (kategori ?? '').toLowerCase();

    switch (value) {
      case 'ringan':
        return FontAwesomeIcons.triangleExclamation;

      case 'berat':
        return FontAwesomeIcons.circleExclamation;

      case '-':
        return FontAwesomeIcons.minus;

      default:
        return FontAwesomeIcons.circleQuestion;
  }
}

  Future<void> _deletePelanggaran(String id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Hapus Data', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus data ini?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins(color: Color(0xFF004e92))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await PelanggaranService.deletePelanggaran(int.parse(id));
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil menghapus data', style: GoogleFonts.poppins()),
            backgroundColor: Color(0xFF004e92),
          ),
        );
        _loadPelanggaran();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus data', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDetailItem(String label, String value) {
    final bool isEmpty = value.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isEmpty ? Colors.grey[100] : Colors.blue[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isEmpty ? 'Tidak ada catatan' : value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w600,
                  fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                  color: isEmpty ? Colors.grey[500] : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(  
        backgroundColor: Color(0xFF004e92),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pelanggaran',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadPelanggaran();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: Color(0xFF004e92),
        child: FutureBuilder<List<Pelanggaran>>(
          future: _pelanggaranFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Color(0xFF004e92)),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text('Terjadi Kesalahan', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red[700])),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadPelanggaran,
                      icon: const Icon(Icons.refresh),
                      label: Text('Coba Lagi', style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF004e92), foregroundColor: Colors.white),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              final dataList = snapshot.data!;
              if (dataList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.triangleExclamation,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text('Belum Ada Data Pelanggaran', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dataList.length,
                itemBuilder: (context, index) {
                  final pelanggaran = dataList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getSeverityColor(pelanggaran.kategori).withOpacity(0.2), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getSeverityColor(pelanggaran.kategori).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: FaIcon(_getSeverityIcon(pelanggaran.kategori), color: _getSeverityColor(pelanggaran.kategori), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pelanggaran.jenisPelanggaran, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.grey[800])),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getSeverityColor(pelanggaran.kategori).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(pelanggaran.kategori.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _getSeverityColor(pelanggaran.kategori))),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(height: 1, color: Colors.grey[200]),
                          const SizedBox(height: 8),
                          _buildDetailItem('Tanggal', pelanggaran.tanggal),
                          _buildDetailItem('Hukuman', pelanggaran.hukuman),
                          _buildDetailItem('Pengisi', pelanggaran.namaPengisi),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await Navigator.push(context, MaterialPageRoute(builder: (_) => PostPelanggaranScreen(pelanggaran: pelanggaran)));
                                  _loadPelanggaran();
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deletePelanggaran(pelanggaran.id.toString()),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('Tidak ada data'));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostPelanggaranScreen()),
          );
          if (result == true) _loadPelanggaran();
        },
        backgroundColor: const Color(0xFF004e92),
        label: Text(
          'Tambah',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}