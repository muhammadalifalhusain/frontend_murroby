
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/kelengkapan_model.dart';
import '../../services/kelengkapan_service.dart';

class FormKelengkapanScreen extends StatefulWidget {
  final int noInduk;
  final String? namaSantri;

  const FormKelengkapanScreen({
    Key? key,
    required this.noInduk,
    this.namaSantri,
  }) : super(key: key);

  @override
  State<FormKelengkapanScreen> createState() => _FormKelengkapanScreenState();
}

class _FormKelengkapanScreenState extends State<FormKelengkapanScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  DateTime _selectedDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();

  int _perlengkapanMandi = 0;
  int _peralatanSekolah = 0;
  int _perlengkapanDiri = 0;

  final TextEditingController _catatanMandiController =
      TextEditingController();
  final TextEditingController _catatanSekolahController =
      TextEditingController();
  final TextEditingController _catatanDiriController =
      TextEditingController();

  final Map<int, String> _scoreMap = {
    0: 'Kurang Baik',
    1: 'Cukup',
    2: 'Baik',
  };

  final Map<int, Color> _scoreColorMap = {
    0: const Color(0xFFD9534F),
    1: const Color(0xFFE0A458),
    2: const Color(0xFF4CAF50),
  };

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _catatanMandiController.dispose();
    _catatanSekolahController.dispose();
    _catatanDiriController.dispose();
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
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2D3748),
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = PostKelengkapanRequest(
        noInduk: widget.noInduk,
        tanggal: DateFormat('yyyy-MM-dd').format(_selectedDate),
        perlengkapanMandi: _perlengkapanMandi,
        catatanMandi: _catatanMandiController.text,
        peralatanSekolah: _peralatanSekolah,
        catatanSekolah: _catatanSekolahController.text,
        perlengkapanDiri: _perlengkapanDiri,
        catatanDiri: _catatanDiriController.text,
      );

      final success = await KelengkapanService.postKelengkapan(request);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Data kelengkapan berhasil disimpan',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.of(context).pop(true);
      } else {
        _showErrorMessage('Gagal menyimpan data kelengkapan');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Terjadi kesalahan saat menyimpan data');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFD9534F),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF2D3748),
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
              padding: const EdgeInsets.only(left: 8, right: 4),
              constraints: const BoxConstraints(),
            ),
            Text(
              'Tambah Kelengkapan',
              style: GoogleFonts.poppins(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStudentInfo(),
              const SizedBox(height: 16),
              _buildDateSection(),
              const SizedBox(height: 16),
              _buildAssessmentSection(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF4CAF50),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Santri',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.namaSantri ?? 'No. Induk: ${widget.noInduk}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF2D3748),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return _buildSectionContainer(
      title: 'Tanggal Penilaian',
      child: TextFormField(
        controller: _dateController,
        readOnly: true,
        onTap: _selectDate,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: const Color(0xFF2D3748),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Pilih tanggal',
          hintStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            size: 19,
            color: Color(0xFF4CAF50),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: Color(0xFF4CAF50),
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
    );
  }

  Widget _buildAssessmentSection() {
    return _buildSectionContainer(
      title: 'Penilaian Kelengkapan',
      child: Column(
        children: [
          _buildAssessmentItem(
            title: 'Perlengkapan Mandi',
            icon: Icons.shower_outlined,
            value: _perlengkapanMandi,
            controller: _catatanMandiController,
            onChanged: (value) {
              setState(() {
                _perlengkapanMandi = value;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildAssessmentItem(
            title: 'Alat Sekolah',
            icon: Icons.school_outlined,
            value: _peralatanSekolah,
            controller: _catatanSekolahController,
            onChanged: (value) {
              setState(() {
                _peralatanSekolah = value;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildAssessmentItem(
            title: 'Perlengkapan Diri',
            icon: Icons.checkroom_outlined,
            value: _perlengkapanDiri,
            controller: _catatanDiriController,
            onChanged: (value) {
              setState(() {
                _perlengkapanDiri = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentItem({
    required String title,
    required IconData icon,
    required int value,
    required TextEditingController controller,
    required Function(int) onChanged,
  }) {
    final activeColor = _scoreColorMap[value]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: activeColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                size: 18,
                color: activeColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildScoreButton(
              score: 0,
              currentValue: value,
              onChanged: onChanged,
            ),
            const SizedBox(width: 8),
            _buildScoreButton(
              score: 1,
              currentValue: value,
              onChanged: onChanged,
            ),
            const SizedBox(width: 8),
            _buildScoreButton(
              score: 2,
              currentValue: value,
              onChanged: onChanged,
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: 2,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF374151),
          ),
          decoration: InputDecoration(
            hintText: 'Tambahkan catatan...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(9)),
              borderSide: BorderSide(
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Catatan harus diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildScoreButton({
    required int score,
    required int currentValue,
    required Function(int) onChanged,
  }) {
    final isSelected = currentValue == score;
    final color = _scoreColorMap[score]!;

    return Expanded(
      child: InkWell(
        onTap: () => onChanged(score),
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.10)
                : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isSelected
                  ? color
                  : Colors.grey.shade200,
              width: isSelected ? 1.2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Icon(
                    Icons.check_circle,
                    size: 14,
                    color: color,
                  ),
                ),
              Flexible(
                child: Text(
                  _scoreMap[score]!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? color
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 14),
          child,
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
          backgroundColor: const Color(0xFF4CAF50),
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          elevation: 0,
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
                'Simpan Data',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}