
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/santri_model.dart';
import '../../models/izin_model.dart';
import '../../services/izin_service.dart';
import '../../services/santri_service.dart';
import 'package:google_fonts/google_fonts.dart';

class TambahIzinScreen extends StatefulWidget {
  final Izin? izin;

  const TambahIzinScreen({super.key, this.izin});

  @override
  State<TambahIzinScreen> createState() => _TambahIzinScreenState();
}

class _TambahIzinScreenState extends State<TambahIzinScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController searchController = TextEditingController();
  final TextEditingController kategoriPelanggaranController =
      TextEditingController();

  List<Santri> santriList = [];
  Santri? selectedSantri;

  DateTime? selectedTanggal;
  TimeOfDay? keluarTime;
  TimeOfDay? kembaliTime;

  int? selectedKategori;
  int? selectedStatus;

  bool get isEdit => widget.izin != null;
  bool isLoading = false;

  static const Color primaryColor = Color(0xFF43A047);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textColor = Color(0xFF1F2937);
  static const Color secondaryTextColor = Color(0xFF6B7280);

  final List<Map<String, Object>> kategoriList = [
    {'label': 'Izin Keluar', 'value': 1},
    {'label': 'Izin Pulang', 'value': 2},
  ];

  final List<Map<String, Object>> statusList = [
    {'label': 'Diberikan', 'value': 1},
    {'label': 'Dicabut', 'value': 0},
  ];

  @override
  void initState() {
    super.initState();
    _fetchSantri();
  }

  int? _getDropdownValue(
    List<Map<String, Object>> list,
    String label,
  ) {
    final match = list.firstWhere(
      (item) =>
          (item['label'] as String).toLowerCase().trim() ==
          label.toLowerCase().trim(),
      orElse: () => {},
    );

    return match['value'] as int?;
  }

  Future<void> _fetchSantri() async {
    try {
      final response = await SantriService.fetchAllSantri();

      if (!mounted) return;

      setState(() {
        santriList = response.data;

        if (isEdit) {
          final izin = widget.izin!;

          selectedSantri = santriList.firstWhere(
            (santri) => santri.nama == izin.nama,
            orElse: () => Santri(
              id: '',
              nama: izin.nama,
              noInduk: '-',
              kelas: null,
            ),
          );

          searchController.text =
              '${selectedSantri?.nama ?? ''} (${selectedSantri?.noInduk ?? ''})';

          try {
            selectedTanggal =
                DateFormat('dd MMMM yyyy', 'id_ID').parse(izin.tanggal);
          } catch (_) {
            selectedTanggal = DateTime.tryParse(izin.tanggal);
          }

          keluarTime = _parseTimeOfDay(izin.keluar);
          kembaliTime = _parseTimeOfDay(izin.kembali);

          selectedKategori = _getDropdownValue(
            kategoriList,
            izin.kategori,
          );

          selectedStatus = _getDropdownValue(
            statusList,
            izin.status,
          );

          kategoriPelanggaranController.text =
              izin.kategoriPelanggaran;
        }
      });
    } catch (_) {}
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedSantri == null ||
        selectedTanggal == null ||
        keluarTime == null ||
        kembaliTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lengkapi semua data terlebih dahulu',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: const Color(0xFF374151),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final request = IzinRequest(
      noInduk: selectedSantri!.noInduk,
      tanggal: DateFormat('yyyy-MM-dd').format(selectedTanggal!),
      keluar: keluarTime!.format(context),
      kembali: kembaliTime!.format(context),
      kategori: selectedKategori!,
      status: selectedStatus!,
    );

    setState(() {
      isLoading = true;
    });

    bool success = false;

    try {
      success = isEdit
          ? await IzinService.updateIzin(widget.izin!.id, request)
          : await IzinService.postIzin(request);
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                isEdit
                    ? 'Data izin berhasil diperbarui'
                    : 'Data izin berhasil disimpan',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isEdit
                      ? 'Gagal memperbarui data izin'
                      : 'Gagal menyimpan data izin',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedTanggal ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedTanggal = picked;
      });
    }
  }

  Future<void> _pickTime(bool isKeluar) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isKeluar
          ? keluarTime ?? TimeOfDay.now()
          : kembaliTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isKeluar) {
          keluarTime = picked;
        } else {
          kembaliTime = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    kategoriPelanggaranController.dispose();
    super.dispose();
  }

  Widget _buildTimeField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final hasValue = value.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hasValue ? value : 'Pilih jam',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: hasValue
                    ? textColor
                    : secondaryTextColor,
                fontWeight:
                    hasValue ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSantriSearch() {
    return Autocomplete<Santri>(
      optionsBuilder: (TextEditingValue val) {
        if (val.text.isEmpty) {
          return const Iterable<Santri>.empty();
        }

        return santriList.where(
          (s) =>
              s.nama.toLowerCase().contains(val.text.toLowerCase()) ||
              s.noInduk.toLowerCase().contains(val.text.toLowerCase()),
        );
      },
      displayStringForOption: (s) => '${s.nama} (${s.noInduk})',
      onSelected: (s) {
        setState(() {
          selectedSantri = s;
          searchController.text = '${s.nama} (${s.noInduk})';
        });
      },
      fieldViewBuilder: (
        context,
        controller,
        focusNode,
        onEditingComplete,
      ) {
        if (controller.text != searchController.text) {
          controller.text = searchController.text;
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        }

        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: _inputDecoration(
            label: 'Cari Santri',
            icon: Icons.person_outline_rounded,
          ),
          validator: (_) {
            if (selectedSantri == null) {
              return 'Pilih santri terlebih dahulu';
            }
            return null;
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: secondaryTextColor,
      ),
      floatingLabelStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: primaryColor,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(
        icon,
        size: 20,
        color: secondaryTextColor,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.3,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFDC2626),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFDC2626),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final hasValue = value.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasValue ? value : 'Belum dipilih',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: hasValue
                          ? textColor
                          : secondaryTextColor,
                      fontWeight:
                          hasValue ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required int? value,
    required List<Map<String, Object>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: _inputDecoration(
        label: label,
        icon: icon,
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.grey.shade500,
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<int>(
              value: item['value'] as int,
              child: Text(
                item['label'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: textColor,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (val) {
        if (val == null) {
          return 'Pilih $label';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        surfaceTintColor: Colors.white,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black87,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
              padding: const EdgeInsets.only(
                left: 8,
                right: 4,
              ),
              constraints: const BoxConstraints(),
            ),
            Text(
              isEdit ? 'Edit Izin' : 'Tambah Izin',
              style: GoogleFonts.poppins(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              24,
            ),
            child: Column(
              children: [
                _buildSection(
                  title: 'Data Santri',
                  icon: Icons.person_outline_rounded,
                  child: _buildSantriSearch(),
                ),
                const SizedBox(height: 12),
                _buildSection(
                  title: 'Waktu Izin',
                  icon: Icons.schedule_rounded,
                  child: Column(
                    children: [
                      _buildDateTimeField(
                        label: 'Tanggal Izin',
                        value: selectedTanggal == null
                            ? ''
                            : DateFormat(
                                'dd MMMM yyyy',
                                'id_ID',
                              ).format(selectedTanggal!),
                        icon: Icons.calendar_today_outlined,
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTimeField(
                              label: 'Jam Keluar',
                              value: keluarTime?.format(context) ?? '',
                              onTap: () => _pickTime(true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTimeField(
                              label: 'Jam Kembali',
                              value: kembaliTime?.format(context) ?? '',
                              onTap: () => _pickTime(false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildSection(
                  title: 'Detail Izin',
                  icon: Icons.assignment_outlined,
                  child: Column(
                    children: [
                      _buildDropdown(
                        label: 'Kategori',
                        icon: Icons.category_outlined,
                        value: selectedKategori,
                        items: kategoriList,
                        onChanged: (val) {
                          setState(() {
                            selectedKategori = val;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildDropdown(
                        label: 'Status',
                        icon: Icons.check_circle_outline_rounded,
                        value: selectedStatus,
                        items: statusList,
                        onChanged: (val) {
                          setState(() {
                            selectedStatus = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: primaryColor.withOpacity(0.5),
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isEdit
                              ? Icons.save_outlined
                              : Icons.add_circle_outline_rounded,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isEdit ? 'Perbarui Izin' : 'Simpan Izin',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

TimeOfDay _parseTimeOfDay(String time) {
  final parts = time.split(':');

  return TimeOfDay(
    hour: int.parse(parts[0]),
    minute: int.parse(parts[1]),
  );
}