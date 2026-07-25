import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/perlengkapan_model.dart';
import '../../models/santri_model.dart';
import '../../services/perlengkapan_service.dart';
import '../../services/santri_service.dart';
import '../../utils/perlengkapan_items.dart';
import 'package:google_fonts/google_fonts.dart';

class TambahPerlengkapanScreen extends StatefulWidget {
  final int? perlengkapanId;
  const TambahPerlengkapanScreen({super.key, this.perlengkapanId});

  @override
  State<TambahPerlengkapanScreen> createState() => _TambahPerlengkapanScreenState();
}

class _TambahPerlengkapanScreenState extends State<TambahPerlengkapanScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  String _tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<Santri> santriList = [];
  Santri? selectedSantri;
  Map<String, int> _items = Map<String, int>.from(defaultItems);

  bool isLoading = true;
  EditPerlengkapanModel? editData;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _fetchSantri();

    if (widget.perlengkapanId != null) {
      await _fetchEditData(widget.perlengkapanId!);
      _applyEditData();
    }

    setState(() => isLoading = false);
  }

  Future<void> _fetchSantri() async {
    try {
      final response = await SantriService.fetchAllSantri();
      santriList = response.data;
    } catch (e) {
      debugPrint("Gagal mengambil data santri: $e");
    }
  }

  Future<void> _fetchEditData(int id) async {
    try {
      editData = await PerlengkapanService.getPerlengkapanById(id);
    } catch (e) {
      debugPrint("Gagal mengambil detail perlengkapan: $e");
    }
  }

  void _applyEditData() {
    if (editData == null) return;
    final edit = editData!;

    _tanggal = edit.tanggal;
    _keteranganController.text = edit.keterangan;

    selectedSantri = santriList.firstWhere(
      (s) => s.noInduk == edit.noInduk,
      orElse: () => Santri(id: '-1', nama: 'Tidak ditemukan', noInduk: edit.noInduk),
    );

    searchController.text = selectedSantri?.nama ?? 'Tidak ditemukan';

    _items.clear();
    _items.addAll(defaultItems);

    defaultItems.keys.forEach((key) {
      final value = edit.toJson()[key];
      _items[key] = int.tryParse(value?.toString() ?? '0') ?? 0;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = PostPerlengkapanRequest(
      noInduk: selectedSantri!.noInduk,
      tanggal: _tanggal,
      items: _items,
      keterangan: _keteranganController.text,
      namaPengisi: "Admin",
    );

    try {
      bool success;

      if (widget.perlengkapanId != null) {
        success = await PerlengkapanService.updatePerlengkapan(widget.perlengkapanId!, request.toJson());
      } else {
        success = await PerlengkapanService.postPerlengkapan(request.toJson());
      }

      if (success && mounted) {
        Navigator.pop(context, true);
      } else {
        _showError('Gagal menyimpan data.');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_tanggal),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggal = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Widget _buildSantriSearch() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Autocomplete<Santri>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) return const Iterable<Santri>.empty();
          return santriList.where((s) =>
              s.nama.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
              s.noInduk.toLowerCase().contains(textEditingValue.text.toLowerCase()));
        },
        displayStringForOption: (Santri s) => '${s.nama} (${s.noInduk})',
        onSelected: (Santri selection) {
          setState(() {
            selectedSantri = selection;
            searchController.text = '${selection.nama} (${selection.noInduk})';
          });
        },
        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
          controller.text = searchController.text;
          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            onEditingComplete: onEditingComplete,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Pilih Santri',
              labelStyle: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.search,
                  color: Colors.indigo[600],
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.indigo, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (_) => selectedSantri == null ? 'Pilih nama santri' : null,
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: MediaQuery.of(context).size.width - 32,
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: options.map((Santri option) {
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.indigo[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.indigo[600],
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.nama,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    option.noInduk,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKelayakanField(String label) {
    int? value = _items[label] ?? 0;
    bool isKelayakan = label.toLowerCase().contains('layak');
    final optionTexts = isKelayakan ? ['Layak', 'Tidak Layak'] : ['Ada', 'Tidak Ada'];
    final optionIcons = isKelayakan
        ? [Icons.check_circle, Icons.cancel]
        : [Icons.check, Icons.close];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ToggleButtons(
            borderRadius: BorderRadius.circular(10),
            selectedBorderColor: value == 0 ? Colors.green : Colors.red,
            selectedColor: Colors.white,
            fillColor: value == 0 ? Colors.green : Colors.red,
            color: Colors.grey[600],
            constraints: const BoxConstraints(minHeight: 40, minWidth: 80),
            isSelected: [value == 0, value == 1],
            onPressed: (index) {
              setState(() {
                _items[label] = index;
              });
            },
            children: List.generate(2, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(optionIcons[index], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      optionTexts[index],
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF43A047)),
          ),
        ),
      );
    }

    final isEdit = widget.perlengkapanId != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
              'Tambah Perlengkapan',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSantriSearch(),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: Color(0xFF43A047),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tanggal",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tanggal,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.edit_calendar, size: 18),
                      label: Text(
                        'Ubah',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      onPressed: _selectDate,
                      style: TextButton.styleFrom(
                        foregroundColor: Color(0xFF43A047),
                      ),
                    ),
                  ],
                ),
              ),

              // Equipment Section
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF43A047).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            color: Color(0xFF43A047),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Perlengkapan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._items.keys.map((k) => _buildKelayakanField(k)).toList(),
                  ],
                ),
              ),

              // Notes Section
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _keteranganController,
                  maxLines: 3,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Keterangan',
                    labelStyle: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF43A047).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.note_alt,
                        color: Color(0xFF43A047),
                        size: 20,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.indigo, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),

              // Submit Button
              Container(
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF43A047),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isEdit ? 'Simpan' : 'Simpan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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