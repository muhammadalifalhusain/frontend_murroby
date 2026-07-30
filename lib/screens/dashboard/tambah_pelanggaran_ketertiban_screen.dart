
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pelanggaran_ketertiban_model.dart';
import '../../services/pelanggaran_ketertiban_service.dart';
import '../../services/santri_service.dart';
import '../../models/santri_model.dart';

class FormPelanggaranKetertibanScreen extends StatefulWidget {
  final int? idEdit;

  const FormPelanggaranKetertibanScreen({
    super.key,
    this.idEdit,
  });

  @override
  State<FormPelanggaranKetertibanScreen> createState() =>
      _FormPelanggaranKetertibanScreenState();
}

class _FormPelanggaranKetertibanScreenState
    extends State<FormPelanggaranKetertibanScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController searchController = TextEditingController();
  final TextEditingController noIndukController = TextEditingController();

  List<Santri> santriList = [];
  Santri? selectedSantri;

  DateTime? _tanggal;

  // 0 = Bagus
  // 1 = Tidak
  int _buangSampah = 0;
  int _menata = 0;
  int _tidakBerseragam = 0;

  bool _loading = false;
  bool _isLoading = true;

  // Warna utama halaman
  final Color primaryColor = const Color(0xFF004E92);
  final Color backgroundColor = const Color(0xFFF7F8FA);
  final Color textColor = const Color(0xFF202124);

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    searchController.dispose();
    noIndukController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _fetchSantri();

    if (widget.idEdit != null) {
      await _loadEditData(widget.idEdit!);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSantri() async {
    try {
      final response = await SantriService.fetchAllSantri();

      if (mounted) {
        setState(() {
          santriList = response.data;
        });
      }
    } catch (e) {
      debugPrint('Gagal mengambil data santri: $e');
    }
  }

  Future<void> _loadEditData(int id) async {
    try {
      final data =
          await PelanggaranKetertibanService.fetchById(id);

      if (data != null && mounted) {
        setState(() {
          noIndukController.text = data.noInduk.toString();

          _tanggal = DateTime.tryParse(data.tanggal);

          // API -> String "Ya"/"Tidak"
          // UI -> int 1/0
          _buangSampah =
              data.buangSampah.toLowerCase() == 'ya' ? 1 : 0;

          _menata =
              data.menataPeralatan.toLowerCase() == 'ya' ? 1 : 0;

          _tidakBerseragam =
              data.tidakBerseragam.toLowerCase() == 'ya' ? 1 : 0;

          selectedSantri = santriList.firstWhere(
            (s) => s.noInduk == data.noInduk.toString(),
            orElse: () => Santri(
              id: '-1',
              nama: 'Tidak ditemukan',
              noInduk: data.noInduk.toString(),
            ),
          );

          searchController.text =
              selectedSantri?.nama ?? 'Tidak ditemukan';
        });
      }
    } catch (e) {
      debugPrint(
        'Gagal mengambil detail pelanggaran: $e',
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _tanggal == null ||
        selectedSantri == null) {
      _showError(
        'Mohon lengkapi semua data yang diperlukan',
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    final request = PelanggaranKetertibanRequest(
      noInduk: int.tryParse(selectedSantri!.noInduk) ?? -1,
      tanggal: _tanggal!.toIso8601String(),
      buangSampah: _buangSampah,
      menataPeralatan: _menata,
      tidakBerseragam: _tidakBerseragam,
    );

    try {
      bool success;

      if (widget.idEdit != null) {
        success =
            await PelanggaranKetertibanService.update(
          widget.idEdit!,
          request,
        );
      } else {
        success =
            await PelanggaranKetertibanService.create(
          request,
        );
      }

      if (success && mounted) {
        Navigator.pop(context, true);
      } else {
        _showError('Gagal menyimpan data.');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _tanggal = picked;
      });
    }
  }

  // ============================================================
  // SANTRI SEARCH
  // ============================================================

  Widget _buildSantriSearch() {
    return Autocomplete<Santri>(
      optionsBuilder: (
        TextEditingValue value,
      ) {
        if (value.text.trim().isEmpty) {
          return const Iterable<Santri>.empty();
        }

        final keyword = value.text.toLowerCase();

        return santriList.where(
          (santri) =>
              santri.nama.toLowerCase().contains(keyword) ||
              santri.noInduk.toLowerCase().contains(keyword),
        );
      },

      displayStringForOption: (santri) =>
          '${santri.nama} (${santri.noInduk})',

      onSelected: (santri) {
        setState(() {
          selectedSantri = santri;
          searchController.text =
              '${santri.nama} (${santri.noInduk})';
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
            TextPosition(
              offset: controller.text.length,
            ),
          );
        }

        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: textColor,
          ),
          decoration: _inputDecoration(
            label: 'Pilih Santri',
            hint: 'Cari nama atau nomor induk',
            icon: Icons.search_rounded,
          ),
          validator: (_) {
            if (selectedSantri == null) {
              return 'Pilih santri terlebih dahulu';
            }

            return null;
          },
        );
      },

      optionsViewBuilder: (
        context,
        onSelected,
        options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              constraints: const BoxConstraints(
                maxHeight: 220,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                ),
                itemCount: options.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1),
                itemBuilder: (context, index) {
                  final santri = options.elementAt(index);

                  return ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 3,
                    ),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          primaryColor.withOpacity(0.08),
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 19,
                        color: primaryColor,
                      ),
                    ),
                    title: Text(
                      santri.nama,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(
                      santri.noInduk,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () => onSelected(santri),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _buildDateField() {
    final hasDate = _tanggal != null;

    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 19,
              color: primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasDate
                        ? _formatDate(_tanggal!)
                        : 'Pilih tanggal',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: hasDate
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: hasDate
                          ? textColor
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ============================================================
  // RADIO / SEGMENTED FIELD
  // ============================================================

  Widget _buildStatusField({
    required String title,
    required int value,
    required ValueChanged<int> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: primaryColor,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              Expanded(
                child: _buildStatusOption(
                  label: 'Bagus',
                  selected: value == 0,
                  color: Colors.green,
                  onTap: () => onChanged(0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusOption(
                  label: 'Tidak',
                  selected: value == 1,
                  color: Colors.red,
                  onTap: () => onChanged(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 40,
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? color
                : Colors.grey.shade300,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 17,
              color: selected
                  ? color
                  : Colors.grey[500],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: selected
                    ? color
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
                  size: 18,
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
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.grey[600],
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.grey[400],
      ),
      prefixIcon: Icon(
        icon,
        size: 19,
        color: primaryColor,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: primaryColor,
          width: 1.3,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.3,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor:
                AlwaysStoppedAnimation<Color>(
              primaryColor,
            ),
          ),
        ),
      );
    }

    final bool isEdit = widget.idEdit != null;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: Colors.black87,
          ),
          onPressed: () =>
              Navigator.of(context).pop(),
        ),

        title: Text(
          isEdit
              ? 'Edit Ketertiban'
              : 'Tambah Ketertiban',
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),

                  padding: const EdgeInsets.fromLTRB(
                    16,
                    14,
                    16,
                    20,
                  ),

                  child: Column(
                    children: [
                      // ==========================
                      // DATA SANTRI
                      // ==========================

                      _buildSection(
                        title: 'Data Santri',
                        icon:
                            Icons.person_outline_rounded,
                        child:
                            _buildSantriSearch(),
                      ),

                      const SizedBox(height: 12),

                      // ==========================
                      // TANGGAL
                      // ==========================

                      _buildSection(
                        title: 'Tanggal Pelanggaran',
                        icon:
                            Icons.calendar_today_outlined,
                        child:
                            _buildDateField(),
                      ),

                      const SizedBox(height: 12),

                      // ==========================
                      // KETERTIBAN
                      // ==========================

                      _buildSection(
                        title: 'Penilaian Ketertiban',
                        icon:
                            Icons.rule_rounded,
                        child: Column(
                          children: [
                            _buildStatusField(
                              title: 'Buang Sampah',
                              value: _buangSampah,
                              icon:
                                  Icons.delete_outline_rounded,
                              onChanged: (value) {
                                setState(() {
                                  _buangSampah = value;
                                });
                              },
                            ),

                            const SizedBox(height: 8),

                            _buildStatusField(
                              title: 'Menata Peralatan',
                              value: _menata,
                              icon:
                                  Icons.inventory_2_outlined,
                              onChanged: (value) {
                                setState(() {
                                  _menata = value;
                                });
                              },
                            ),

                            const SizedBox(height: 8),

                            _buildStatusField(
                              title: 'Tidak Berseragam',
                              value:
                                  _tidakBerseragam,
                              icon:
                                  Icons.checkroom_outlined,
                              onChanged: (value) {
                                setState(() {
                                  _tidakBerseragam =
                                      value;
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

              // ==============================
              // BOTTOM BUTTON
              // ==============================

              Container(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),

                child: SizedBox(
                  width: double.infinity,
                  height: 48,

                  child: ElevatedButton(
                    onPressed:
                        _loading ? null : _submit,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor:
                          Colors.white,
                      disabledBackgroundColor:
                          primaryColor
                              .withOpacity(0.45),
                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),

                    child: _loading
                        ? Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              const SizedBox(
                                width: 17,
                                height: 17,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<
                                          Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 9),
                              Text(
                                'Menyimpan...',
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Text(
                                isEdit
                                    ? 'Perbarui Data'
                                    : 'Simpan Data',
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
