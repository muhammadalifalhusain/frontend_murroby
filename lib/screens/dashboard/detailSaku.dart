import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:google_fonts/google_fonts.dart';
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

  class _DetailSakuScreenState extends State<DetailSakuScreen> with SingleTickerProviderStateMixin {
    late Future<DetailSakuResponse> futureUangMasuk;
    late Future<DetailSakuResponse> futureUangKeluar;
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    late TabController _tabController;

    @override
    void initState() {
      super.initState();
      _tabController = TabController(length: 2, vsync: this); 
      _refreshData();
    }

    @override
    void dispose() {
      _tabController.dispose(); 
      super.dispose();
    }

    void _refreshData() {
      setState(() {
        futureUangMasuk = DetailSakuService.fetchUangMasuk(widget.noInduk);
        futureUangKeluar = DetailSakuService.fetchUangKeluar(widget.noInduk);
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 229, 229), 
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          toolbarHeight: 64,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              Expanded(
                child: Text(
                  widget.namaSantri,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8F9FF),
                Color(0xFFE8EEFF),
              ],
            ),
          ),
          child: Column(
            children: [ 
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF8B5CF6),
                        Color(0xFF3B82F6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: const EdgeInsets.all(4),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white.withOpacity(0.7),
                        labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        tabs: const [
                          Tab(text: 'Uang Masuk'),
                          Tab(text: 'Uang Keluar'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUangMasukTab(),
                    _buildUangKeluarTab(),
                  ],
                ),
              ),
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      'Terjadi kesalahan',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData ||
              snapshot.data!.dataUangMasuk == null ||
              snapshot.data!.dataUangMasuk!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      'Tidak ada data uang masuk',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final uangMasukList = data.dataUangMasuk!;

          return RefreshIndicator(
            onRefresh: () async {
              _refreshData();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: uangMasukList.length,
              itemBuilder: (context, index) {
                final uangMasuk = uangMasukList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1.5,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                uangMasuk.uangAsal,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            Text(
                              currencyFormat.format(uangMasuk.jumlahMasuk),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(uangMasuk.tanggalTransaksi),
                              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      'Terjadi kesalahan',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${snapshot.error}',
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData ||
              snapshot.data!.dataUangKeluar == null ||
              snapshot.data!.dataUangKeluar!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.money_off_outlined, size: 48, color: Colors.grey),
                    const SizedBox(height: 10),
                    Text(
                      'Tidak ada data uang keluar',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final uangKeluarList = data.dataUangKeluar!;
          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: uangKeluarList.length,
              itemBuilder: (context, index) {
                final uangKeluar = uangKeluarList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      uangKeluar.catatan,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Tanggal: ${_formatDate(uangKeluar.tanggalTransaksi)}',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                        Text(
                          'Petugas: ${uangKeluar.namaMurroby}',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ],
                    ),
                    trailing: Text(
                      currencyFormat.format(uangKeluar.jumlahKeluar),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                );
              },
            ),
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