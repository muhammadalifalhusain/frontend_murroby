import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/pelanggaran_model.dart';
import '../../models/santri_model.dart';
import '../../services/pelanggaran_service.dart';
import '../../services/santri_service.dart';

class PostPelanggaranScreen extends StatefulWidget {
  final Pelanggaran? pelanggaran;

  const PostPelanggaranScreen({super.key, this.pelanggaran});

  @override
  State<PostPelanggaranScreen> createState() => _PostPelanggaranScreenState();
}

class _PostPelanggaranScreenState extends State<PostPelanggaranScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController jenisController = TextEditingController();
  final TextEditingController hukumanController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  File? _pickedImage;
  List<Santri> santriList = [];
  Santri? selectedSantri;
  String? selectedKategori;

  bool get isEditMode => widget.pelanggaran != null;

  @override
  void initState() {
    super.initState();
    _fetchSantri();

    if (isEditMode) {
      final p = widget.pelanggaran!;
      tanggalController.text = p.tanggal;
      jenisController.text = p.jenisPelanggaran;
      hukumanController.text = p.hukuman;
      selectedKategori = _kategoriToValue(p.kategori);
      searchController.text = p.nama;      
    }
  }

  Future<void> _fetchSantri() async {
    try {
      final response = await SantriService.fetchAllSantri();
      setState(() {
        santriList = response.data;
      });
    } catch (_) {}
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedSantri == null || selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Santri dan kategori wajib diisi')),
      );
      return;
    }

    final request = PelanggaranRequest(
      noInduk: selectedSantri!.noInduk,
      tanggal: tanggalController.text,
      jenis: jenisController.text,
      kategori: selectedKategori!,
      hukuman: hukumanController.text,
      buktiPath: _pickedImage?.path,
    );

    try {
      bool result = isEditMode
          ? await PelanggaranService.updatePelanggaran(widget.pelanggaran!.id, request)
          : await PelanggaranService.submitPelanggaran(request);

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditMode ? 'Berhasil diperbarui' : 'Berhasil disimpan')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }
  }

  @override
  void dispose() {
    tanggalController.dispose();
    jenisController.dispose();
    hukumanController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEditMode ? 'Edit Pelanggaran' : 'Tambah Pelanggaran'),
        backgroundColor: Color(0xFF004e92),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSantriSearch(),
              const SizedBox(height: 16),
              TextFormField(
                controller: tanggalController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    tanggalController.text =
                        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                  }
                },
                validator: (val) => val!.isEmpty ? 'Tanggal wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: jenisController,
                decoration: InputDecoration(
                  labelText: 'Jenis Pelanggaran',
                  prefixIcon: const Icon(Icons.warning),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (val) => val!.isEmpty ? 'Jenis wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedKategori,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Ringan')),
                  DropdownMenuItem(value: '2', child: Text('Berat')),
                ],
                onChanged: (val) => setState(() => selectedKategori = val),
                validator: (val) => val == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: hukumanController,
                decoration: InputDecoration(
                  labelText: 'Hukuman',
                  prefixIcon: const Icon(Icons.gavel),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (val) => val!.isEmpty ? 'Hukuman wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Text('Bukti Pelanggaran (Opsional)', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              if (_pickedImage != null)
                Column(
                  children: [
                    Image.file(_pickedImage!, height: 150),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Hapus Gambar'),
                      onPressed: () => setState(() => _pickedImage = null),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeri'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Kamera'),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: Text(isEditMode ? 'Perbarui' : 'Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF004e92),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSantriSearch() {
    return Autocomplete<Santri>(
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
          decoration: InputDecoration(
            labelText: 'Cari Santri',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (_) => selectedSantri == null ? 'Pilih nama santri' : null,
        );
      },
    );
  }
}
String? _kategoriToValue(String kategori) {
  switch (kategori.toLowerCase()) {
    case 'ringan':
      return '1';
    case 'berat':
      return '2';
    default:
      return null;
  }
}

