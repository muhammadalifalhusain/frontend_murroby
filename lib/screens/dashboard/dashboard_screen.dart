import 'package:flutter/material.dart';
import '../../services/login_service.dart';

class DashboardMurrobyScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> murrobyData;

  const DashboardMurrobyScreen({
    Key? key,
    required this.userId,
    required this.murrobyData,
  }) : super(key: key);

  @override
  _DashboardMurrobyScreenState createState() => _DashboardMurrobyScreenState();
}

class _DashboardMurrobyScreenState extends State<DashboardMurrobyScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? userData;
  List<dynamic> santriList = [];
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const String fotoGaleriBaseUrl =
      "https://manajemen.ppatq-rf.id/assets/img/upload/photo/";

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
    fetchDashboard();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchDashboard() async {
    final result = await LoginService.fetchDashboardData(widget.userId);

    if (result['success']) {
      setState(() {
        userData = result['data']['dataUser'];
        santriList = result['data']['listSantri'];
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

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final photoUrl =
        widget.murrobyData['photo'] != null && widget.murrobyData['photo'] != ''
            ? fotoGaleriBaseUrl + widget.murrobyData['photo']
            : null;

    final namaMurroby = widget.murrobyData['nama'] ?? 'Nama tidak tersedia';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: Colors.teal,
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(namaMurroby, photoUrl),
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatsCards(size),
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF00695C), Color(0xFF004D40)],
        ),
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

  Widget _buildSliverAppBar(String namaMurroby, String? photoUrl) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Color(0xFF7B9080),
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Calculate the collapse ratio
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
                'Dashboard',
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
                        namaMurroby,
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

  Widget _buildStatsCards(Size size) {
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
          child: _buildStatCard(
            title: 'Kode Kamar',
            value: userData?['kodeKamar'] ?? '-',
            icon: Icons.home,
            color: Colors.orange,
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
              'Santri Binaan',
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
          _buildEmptyState()
        else
          _buildSantriList(),
      ],
    );
  }

  Widget _buildEmptyState() {
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
            Icons.school_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada santri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Santri binaan akan muncul di sini',
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

  Widget _buildSantriCard(Map<String, dynamic> santri, int index) {
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
            // Handle santri detail tap
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
                        santri['namaSantri'] ?? 'Nama tidak tersedia',
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
                            Icons.class_,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kelas ${santri['kelasSantri'] ?? '-'}',
                            style: TextStyle(
                              fontSize: 14,
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
                    'NoInduk: ${santri['noIndukSantri']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}