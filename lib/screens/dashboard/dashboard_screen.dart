import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../login_screen.dart';
import '../../services/dashboard_service.dart';
import '../../models/dashboard_model.dart';
import '../../widgets/menu_widget.dart';
import '../../utils/session_manager.dart';
import '../../services/login_service.dart';
import '../../config/app_config.dart';
import '../../widgets/dashboard_bottom_bar.dart';
import 'pelanggaran_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<UserDataResponse> _userDataFuture;
  String _namaMurroby = '';
  String _photo = '';

  @override
  void initState() {
    super.initState();

  _loadSession();
  _userDataFuture = _fetchUserData();
  }

  Future<void> _loadSession() async {
    _namaMurroby = await SessionManager.getNamaMurroby();
    _photo = await SessionManager.getPhoto();

    if (mounted) {
      setState(() {});
    }
  }

  Future<UserDataResponse> _fetchUserData() async {
    try {
      return await ApiService.fetchUserData();
    } catch (e) {
      throw Exception('Gagal memuat data: ${e.toString()}');
    }
  }

  void _loginUlang(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>  LoginScreenMurroby(),
      ),
      (route) => false,
    );
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 229, 229),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Selamat Datang',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    _namaMurroby,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'V1.1.11',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ),
        ],
      ),

      body: FutureBuilder<UserDataResponse>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return _buildEmptyDataWidget();
          }

          final userData = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildDashboardContent(userData),
          );
        },
      ),

      // ================= FLOATING CAMERA =================

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "camera",
            backgroundColor: const Color(0xFF2E7D32),
            elevation: 8,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PelanggaranScreen(),
                ),
              );
            },
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "Pelanggaran",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      // ================= BOTTOM BAR =================

      bottomNavigationBar: DashboardBottomBar(
        onDashboard: () {
        },

        onLogout: () async {
          final result = await LoginService.logout();

          if (result['success']) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => LoginScreenMurroby(),
              ),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message']),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDashboardContent(UserDataResponse userData) {
    final murroby = userData.data.dataUser;
    final santriList = userData.data.listSantri;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMurrobyProfileCard(
            murroby,
            santriList,
          ),
          MenuIkonWidget(),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Santri Binaan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 8),

          _buildSantriList(santriList),
        ],
      ),
    );
  }
  Widget _buildMurrobyProfileCard(
    DataUser murroby,
    List<Santri> santriList,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF43A047),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white,
                    backgroundImage: murroby.fotoMurroby.isNotEmpty
                        ? NetworkImage(
                            AppConfig.murrobyPhoto(
                              murroby.fotoMurroby,
                            ),
                          )
                        : null,
                    child: murroby.fotoMurroby.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Color(0xFF2E7D32),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        murroby.namaMurroby,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        murroby.alamatMurroby,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Divider(
              color: Colors.white.withOpacity(.35),
              thickness: 1,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  "Asrama",
                  murroby.kodeKamar,
                ),

                _buildInfoItem(
                  "Santri",
                  santriList.length.toString(),
                ),

                _buildInfoItem(
                  "Kelas",
                  santriList.isNotEmpty
                      ? santriList.first.kelasSantri
                      : "-",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(
    String title,
    String value,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(.75),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildSantriList(List<Santri> santriList) {
    return Column(
      
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [    
        ...santriList.map((santri) => _buildSantriCard(santri)).toList(),
      ],
    );
  }

  Widget _buildSantriCard(Santri santri) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: santri.fotoSantri.isNotEmpty
                      ? NetworkImage(
                          '${AppConfig.santriPhotoPath}/${santri.fotoSantri}',
                        )
                      : null,
                  child: santri.fotoSantri.isEmpty
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        santri.namaSantri,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        'NIS : ${santri.noIndukSantri} • ${santri.kelasSantri}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildInfoRow(
              Icons.phone,
              santri.noHpSantri ?? '-',
            ),

            const SizedBox(height: 6),

            _buildInfoRow(
              Icons.location_on_outlined,
              santri.alamatLengkap ?? '-',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Icon(
          icon,
          size: 16,
          color: const Color(0xFF2E7D32),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
            ),
            const SizedBox(height: 16),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF4A5568)),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () => _loginUlang(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Kembali',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 48,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada data tersedia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Silahkan refresh atau cek koneksi internet Anda',
            style: TextStyle(color: Color(0xFF4A5568)),
          ),
        ],
      ),
    );
  }
}