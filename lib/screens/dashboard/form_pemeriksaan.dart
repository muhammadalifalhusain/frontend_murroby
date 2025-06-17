import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../models/pemeriksaan_model.dart';
import '../../services/pemeriksaan_service.dart';

class PemeriksaanFormScreen extends StatefulWidget {
  final String noInduk;
  final String namaSantri;

  const PemeriksaanFormScreen({
    Key? key,
    required this.noInduk,
    required this.namaSantri,
  }) : super(key: key);

  @override
  _PemeriksaanFormScreenState createState() => _PemeriksaanFormScreenState();
}

class _PemeriksaanFormScreenState extends State<PemeriksaanFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _service = PemeriksaanService();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Data form
  DateTime? _tanggalPemeriksaan;
  final _tinggiBadanController = TextEditingController();
  final _beratBadanController = TextEditingController();
  final _lingkarPinggulController = TextEditingController();
  final _lingkarDadaController = TextEditingController();
  final _kondisiGigiController = TextEditingController();

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tinggiBadanController.dispose();
    _beratBadanController.dispose();
    _lingkarPinggulController.dispose();
    _lingkarDadaController.dispose();
    _kondisiGigiController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalPemeriksaan == null) {
      _showCustomSnackBar('Tanggal pemeriksaan harus diisi', isError: true);
      return;
    }

    if (widget.noInduk == null) {
      _showCustomSnackBar('Nomor Induk tidak tersedia', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = PemeriksaanPostRequest(
        noInduk: widget.noInduk,
        tanggalPemeriksaan: DateFormat('yyyy-MM-dd').format(_tanggalPemeriksaan!),
        tinggiBadan: int.parse(_tinggiBadanController.text),
        beratBadan: int.parse(_beratBadanController.text),
        lingkarPinggul: int.parse(_lingkarPinggulController.text),
        lingkarDada: int.parse(_lingkarDadaController.text),
        kondisiGigi: _kondisiGigiController.text,
      );

      final response = await _service.createPemeriksaan(request);

      if (mounted) {
        _showCustomSnackBar(response.message, isError: false);
        await Future.delayed(const Duration(milliseconds: 1500));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showCustomSnackBar('Error: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCustomSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.teal.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _tanggalPemeriksaan) {
      setState(() => _tanggalPemeriksaan = picked);
    }
  }

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 2,
        toolbarHeight: 56,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'Tambah Data',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildPatientInfoCard(),
                const SizedBox(height: 24),
                _buildDateSelectionCard(),
                const SizedBox(height: 24),
                _buildMeasurementCard(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.teal.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Informasi Santri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoItem('Nomor Induk', widget.noInduk, Icons.badge),
            const SizedBox(height: 12),
            _buildInfoItem('Nama Santri', widget.namaSantri, Icons.account_circle),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.teal.shade600),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelectionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.teal.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tanggal Periksa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 4,
                          child: Text(
                            _tanggalPemeriksaan == null
                                ? 'Pilih tanggal'
                                : DateFormat('dd MMMM yyyy').format(_tanggalPemeriksaan!),
                            style: TextStyle(
                              fontSize: 16,
                              color: _tanggalPemeriksaan == null
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                              fontWeight: _tanggalPemeriksaan == null
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.date_range,
                          color: Colors.teal.shade600,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.monitor_weight,
                  color: Colors.teal.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Data Pengukuran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ..._buildMeasurementFields(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMeasurementFields() {
    return [
      _buildCustomTextField(
        controller: _tinggiBadanController,
        label: 'Tinggi Badan',
        suffix: 'cm',
        icon: Icons.height,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Tinggi badan harus diisi';
          if (int.tryParse(value) == null) return 'Masukkan angka yang valid';
          return null;
        },
      ),
      const SizedBox(height: 16),
      _buildCustomTextField(
        controller: _beratBadanController,
        label: 'Berat Badan',
        suffix: 'kg',
        icon: Icons.monitor_weight,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Berat badan harus diisi';
          if (int.tryParse(value) == null) return 'Masukkan angka yang valid';
          return null;
        },
      ),
      const SizedBox(height: 16),
      _buildCustomTextField(
        controller: _lingkarPinggulController,
        label: 'Lingkar Pinggul',
        suffix: 'cm',
        icon: Icons.straighten,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Lingkar pinggul harus diisi';
          if (int.tryParse(value) == null) return 'Masukkan angka yang valid';
          return null;
        },
      ),
      const SizedBox(height: 16),
      _buildCustomTextField(
        controller: _lingkarDadaController,
        label: 'Lingkar Dada',
        suffix: 'cm',
        icon: Icons.straighten,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Lingkar dada harus diisi';
          if (int.tryParse(value) == null) return 'Masukkan angka yang valid';
          return null;
        },
      ),
      const SizedBox(height: 16),
      _buildCustomTextField(
        controller: _kondisiGigiController,
        label: 'Kondisi Gigi',
        icon: Icons.sentiment_satisfied,
        maxLines: 3,
        keyboardType: TextInputType.multiline,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Kondisi gigi harus diisi';
          return null;
        },
      ),
    ];
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? suffix,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.number,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon, color: Colors.teal.shade600),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade700),
        suffixStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade600, Colors.teal.shade700],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade200,
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'SIMPAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}