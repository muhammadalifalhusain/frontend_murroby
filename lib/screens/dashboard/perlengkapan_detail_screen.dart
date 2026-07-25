import 'package:flutter/material.dart';
import '../../models/perlengkapan_model.dart';

class DetailPerlengkapanScreen extends StatelessWidget {
  final PerlengkapanModel perlengkapan;

  const DetailPerlengkapanScreen({super.key, required this.perlengkapan});

  Widget _buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? '-')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Perlengkapan'),
        backgroundColor: const Color(0xFF5B913B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('Nama', perlengkapan.nama),
            _buildRow('Tanggal', perlengkapan.tanggal),
            _buildRow('Buku', '${perlengkapan.buku} (${perlengkapan.bukuLayak})'),
            _buildRow('Pensil', '${perlengkapan.pensil} (${perlengkapan.pensilLayak})'),
            _buildRow('Bolpoin', '${perlengkapan.bolpoin} (${perlengkapan.bolpoinLayak})'),
            _buildRow('Penghapus', '${perlengkapan.penghapus} (${perlengkapan.penghapusLayak})'),
            _buildRow('Penggaris', '${perlengkapan.penggaris} (${perlengkapan.penggarisLayak})'),
            _buildRow('Box Pensil', '${perlengkapan.boxPensil} (${perlengkapan.boxPensilLayak})'),
            _buildRow('Pakaian Putih', '${perlengkapan.putih} (${perlengkapan.putihLayak})'),
            _buildRow('Coklat', '${perlengkapan.coklat} (${perlengkapan.coklatLayak})'),
            _buildRow('Kerudung', '${perlengkapan.kerudung} (${perlengkapan.kerudungLayak})'),
            _buildRow('Sepatu', '${perlengkapan.sepatu} (${perlengkapan.sepatuLayak})'),
            _buildRow('Peci', '${perlengkapan.peci} (${perlengkapan.peciLayak})'),
            _buildRow('Ikat Pinggang', '${perlengkapan.ikatPinggang} (${perlengkapan.ikatPinggangLayak})'),
            _buildRow('Mukenah', '${perlengkapan.mukenah} (${perlengkapan.mukenahLayak})'),
            _buildRow('Al-Quran', '${perlengkapan.alQuran} (${perlengkapan.alQuranLayak})'),
            _buildRow('Keterangan', perlengkapan.keterangan),
            _buildRow('Nama Pengisi', perlengkapan.namaPengisi),
          ],
        ),
      ),
    );
  }
}
