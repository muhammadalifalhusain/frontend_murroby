import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';
import '../../services/detailSaku_service.dart';
import '../../utils/session_manager.dart';
class TambahUangKeluarScreen extends StatefulWidget {
  const TambahUangKeluarScreen({Key? key}) : super(key: key);

  @override
  State<TambahUangKeluarScreen> createState() => _TambahUangKeluarScreenState();
}

class _TambahUangKeluarScreenState extends State<TambahUangKeluarScreen>
    with TickerProviderStateMixin {
  List<Santri> _santriList = [];
  List<Santri> _selectedSantri = [];

  bool _allKamar = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  DateTime? _selectedDate;

  bool _isLoading = false;
  bool _isLoadingSantri = true;
  int? _idUser;

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
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _loadSantriList() async {
    try {
      final userData = await ApiService.fetchUserData();
      setState(() {
        _santriList = userData.data.listSantri;
        _idUser = userData.data.dataUser.idPegawai;
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

  void _openSantriMultiSelect() {
    final tempSelected = List<Santri>.from(_selectedSantri);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Pilih Santri',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _santriList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final santri = _santriList[index];
                    final isSelected = tempSelected.contains(santri);

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setStateDialog(() {
                          isSelected
                              ? tempSelected.remove(santri)
                              : tempSelected.add(santri);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.red.shade50
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? Colors.red.shade300
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                santri.namaSantri,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            Checkbox(
                              value: isSelected,
                              activeColor: Colors.red.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (checked) {
                                setStateDialog(() {
                                  checked == true
                                      ? tempSelected.add(santri)
                                      : tempSelected.remove(santri);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedSantri = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Simpan',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _submit() async {
    if (!_allKamar && _selectedSantri.isEmpty) {
      _showErrorSnackBar("Santri harus dipilih!");
      return;
    }

    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      if (_selectedDate == null) {
        _showErrorSnackBar("Tanggal harus dipilih!");
      }
      return;
    }

    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final raw = _jumlahController.text;
      final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
      final jumlah = int.tryParse(cleaned);

      if (jumlah == null || jumlah <= 0) {
        _showErrorSnackBar("Jumlah harus berupa angka positif!");
        return;
      }

      final result = await DetailSakuService.postUangKeluar(
        jumlah: jumlah,
        catatan: _catatanController.text,
        tanggal: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        allKamar: _allKamar,
        selectedSantri: !_allKamar
            ? _selectedSantri.map((e) => e.noIndukSantri).toList()
            : null,
      );

      if (mounted) {
        _showSuccessSnackBar(result);
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorSnackBar("Terjadi kesalahan: ${e.toString()}");
    } finally {
      if (mounted) {
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
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.help_outline, color: Colors.red.shade600),
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
              'Pastikan data pengeluaran berikut sudah benar ya',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            if (_allKamar)
            FutureBuilder<String>(
              future: SessionManager.getNamaMurroby(),
              builder: (context, snapshot) {
                final nama = snapshot.data ?? '-';
                return _buildConfirmationItem('Target', 'Semua santri binaan kamar $nama');
              },
            )
            else
            _buildConfirmationItem(
              'Santri',
              _allKamar
                  ? 'Semua santri dalam kamar'
                  : _selectedSantri.map((e) => e.namaSantri).join(', '),
            ),
            _buildConfirmationItem(
              'Jumlah',
              'Rp ${NumberFormat('#,##0', 'id').format(
                int.parse(_jumlahController.text.replaceAll(RegExp(r'[^0-9]'), '')),
              )}',
            ),
            _buildConfirmationItem('Catatan', _catatanController.text),
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
              backgroundColor: Colors.red.shade600,
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
              primary: Colors.red.shade600,
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
            Colors.red.shade400,
            Colors.red.shade600,
            Colors.red.shade800,
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
              'Tambah Uang Keluar',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Catat pengeluaran uang santri dengan mudah',
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

  Widget _buildAllKamarSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _allKamar ? Colors.red.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.group,
                color: _allKamar ? Colors.red.shade600 : Colors.grey.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terapkan ke Semua Santri',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    'Pengeluaran berlaku untuk seluruh santri',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _allKamar,
              onChanged: (val) {
                setState(() {
                  _allKamar = val;
                  if (val) {
                    _selectedSantri.clear();
                  }
                });
              },
              activeColor: Colors.red.shade600,
              inactiveThumbColor: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSantriDropdown() {
    return GestureDetector(
      onTap: _allKamar ? null : _openSantriMultiSelect,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _allKamar ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _allKamar
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Santri',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color:
                    _allKamar ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            _selectedSantri.isEmpty
                ? Text(
                    'Tap untuk memilih santri',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedSantri.map((santri) {
                      return Chip(
                        label: Text(santri.namaSantri),
                        onDeleted: _allKamar
                            ? null
                            : () {
                                setState(() {
                                  _selectedSantri.remove(santri);
                                });
                              },
                      );
                    }).toList(),
                  ),
          ],
        ),
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
          labelText: 'Jumlah Pengeluaran',
          labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
          hintText: 'Masukkan jumlah pengeluaran',
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


  Widget _buildCatatanField() {
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
        controller: _catatanController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Catatan Pengeluaran',
          labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
          hintText: 'Masukkan detail pengeluaran (misal: beli makanan, bayar laundry)',
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
            child: Icon(Icons.note_alt, color: Colors.red.shade600, size: 20),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          alignLabelWithHint: true,
        ),
        style: GoogleFonts.poppins(fontSize: 14),
        validator: (val) => val == null || val.isEmpty ? 'Catatan wajib diisi' : null,
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
                      'Tanggal Pengeluaran',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedDate == null
                          ? 'Pilih tanggal pengeluaran'
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
          colors: [Colors.red.shade400, Colors.red.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
  
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade600),
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
                                'Informasi Pengeluaran',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 13),
                              _buildAllKamarSwitch(),
                              const SizedBox(height: 16),
                              _buildSantriDropdown(),
                              const SizedBox(height: 14),
                              _buildJumlahField(),
                              const SizedBox(height: 14),
                              _buildCatatanField(),
                              const SizedBox(height: 14),
                              _buildDatePicker(),
                              const SizedBox(height: 21),
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