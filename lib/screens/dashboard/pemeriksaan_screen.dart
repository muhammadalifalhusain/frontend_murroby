import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../models/pemeriksaan_model.dart';
import '../../services/pemeriksaan_service.dart';
import 'detail_pemeriksaan_screen.dart';

class PemeriksaanScreen extends StatefulWidget {
  const PemeriksaanScreen({Key? key}) : super(key: key);

  @override
  _PemeriksaanScreenState createState() => _PemeriksaanScreenState();
}

class _PemeriksaanScreenState extends State<PemeriksaanScreen> {
  late Future<PemeriksaanResponse> _pemeriksaanFuture;
  final PemeriksaanService _service = PemeriksaanService();

  @override
  void initState() {
    super.initState();
    _pemeriksaanFuture = _service.getPemeriksaanData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 2,
        toolbarHeight: 56,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32,color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'Pemeriksaan',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: FutureBuilder<PemeriksaanResponse>(
        future: _pemeriksaanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final data = snapshot.data!;
          final user = data.data.dataUser;
          final santriList = data.data.dataSantri;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            'https://manajemen.ppatq-rf.id/assets/img/upload/photo/${user.fotoMurroby}',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.namaMurroby,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kamar: ${user.kodeKamar}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Daftar Santri',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Santri List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: santriList.length,
                  itemBuilder: (context, index) {
                    final santri = santriList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ExpansionTile(
                        title: Text(
                          santri.nama,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('No. Induk: ${santri.noInduk}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildInfoRow('Tanggal Pemeriksaan',
                                    santri.tanggalPemeriksaan ?? 'Belum diperiksa'),
                                const Divider(),
                                _buildInfoRow('Tinggi Badan',
                                    santri.tinggiBadan?.toString() ?? '-'),
                                const Divider(),
                                _buildInfoRow('Berat Badan',
                                    santri.beratBadan?.toString() ?? '-'),
                                const SizedBox(height: 16),
                                ElevatedButton(
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
                                  child: const Text('Lihat Detail Pemeriksaan'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }
}