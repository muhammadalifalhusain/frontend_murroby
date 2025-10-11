import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';
import '../../services/detailSaku_service.dart';

class TambahUangMasukScreen extends StatefulWidget {
  const TambahUangMasukScreen({Key? key}) : super(key: key);

  @override
  State<TambahUangMasukScreen> createState() => _TambahUangMasukScreenState();
}

class _TambahUangMasukScreenState extends State<TambahUangMasukScreen>
    with TickerProviderStateMixin {
  List<Santri> _santriList = [];
  Santri? _selectedSantri;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _jumlahController = TextEditingController();
  DateTime? _selectedDate;
  int? _selectedDari;

  bool _isLoading = false;
  bool _isLoadingSantri = true;

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
    super.dispose();
  }

  Future<void> _loadSantriList() async {
    try {
      final userData = await ApiService.fetchUserData();
      setState(() {
        _santriList = userData.data.listSantri;
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
    if (_formKey.currentState!.validate() &&
        _selectedSantri != null &&
        _selectedDate != null &&
        _selectedDari != null) {
      
      // Show confirmation dialog
      final confirmed = await _showConfirmationDialog();
      if (!confirmed) return;

      setState(() => _isLoading = true);

      try {
        final raw = _jumlahController.text;
        final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
        final jumlah = int.tryParse(cleaned);

        // Debug print untuk melihat nilai rawText, cleanedText, dan jumlah
        print("Raw Text: $raw");
        print("Cleaned Text: $cleaned");
        print("Jumlah: $jumlah");

        final result = await DetailSakuService.postUangMasuk(
          noInduk: _selectedSantri!.noIndukSantri,
          dari: _selectedDari.toString(),
          jumlah: jumlah!,
          tanggal: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        );

        if (mounted) {
          _showSuccessSnackBar(result);
          Navigator.pop(context, true);
        }
      } catch (e) {
        _showErrorSnackBar(e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
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
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.help_outline, color: Colors.green.shade600),
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
              'Pastikan data detail dibawah sudah benar ya',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            _buildConfirmationItem('Nama', _selectedSantri?.namaSantri ?? ''),
            _buildConfirmationItem(
                'Jumlah',
                'Rp ${NumberFormat('#,##0', 'id').format(
                  int.parse(_jumlahController.text.replaceAll(RegExp(r'[^0-9]'), '')),
                )}',
              ),
            _buildConfirmationItem('Sumber', _getDariText(_selectedDari)),
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
              backgroundColor: Colors.green.shade600,
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

  String _getDariText(int? dari) {
    switch (dari) {
      case 1: return 'Uang Saku';
      case 2: return 'Kunjungan Walsan';
      case 3: return 'Sisa Bulan Kemarin';
      default: return '';
    }
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
              primary: Colors.green.shade600,
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
            Colors.green.shade400,
            Colors.green.shade600,
            Colors.green.shade800,
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
            const SizedBox(height: 14),
            Text(
              'Tambah Uang Masuk',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Catat pemasukan uang santri dengan mudah',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSantriDropdown() {
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
      child: DropdownButtonFormField<Santri>(
        value: _selectedSantri,
        decoration: InputDecoration(
          labelText: 'Pilih Santri',
          labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
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
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person, color: Colors.green.shade600, size: 20),
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
        onChanged: (val) => setState(() => _selectedSantri = val),
        validator: (val) => val == null ? 'Santri harus dipilih' : null,
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade800),
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
          labelText: 'Tambahkan Jumlah',
          labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
          hintText: 'Masukkan Jumlah Saku Masuk',
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

  Widget _buildDariDropdown() {
    final sources = [
      {'value': 1, 'text': 'Uang Saku', 'icon': Icons.account_balance_wallet},
      {'value': 2, 'text': 'Kunjungan Walsan', 'icon': Icons.family_restroom},
      {'value': 3, 'text': 'Sisa Bulan Kemarin', 'icon': Icons.savings},
    ];

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
      child: DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: 'Sumber Uang',
          labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
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
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _selectedDari != null 
                ? sources.firstWhere((s) => s['value'] == _selectedDari)['icon'] as IconData
                : Icons.source,
              color: Colors.green.shade600, 
              size: 20,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        value: _selectedDari,
        items: sources.map((source) {
          return DropdownMenuItem<int>(
            value: source['value'] as int,
            child: Row(
              children: [
                Icon(
                  source['icon'] as IconData,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  source['text'] as String,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedDari = value),
        validator: (value) => value == null ? 'Pilih sumber uang' : null,
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade800),
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
                      'Tanggal',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedDate == null
                          ? 'Pilih tanggal'
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
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade300,
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
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
                                'Informasi Transaksi',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 13),
                              _buildSantriDropdown(),
                              const SizedBox(height: 16),
                              _buildJumlahField(),
                              const SizedBox(height: 16),
                              _buildDariDropdown(),
                              const SizedBox(height: 16),
                              _buildDatePicker(),
                              const SizedBox(height: 20),
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