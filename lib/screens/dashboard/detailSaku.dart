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

class _DetailSakuScreenState extends State<DetailSakuScreen>
    with SingleTickerProviderStateMixin {
  late Future<DetailSakuResponse> futureUangMasuk;
  late Future<DetailSakuResponse> futureUangKeluar;
  late TabController _tabController;
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // untuk melacak panel yang terbuka
  String? expandedMonthMasuk;
  String? expandedMonthKeluar;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      futureUangMasuk = DetailSakuService.fetchUangMasuk(widget.noInduk);
      futureUangKeluar = DetailSakuService.fetchUangKeluar(widget.noInduk);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _monthOrder(String bulan) {
    const urutan = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return urutan.indexOf(bulan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
        titleSpacing: 0, 
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                widget.namaSantri,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 20, color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildTabBar(),
          const SizedBox(height: 8),
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
    );
  }

  Widget _buildTabBar() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Uang Masuk"),
            Tab(text: "Uang Keluar"),
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
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Terjadi kesalahan: ${snapshot.error}",
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          );
        }

        final dataMap = snapshot.data?.dataUangMasuk;
        if (dataMap == null || dataMap.isEmpty) {
          return Center(
            child: Text(
              "Tidak ada data uang masuk",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          );
        }

        final tahunList = dataMap.keys.toList()
          ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));

        return RefreshIndicator(
          onRefresh: () async => _refreshData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tahunList.length,
            itemBuilder: (context, tahunIndex) {
              final tahun = tahunList[tahunIndex];
              final bulanMap = dataMap[tahun] ?? {};
              final bulanList = bulanMap.keys.toList()
                ..sort((a, b) => _monthOrder(b).compareTo(_monthOrder(a)));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Tahun
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 8),
                    child: Text(
                      tahun,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  // List Bulan
                  ...bulanList.map((bulan) {
                    final transaksi = bulanMap[bulan] ?? [];
                    final key = '$tahun-$bulan';
                    final isExpanded = expandedMonthMasuk == key;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header Bulan
                            InkWell(
                              onTap: () {
                                setState(() {
                                  expandedMonthMasuk = isExpanded ? null : key;
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bulan,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${transaksi.length} transaksi",
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.grey[500],
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: isExpanded ? 0.5 : 0,
                                      duration: const Duration(milliseconds: 200),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isExpanded ? '−' : '+',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Body Transaksi
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 250),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: const SizedBox.shrink(),
                              secondChild: Column(
                                children: [
                                  Divider(height: 1, color: Colors.grey[200]),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    itemCount: transaksi.length,
                                    separatorBuilder: (_, __) => Divider(
                                      height: 1,
                                      color: Colors.grey[100],
                                      indent: 20,
                                      endIndent: 20,
                                    ),
                                    itemBuilder: (context, idx) {
                                      final item = transaksi[idx];
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Konten Kiri
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.uangAsal,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black87,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    item.tanggalTransaksi,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            
                                            // Nominal
                                            Text(
                                              currencyFormat.format(item.jumlahMasuk),
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: Colors.green,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
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
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Terjadi kesalahan: ${snapshot.error}",
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          );
        }

        final dataMap = snapshot.data?.dataUangKeluar;
        if (dataMap == null || dataMap.isEmpty) {
          return Center(
            child: Text(
              "Tidak ada data uang keluar",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          );
        }

        final tahunList = dataMap.keys.toList()
          ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));

        return RefreshIndicator(
          onRefresh: () async => _refreshData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tahunList.length,
            itemBuilder: (context, tahunIndex) {
              final tahun = tahunList[tahunIndex];
              final bulanMap = dataMap[tahun] ?? {};
              final bulanList = bulanMap.keys.toList()
                ..sort((a, b) => _monthOrder(b).compareTo(_monthOrder(a)));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Tahun
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 8),
                    child: Text(
                      tahun,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  // List Bulan
                  ...bulanList.map((bulan) {
                    final transaksi = bulanMap[bulan] ?? [];
                    final key = '$tahun-$bulan';
                    final isExpanded = expandedMonthKeluar == key;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header Bulan
                            InkWell(
                              onTap: () {
                                setState(() {
                                  expandedMonthKeluar = isExpanded ? null : key;
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bulan,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${transaksi.length} transaksi",
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.grey[500],
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: isExpanded ? 0.5 : 0,
                                      duration: const Duration(milliseconds: 200),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isExpanded ? '−' : '+',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Body Transaksi
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 250),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: const SizedBox.shrink(),
                              secondChild: Column(
                                children: [
                                  Divider(height: 1, color: Colors.grey[200]),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    itemCount: transaksi.length,
                                    separatorBuilder: (_, __) => Divider(
                                      height: 1,
                                      color: Colors.grey[100],
                                      indent: 20,
                                      endIndent: 20,
                                    ),
                                    itemBuilder: (context, idx) {
                                      final item = transaksi[idx];
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Konten Kiri
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.catatan,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black87,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    item.tanggalTransaksi,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    "Petugas: ${item.namaMurroby}",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            
                                            // Nominal
                                            Text(
                                              currencyFormat.format(item.jumlahKeluar),
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: Colors.redAccent,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        );
      },
    );
  }

}