
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
  late TextEditingController _dateController;

  int _ketertiban = 2;
  int _kebersihan = 2;
  int _kedisiplinan = 2;
  int _kerapian = 2;
  int _kesopanan = 2;
  int _kepekaanLingkungan = 2;
  int _ketaatanPeraturan = 2;

  final Map<int, String> _scoreMap = {
    0: 'Kurang Baik',
    1: 'Cukup',
    2: 'Baik',
  };

  final Map<int, Color> _colorMap = {
    0: const Color(0xFFE53935),
    1: const Color(0xFFFB8C00),
    2: const Color(0xFF43A047),
  };

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF43A047),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _dateController.text =
          DateFormat('dd MMMM yyyy', 'id_ID').format(picked);
    });
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

      final success = await PerilakuService.postPerilaku(request);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data perilaku berhasil ditambahkan',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.of(context).pop(true);
      } else {
        _showMessage('Gagal menambahkan data perilaku');
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tambah Perilaku',
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSantriInfo(),
              const SizedBox(height: 24),
              _buildDateSection(),
              const SizedBox(height: 24),
              _buildAssessmentSection(),
              const SizedBox(height: 28),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSantriInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE7E7E7),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF43A047).withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 22,
              color: Color(0xFF43A047),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.namaSantri ?? 'Santri',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'No. Induk: ${widget.noInduk}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Penilaian',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: _selectDate,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.calendar_today_outlined,
              size: 19,
              color: Color(0xFF43A047),
            ),
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE1E1E1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE1E1E1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF43A047),
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Tanggal harus dipilih';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAssessmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Penilaian Perilaku',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pilih kondisi yang sesuai untuk setiap aspek.',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE7E7E7),
            ),
          ),
          child: Column(
            children: [
              _buildScoreSelector(
                'Ketertiban',
                Icons.rule_rounded,
                _ketertiban,
                (value) => setState(() => _ketertiban = value),
              ),
              _buildScoreSelector(
                'Kebersihan',
                Icons.cleaning_services_outlined,
                _kebersihan,
                (value) => setState(() => _kebersihan = value),
              ),
              _buildScoreSelector(
                'Kedisiplinan',
                Icons.schedule_rounded,
                _kedisiplinan,
                (value) => setState(() => _kedisiplinan = value),
              ),
              _buildScoreSelector(
                'Kerapian',
                Icons.checkroom_outlined,
                _kerapian,
                (value) => setState(() => _kerapian = value),
              ),
              _buildScoreSelector(
                'Kesopanan',
                Icons.waving_hand_outlined,
                _kesopanan,
                (value) => setState(() => _kesopanan = value),
              ),
              _buildScoreSelector(
                'Kepekaan Lingkungan',
                Icons.nature_people_outlined,
                _kepekaanLingkungan,
                (value) => setState(
                  () => _kepekaanLingkungan = value,
                ),
              ),
              _buildScoreSelector(
                'Ketaatan Peraturan',
                Icons.gavel_outlined,
                _ketaatanPeraturan,
                (value) => setState(
                  () => _ketaatanPeraturan = value,
                ),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreSelector(
    String label,
    IconData icon,
    int currentValue,
    ValueChanged<int> onChanged, {
    bool isLast = false,
  }) {
    final activeColor = _colorMap[currentValue]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: activeColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                _scoreMap[currentValue]!,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: activeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [0, 1, 2].map((score) {
              final isSelected = currentValue == score;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: score == 0 || score == 1 ? 6 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => onChanged(score),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _colorMap[score]!.withOpacity(.10)
                            : const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? _colorMap[score]!
                              : const Color(0xFFE2E2E2),
                          width: isSelected ? 1.2 : 1,
                        ),
                      ),
                      child: Text(
                        _scoreMap[score]!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? _colorMap[score]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (!isLast)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Divider(
                height: 1,
                color: Color(0xFFEDEDED),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF43A047),
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Menyimpan...',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                'Simpan Penilaian',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}