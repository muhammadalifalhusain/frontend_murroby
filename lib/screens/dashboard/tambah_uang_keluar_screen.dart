import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';
import '../../services/detailSaku_service.dart';

class TambahUangKeluarScreen extends StatefulWidget {
  const TambahUangKeluarScreen({Key? key}) : super(key: key);

  @override
  State<TambahUangKeluarScreen> createState() => _TambahUangKeluarScreenState();
}

class _TambahUangKeluarScreenState extends State<TambahUangKeluarScreen>
    with TickerProviderStateMixin {
  List<Santri> _santriList = [];
  Santri? _selectedSantri;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  DateTime? _selectedDate;

  bool _isLoading = false;
  bool _isLoadingSantri = true;
  bool _allKamar = false;
  int? _idUser;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _loadSantriList();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _loadSantriList() async {
    try {
      final userData = await ApiService.fetchUserData();
      setState(() {
        _santriList = userData.data.listSantri;
        _idUser = userData.data.dataUser.idPegawai;
        _isLoadingSantri = false;
      });
    } catch (e) {
      setState(() => _isLoadingSantri = false);
      if (mounted) {
        _showErrorSnackBar('Gagal memuat data santri: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submit() async {
  // Validasi pemilihan santri jika allKamar tidak dipilih
  if (!_allKamar && _selectedSantri == null) {
    _showErrorSnackBar("Santri harus dipilih!");
    return;
  }

  // Validasi form dan pemilihan tanggal
  if (!_formKey.currentState!.validate() || _selectedDate == null) {
    if (_selectedDate == null) {
      _showErrorSnackBar("Tanggal harus dipilih!");
    }
    return;
  }

  // Tampilkan dialog konfirmasi
  final confirmed = await _showConfirmationDialog();
  if (!confirmed) return;

  setState(() => _isLoading = true);

  try {
    // Ambil dan bersihkan input jumlah
    final raw = _jumlahController.text;
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final jumlah = int.tryParse(cleaned);

    // Debug print untuk melihat nilai rawText, cleanedText, dan jumlah
    print("Raw Text: $raw");
    print("Cleaned Text: $cleaned");
    print("Jumlah: $jumlah");

    // Validasi jumlah
    if (jumlah == null || jumlah <= 0) {
      _showErrorSnackBar("Jumlah harus berupa angka positif!");
      return;
    }

    // Kirim data ke service
    final result = await DetailSakuService.postUangKeluar(
      jumlah: jumlah,
      catatan: _catatanController.text,
      tanggal: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      allKamar: _allKamar,
      noInduk: _allKamar ? null : _selectedSantri!.noIndukSantri,
    );

    // Tampilkan pesan sukses dan kembali ke halaman sebelumnya
    if (mounted) {
      _showSuccessSnackBar(result);
      Navigator.pop(context, true);
    }
  } catch (e) {
    // Tampilkan pesan kesalahan jika terjadi
    _showErrorSnackBar("Terjadi kesalahan: ${e.toString()}");
  } finally {
    // Set loading state ke false
    setState(() => _isLoading = false);
  }
}


  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.help_outline, color: Colors.red.shade600),
            ),
            const SizedBox(width: 12),
            Text(
              'Konfirmasi',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pastikan data pengeluaran berikut sudah benar:',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            if (_allKamar)
              _buildConfirmationItem('Target', 'Semua Kamar')
            else
            _buildConfirmationItem('Santri', _selectedSantri?.namaSantri ?? ''),
            _buildConfirmationItem(
              'Jumlah',
              'Rp ${NumberFormat('#,##0', 'id').format(
                int.parse(_jumlahController.text.replaceAll(RegExp(r'[^0-9]'), '')),
              )}',
            ),
            _buildConfirmationItem('Catatan', _catatanController.text),
            _buildConfirmationItem('Tanggal', DateFormat('dd MMMM yyyy', 'id').format(_selectedDate!)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Simpan', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildConfirmationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade400,
            Colors.red.shade600,
            Colors.red.shade800,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Tambah Uang Keluar',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Catat pengeluaran uang santri dengan mudah',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllKamarSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _allKamar ? Colors.red.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.group,
                color: _allKamar ? Colors.red.shade600 : Colors.grey.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terapkan ke Semua Santri',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    'Pengeluaran berlaku untuk seluruh santri',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _allKamar,
              onChanged: (val) {
                setState(() {
                  _allKamar = val;
                  if (val) _selectedSantri = null;
                });
              },
              activeColor: Colors.red.shade600,
              inactiveThumbColor: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSantriDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: _allKamar ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _allKamar ? [] : [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<Santri>(
        value: _selectedSantri,
        decoration: InputDecoration(
          labelText: 'Pilih Santri',
          labelStyle: GoogleFonts.poppins(
            color: _allKamar ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: _allKamar ? Colors.grey.shade100 : Colors.white,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _allKamar ? Colors.grey.shade200 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.person,
              color: _allKamar ? Colors.grey.shade400 : Colors.red.shade600,
              size: 20,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: _santriList.map((santri) {
          return DropdownMenuItem<Santri>(
            value: santri,
            child: Text(
              santri.namaSantri,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: _allKamar ? null : (val) => setState(() => _selectedSantri = val),
        validator: (val) => _allKamar ? null : (val == null ? 'Santri harus dipilih' : null),
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: _allKamar ? Colors.grey.shade400 : Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildJumlahField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _jumlahController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          TextInputFormatter.withFunction((oldValue, newValue) {
            String newText = newValue.text.replaceAll('.', '');
            if (newText.isEmpty) return newValue;

            final buffer = StringBuffer();
            for (int i = 0; i < newText.length; i++) {
              if (i != 0 && (newText.length - i) % 3 == 0) {
                buffer.write('.');
              }
              buffer.write(newText[i]);
            }

            final formatted = buffer.toString();
            return TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }),
        ],
        decoration: InputDecoration(
          labelText: 'Jumlah Pengeluaran',
          labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
          hintText: 'Masukkan jumlah pengeluaran',
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.money_off, color: Colors.red.shade600, size: 20),
          ),
          prefixText: 'Rp ',
          prefixStyle: GoogleFonts.poppins(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: GoogleFonts.poppins(fontSize: 14),
        validator: (val) {
          if (val == null || val.isEmpty) return 'Jumlah wajib diisi';

          final cleanValue = val.replaceAll('.', '');
          final number = int.tryParse(cleanValue);
          if (number == null || number <= 0) return 'Jumlah harus berupa angka positif';
          return null;
        },
      ),
    );
  }


  Widget _buildCatatanField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _catatanController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Catatan Pengeluaran',
          labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
          hintText: 'Masukkan detail pengeluaran (misal: beli makanan, bayar laundry)',
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.note_alt, color: Colors.red.shade600, size: 20),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          alignLabelWithHint: true,
        ),
        style: GoogleFonts.poppins(fontSize: 14),
        validator: (val) => val == null || val.isEmpty ? 'Catatan wajib diisi' : null,
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calendar_today, color: Colors.red.shade600, size: 20),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Pengeluaran',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedDate == null
                          ? 'Pilih tanggal pengeluaran'
                          : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _selectedDate == null ? Colors.grey.shade400 : Colors.grey.shade800,
                        fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade300,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Menyimpan...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Simpan Data',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoadingSantri
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade600),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat data santri...',
                          style: GoogleFonts.poppins(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informasi Pengeluaran',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 13),
                              _buildAllKamarSwitch(),
                              const SizedBox(height: 16),
                              _buildSantriDropdown(),
                              const SizedBox(height: 16),
                              _buildJumlahField(),
                              const SizedBox(height: 16),
                              _buildCatatanField(),
                              const SizedBox(height: 16),
                              _buildDatePicker(),
                              const SizedBox(height: 25),
                              _buildSubmitButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}