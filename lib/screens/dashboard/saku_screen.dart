import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:murroby/models/saku_model.dart';
import 'package:murroby/services/saku_service.dart';
import 'detailSaku.dart';

class UangSakuScreen extends StatefulWidget {
  final int userId;

  const UangSakuScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<UangSakuScreen> createState() => _UangSakuScreenState();
}

class _UangSakuScreenState extends State<UangSakuScreen>
    with SingleTickerProviderStateMixin {
  MurrobyData? murroby;
  List<SantriUangSaku> santriList = [];
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const String fotoGaleriBaseUrl ="https://manajemen.ppatq-rf.id/assets/img/upload/photo/";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    fetchData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    final result = await UangSakuService.fetchUangSaku(widget.userId);

    if (result['success']) {
      setState(() {
        murroby = result['murroby'];
        santriList = result['santriList'];
        isLoading = false;
      });
      _animationController.forward();
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal mengambil data'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: isLoading
          ? _buildLoadingState()
          : murroby == null
              ? _buildEmptyState(message: 'Data murroby tidak ditemukan')
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: Color(0xFF7B9080),
                  child: CustomScrollView(
                    slivers: [
                      _buildSliverAppBar(),
                      SliverToBoxAdapter(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatsCards(),
                                const SizedBox(height: 24),
                                _buildSantriSection(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

  Widget _buildLoadingState() {
      return Container(
        decoration: const BoxDecoration(
        color: Color(0xFF7B9080),
      ),

      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat data...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final photoUrl = murroby!.foto != null && murroby!.foto != ''
        ? fotoGaleriBaseUrl + murroby!.foto
        : null;

    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF7B9080),
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double top = constraints.biggest.height;
          final double collapsedHeight =
              kToolbarHeight + MediaQuery.of(context).padding.top;
          final double expandedHeight =
              180 + MediaQuery.of(context).padding.top;
          final double shrinkOffset = expandedHeight - top;
          final double shrinkRatio =
              shrinkOffset / (expandedHeight - collapsedHeight);
          final double titleOpacity = shrinkRatio.clamp(0.0, 1.0);

          return FlexibleSpaceBar(
            centerTitle: true,
            title: AnimatedOpacity(
              opacity: titleOpacity,
              duration: const Duration(milliseconds: 100),
              child: const Text(
                'Saku Santri',
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
                  padding: const EdgeInsets.all(17.0),
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
                            backgroundImage:
                                photoUrl != null ? NetworkImage(photoUrl) : null,
                            backgroundColor: Colors.white,
                            child: photoUrl == null
                                ? Icon(Icons.person,
                                    size: 40, color: Colors.teal[600])
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        murroby!.nama,
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


  Widget _buildStatsCards() {
    double totalSaldo = santriList.fold(
      0.0, (double sum, santri) => sum + (santri.jumlahSaldo ?? 0));
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Santri',
            value: santriList.length.toString(),
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.account_balance_wallet, 
                    color: Colors.green, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  currencyFormat.format(totalSaldo),
                  style: const TextStyle( 
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSantriSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Detail Saku',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (santriList.isEmpty)
          _buildEmptyState(message: 'Belum ada data santri')
        else
          _buildSantriList(),
      ],
    );
  }

  Widget _buildEmptyState({required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSantriList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: santriList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final santri = santriList[index];
        return _buildSantriCard(santri, index);
      },
    );
  }

  Widget _buildSantriCard(SantriUangSaku santri, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailSakuScreen(
                noInduk: santri.noIndukSantri,
                namaSantri: santri.namaSantri,
              ),
            ),
          );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        santri.namaSantri,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Saldo: ${currencyFormat.format(santri.jumlahSaldo ?? 0)}', 
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    santri.noIndukSantri.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}