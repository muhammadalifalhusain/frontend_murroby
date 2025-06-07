import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'package:murroby/models/detailSaku_model.dart';
import 'package:murroby/services/detailSaku_service.dart';

class DetailSakuScreen extends StatefulWidget {
  final int noInduk;
  final String namaSantri;

  const DetailSakuScreen({
    Key? key,
    required this.noInduk,
    required this.namaSantri,
  }) : super(key: key);

  @override
  _DetailSakuScreenState createState() => _DetailSakuScreenState();
}

class _DetailSakuScreenState extends State<DetailSakuScreen> {
  late Future<DetailSakuResponse> futureUangMasuk;
  late Future<DetailSakuResponse> futureUangKeluar;
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    futureUangMasuk = DetailSakuService.fetchUangMasuk(widget.noInduk);
    futureUangKeluar = DetailSakuService.fetchUangKeluar(widget.noInduk);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.namaSantri),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Uang Masuk'),
              Tab(text: 'Uang Keluar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUangMasukTab(),
            _buildUangKeluarTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildUangMasukTab() {
    return FutureBuilder<DetailSakuResponse>(
      future: futureUangMasuk,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.dataUangMasuk == null) {
          return const Center(child: Text('Tidak ada data uang masuk'));
        }

        final data = snapshot.data!;
        final uangMasukList = data.dataUangMasuk!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: uangMasukList.length,
          itemBuilder: (context, index) {
            final uangMasuk = uangMasukList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          uangMasuk.uangAsal,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currencyFormat.format(uangMasuk.jumlahMasuk),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tanggal: ${_formatDate(uangMasuk.tanggalTransaksi)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUangKeluarTab() {
    return FutureBuilder<DetailSakuResponse>(
      future: futureUangKeluar,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.dataUangKeluar == null) {
          return const Center(child: Text('Tidak ada data uang keluar'));
        }

        final data = snapshot.data!;
        final uangKeluarList = data.dataUangKeluar!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: uangKeluarList.length,
          itemBuilder: (context, index) {
            final uangKeluar = uangKeluarList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          uangKeluar.catatan,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currencyFormat.format(uangKeluar.jumlahKeluar),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tanggal: ${_formatDate(uangKeluar.tanggalTransaksi)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Oleh: ${uangKeluar.namaMurroby}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }
}