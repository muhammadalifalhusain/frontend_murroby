import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/kesehatan_model.dart';
import '../../services/kesehatan_service.dart';

class KesehatanScreen extends StatefulWidget {
  @override
  _KesehatanScreenState createState() => _KesehatanScreenState();
}

class _KesehatanScreenState extends State<KesehatanScreen> {
  late Future<PemeriksaanResponse> futurePemeriksaan;
  static const String fotoGaleriBaseUrl =
      "https://manajemen.ppatq-rf.id/assets/img/upload/photo/";

  @override
  void initState() {
    super.initState();
    futurePemeriksaan = PemeriksaanService().fetchPemeriksaan();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PemeriksaanResponse>(
      future: futurePemeriksaan,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Terjadi kesalahan: ${snapshot.error}")));
        } else if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text("Data tidak ditemukan.")));
        }

        final murroby = snapshot.data!.data.dataUser;
        final santriList = snapshot.data!.data.dataSantri;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(murroby),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: List.generate(santriList.length, (index) {
                      final santri = santriList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ExpansionTile(
                          title: Text(
                            santri.nama,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("No Induk: ${santri.noInduk}"),
                          children: [
                            _buildInfoTile("Tanggal Pemeriksaan",
                                santri.tanggalPemeriksaan != null
                                    ? DateFormat('dd MMM yyyy').format(santri.tanggalPemeriksaan!)
                                    : 'Belum diperiksa'),
                            _buildInfoTile("Tinggi Badan", santri.tinggiBadan?.toString() ?? '-'),
                            _buildInfoTile("Berat Badan", santri.beratBadan?.toString() ?? '-'),
                            _buildInfoTile("Lingkar Pinggul", santri.lingkarPinggul?.toString() ?? '-'),
                            _buildInfoTile("Lingkar Dada", santri.lingkarDada?.toString() ?? '-'),
                            _buildInfoTile("Kondisi Gigi", santri.kondisiGigi ?? '-'),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
    );
  }

  Widget _buildSliverAppBar(DataUser murroby) {
    final photoUrl = murroby.fotoMurroby != null && murroby.fotoMurroby.isNotEmpty
        ? fotoGaleriBaseUrl + murroby.fotoMurroby
        : null;

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: const Color(0xFF7B9080),
      iconTheme: const IconThemeData(color: Color(0xFFFFE7CD)),
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double top = constraints.biggest.height;
          final double collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
          final double expandedHeight = 180 + MediaQuery.of(context).padding.top;
          final double shrinkOffset = expandedHeight - top;
          final double shrinkRatio = shrinkOffset / (expandedHeight - collapsedHeight);
          final double titleOpacity = shrinkRatio.clamp(0.0, 1.0);

          return FlexibleSpaceBar(
            centerTitle: true,
            title: AnimatedOpacity(
              opacity: titleOpacity,
              duration: const Duration(milliseconds: 100),
              child: const Text(
                'Kesehatan Santri',
                style: TextStyle(
                  color: Color(0xFFFFE7CD),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            background: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF7B9080),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'murroby_photo',
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 38,
                            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                            backgroundColor: Colors.white,
                            child: photoUrl == null
                                ? Icon(Icons.person, size: 40, color: Colors.teal[600])
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        murroby.namaMurroby,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
