import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/detailSaku_service.dart';
import '../utils/session_manager.dart';

class AddUangKeluarForm extends StatefulWidget {
  final int noInduk;
  final VoidCallback onSuccess;

  const AddUangKeluarForm({
    Key? key,
    required this.noInduk,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<AddUangKeluarForm> createState() => _AddUangKeluarFormState();
}

class _AddUangKeluarFormState extends State<AddUangKeluarForm> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      setState(() {
        tanggalController.text = DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate);
      });
    });
  }

  @override
  void dispose() {
    jumlahController.dispose();
    catatanController.dispose();
    tanggalController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final idUser = await SessionManager.getIdUser();

        if (idUser == null || idUser == 0) {
          throw Exception("ID User tidak ditemukan. Silakan login ulang.");
        }

        String cleanAmount = jumlahController.text.replaceAll('.', '');

        final response = await DetailSakuService.postUangKeluar(
          noInduk: widget.noInduk,
          idUser: idUser,
          jumlah: int.parse(cleanAmount),
          catatan: catatanController.text,
          tanggal: DateFormat('yyyy-MM-dd').format(selectedDate),
          allKamar: false,
        );

        print('--- POST UANG KELUAR ---');
        print('noInduk: ${widget.noInduk}');
        print('idUser: $idUser');
        print('jumlah: $cleanAmount');
        print('catatan: ${catatanController.text}');
        print('tanggal: ${DateFormat('yyyy-MM-dd').format(selectedDate)}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(response),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );

          widget.onSuccess();
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.toString())),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 16,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red.shade600,
                      Colors.red.shade400,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.remove_circle_outline,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tambah Uang Keluar',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAmountField(),
                        const SizedBox(height: 20),
                        _buildNoteField(),
                        const SizedBox(height: 20),
                        _buildDateField(),
                        const SizedBox(height: 32),
                        _buildActionButtons(),
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

  Widget _buildAmountField() {
    return TextFormField(
      controller: jumlahController,
      decoration: InputDecoration(
        labelText: 'Jumlah',
        labelStyle: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.payments, color: Colors.red.shade600, size: 20),
        ),
        prefixText: 'Rp ',
        prefixStyle: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CurrencyInputFormatter(),
      ],
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Masukkan jumlah';
        }
        String cleanValue = value.replaceAll('.', '');
        if (int.tryParse(cleanValue) == null) {
          return 'Masukkan angka yang valid';
        }
        if (int.parse(cleanValue) <= 0) {
          return 'Jumlah harus lebih dari 0';
        }
        return null;
      },
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: catatanController,
      decoration: InputDecoration(
        labelText: 'Catatan',
        labelStyle: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.note, color: Colors.purple.shade600, size: 20),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Masukkan catatan';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: tanggalController,
      decoration: InputDecoration(
        labelText: 'Tanggal',
        labelStyle: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.calendar_today, color: Colors.orange.shade600, size: 20),
        ),
        suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      readOnly: true,
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.blue.shade600,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.grey.shade800,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );
        if (picked != null && picked != selectedDate) {
          setState(() {
            selectedDate = picked;
            tanggalController.text = 
                DateFormat('dd MMMM yyyy', 'id_ID').format(picked);
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pilih tanggal';
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: isLoading ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 18),
            label: const Text(
              'BATAL',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 3,
              shadowColor: Colors.red.shade200,
            ),
            onPressed: isLoading ? null : _submitForm,
            icon: isLoading
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save, size: 18),
            label: Text(
              isLoading ? 'MENYIMPAN...' : 'SIMPAN',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }
    String formatted = '';
    int counter = 0;
    for (int i = newText.length - 1; i >= 0; i--) {
      if (counter == 3) {
        formatted = '.' + formatted;
        counter = 0;
      }
      formatted = newText[i] + formatted;
      counter++;
    }
    
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}