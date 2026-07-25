import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/santri_model.dart';
import '../../models/izin_model.dart';
import '../../services/izin_service.dart';
import '../../services/santri_service.dart';

class TambahIzinScreen extends StatefulWidget {
  final Izin? izin;

  const TambahIzinScreen({super.key, this.izin});

  @override
  State<TambahIzinScreen> createState() => _TambahIzinScreenState();
}

class _TambahIzinScreenState extends State<TambahIzinScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController searchController = TextEditingController();
  final TextEditingController kategoriPelanggaranController = TextEditingController();

  List<Santri> santriList = [];
  Santri? selectedSantri;

  DateTime? selectedTanggal;
  TimeOfDay? keluarTime;
  TimeOfDay? kembaliTime;

  int? selectedKategori;
  int? selectedStatus;

  bool get isEdit => widget.izin != null;
  bool isLoading = false;

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

  int? _getDropdownValue(List<Map<String, Object>> list, String label) {
    final match = list.firstWhere(
      (item) => (item['label'] as String).toLowerCase().trim() == label.toLowerCase().trim(),
      orElse: () => {},
    );
    return match['value'] as int?;
  }


  Future<void> _fetchSantri() async {
    try {
      final response = await SantriService.fetchAllSantri();
      setState(() {
        santriList = response.data;

        if (isEdit) {
          final izin = widget.izin!;
          selectedSantri = santriList.firstWhere(
            (santri) => santri.nama == izin.nama,
            orElse: () => Santri(id: '', nama: izin.nama, noInduk: '-', kelas: null),
          );

          searchController.text = '${selectedSantri?.nama ?? ''} (${selectedSantri?.noInduk ?? ''})';

          try {
            selectedTanggal = DateFormat('dd MMMM yyyy', 'id_ID').parse(izin.tanggal);
          } catch (_) {
            selectedTanggal = DateTime.tryParse(izin.tanggal);
          }

          keluarTime = _parseTimeOfDay(izin.keluar);
          kembaliTime = _parseTimeOfDay(izin.kembali);

          selectedKategori = _getDropdownValue(kategoriList, izin.kategori);
          selectedStatus = _getDropdownValue(statusList, izin.status);

          kategoriPelanggaranController.text = izin.kategoriPelanggaran;
        }
      });
    } catch (e) {
    }
  }


  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedSantri == null || selectedTanggal == null || keluarTime == null || kembaliTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data terlebih dahulu')),
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
    setState(() => isLoading = true);
    bool success = false;

    try {
      success = isEdit
          ? await IzinService.updateIzin(widget.izin!.id, request)
          : await IzinService.postIzin(request);
    } catch (e) {
      print('Error saat submit izin: $e'); // Optional: tampilkan error
    }

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Berhasil diperbarui' : 'Berhasil disimpan')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Gagal memperbarui izin' : 'Gagal menyimpan izin')),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedTanggal ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedTanggal = picked);
  }

  Future<void> _pickTime(bool isKeluar) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isKeluar) keluarTime = picked;
        else kembaliTime = picked;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    kategoriPelanggaranController.dispose();
    super.dispose();
  }

  Widget _buildSantriSearch() {
    return Autocomplete<Santri>(
      optionsBuilder: (TextEditingValue val) {
        if (val.text.isEmpty) return const Iterable<Santri>.empty();
        return santriList.where((s) =>
            s.nama.toLowerCase().contains(val.text.toLowerCase()) ||
            s.noInduk.toLowerCase().contains(val.text.toLowerCase()));
      },
      displayStringForOption: (s) => '${s.nama} (${s.noInduk})',
      onSelected: (s) {
        setState(() {
          selectedSantri = s;
          searchController.text = '${s.nama} (${s.noInduk})';
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        controller.text = searchController.text;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
          decoration: const InputDecoration(
            labelText: 'Cari Santri',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          validator: (_) => selectedSantri == null ? 'Pilih santri' : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEdit ? 'Edit Izin' : 'Tambah Izin'),
        backgroundColor:  Color(0xFF004e92),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSantriSearch(),
              const SizedBox(height: 16),
              ListTile(
                title: const Text("Tanggal Izin"),
                subtitle: Text(selectedTanggal == null
                    ? "Belum dipilih"
                    : DateFormat('dd MMM yyyy').format(selectedTanggal!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                title: const Text("Jam Keluar"),
                subtitle: Text(keluarTime?.format(context) ?? "Belum dipilih"),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(true),
              ),
              ListTile(
                title: const Text("Jam Kembali"),
                subtitle: Text(kembaliTime?.format(context) ?? "Belum dipilih"),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(false),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  border: OutlineInputBorder(),
                ),
                value: selectedKategori,
                items: kategoriList
                .map((item) => DropdownMenuItem<int>(
                      value: item['value'] as int,
                      child: Text(item['label'] as String),
                    ))
                .toList(),
                onChanged: (val) => setState(() => selectedKategori = val),
                validator: (val) => val == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
                value: selectedStatus,
                items: statusList
                .map((item) => DropdownMenuItem<int>(
                      value: item['value'] as int,
                      child: Text(item['label'] as String),
                    ))
                .toList(),
                onChanged: (val) => setState(() => selectedStatus = val),
                validator: (val) => val == null ? 'Pilih status' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(isEdit ? Icons.edit : Icons.save),
                label: Text(isLoading
                    ? "Menyimpan..."
                    : isEdit
                        ? "Perbarui"
                        : "Simpan"),
                onPressed: isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF004e92),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

TimeOfDay _parseTimeOfDay(String time) {
  final parts = time.split(":");
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}
