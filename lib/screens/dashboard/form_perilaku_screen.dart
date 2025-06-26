import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/perilaku_model.dart';
import '../../services/perilaku_service.dart';

class FormPerilakuScreen extends StatefulWidget {
  final int noInduk;
  final String? namaSantri; 

  const FormPerilakuScreen({
    Key? key, 
    required this.noInduk,
    this.namaSantri,
  }) : super(key: key);

  @override
  State<FormPerilakuScreen> createState() => _FormPerilakuScreenState();
}

class _FormPerilakuScreenState extends State<FormPerilakuScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  DateTime _selectedDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();

  int _ketertiban = 2;
  int _kebersihan = 2;
  int _kedisiplinan = 2;
  int _kerapian = 2;
  int _kesopanan = 2;
  int _kepekaanLingkungan = 2;
  int _ketaatanPeraturan = 2;

  // Mapping nilai ke text
  final Map<int, String> _scoreMap = {
    0: 'Kurang Baik',
    1: 'Cukup',
    2: 'Baik',
  };

  // Mapping nilai ke warna
  final Map<int, Color> _colorMap = {
    0: const Color(0xFFEF4444), 
    1: const Color(0xFFF59E0B), 
    2: const Color(0xFF10B981), 
  };

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = PerilakuPostRequest(
        noInduk: widget.noInduk,
        tanggal: DateFormat('yyyy-MM-dd').format(_selectedDate),
        ketertiban: _ketertiban,
        kebersihan: _kebersihan,
        kedisiplinan: _kedisiplinan,
        kerapian: _kerapian,
        kesopanan: _kesopanan,
        kepekaanLingkungan: _kepekaanLingkungan,
        ketaatanPeraturan: _ketaatanPeraturan,
      );

      // Kirim ke backend
      final success = await PerilakuService.postPerilaku(request);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Data berhasil ditambahkan',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        Navigator.of(context).pop(true); 
      } else {
        // Gagal response 400+
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Gagal menambahkan data perilaku'),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Terjadi kesalahan: $e',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
              onPressed: () => Navigator.of(context).pop(),
              padding: const EdgeInsets.only(left: 8, right: 4),
              constraints: const BoxConstraints(),
            ),
            Text(
              'Tambah Perilaku',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.assignment_add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tambah Catatan Perilaku',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.namaSantri ?? 'No. Induk: ${widget.noInduk}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Form Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tanggal Section
                    _buildSectionCard(
                      title: 'Tanggal Penilaian',
                      icon: Icons.calendar_today,
                      child: TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: _selectDate,
                        decoration: InputDecoration(
                          hintText: 'Pilih tanggal',
                          suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF6366F1)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF6366F1)),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tanggal harus dipilih';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                    _buildSectionCard(
                      title: 'Penilaian Perilaku',
                      icon: Icons.assessment,
                      child: Column(
                        children: [
                          _buildScoreSelector('Ketertiban', Icons.rule_rounded, _ketertiban, (value) {
                            setState(() => _ketertiban = value);
                          }),
                          _buildScoreSelector('Kebersihan', Icons.cleaning_services_rounded, _kebersihan, (value) {
                            setState(() => _kebersihan = value);
                          }),
                          _buildScoreSelector('Kedisiplinan', Icons.timer_rounded, _kedisiplinan, (value) {
                            setState(() => _kedisiplinan = value);
                          }),
                          _buildScoreSelector('Kerapian', Icons.checkroom_rounded, _kerapian, (value) {
                            setState(() => _kerapian = value);
                          }),
                          _buildScoreSelector('Kesopanan', Icons.waving_hand_rounded, _kesopanan, (value) {
                            setState(() => _kesopanan = value);
                          }),
                          _buildScoreSelector('Kepekaan Lingkungan', Icons.nature_people_rounded, _kepekaanLingkungan, (value) {
                            setState(() => _kepekaanLingkungan = value);
                          }),
                          _buildScoreSelector('Ketaatan Peraturan', Icons.gavel_rounded, _ketaatanPeraturan, (value) {
                            setState(() => _ketaatanPeraturan = value);
                          }, isLast: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
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
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Simpan Data Perilaku',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: const Color(0xFF6366F1)),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSelector(
    String label,
    IconData icon,
    int currentValue,
    Function(int) onChanged, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _colorMap[currentValue]!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: _colorMap[currentValue]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [0, 1, 2].map((score) {
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(score),
                child: Container(
                  margin: EdgeInsets.only(
                    right: score < 2 ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: currentValue == score
                        ? _colorMap[score]
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: currentValue == score
                          ? _colorMap[score]!
                          : Colors.grey.shade300,
                      width: currentValue == score ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _scoreMap[score]!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: currentValue == score
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (!isLast) const SizedBox(height: 20),
      ],
    );
  }
}