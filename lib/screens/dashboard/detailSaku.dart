import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

import 'package:google_fonts/google_fonts.dart';
import 'package:murroby/models/detailSaku_model.dart';
import 'package:murroby/services/detailSaku_service.dart';

class DetailSakuScreen extends StatefulWidget {
  final int noInduk;
  final String namaSantri;

  const DetailSakuScreen({
    Key? key,
    required this.noInduk,
    required this.namaSantri,
  }) : super(key: key);

  @override
  _DetailSakuScreenState createState() => _DetailSakuScreenState();
}

  class _DetailSakuScreenState extends State<DetailSakuScreen> with SingleTickerProviderStateMixin {
    late Future<DetailSakuResponse> futureUangMasuk;
    late Future<DetailSakuResponse> futureUangKeluar;
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    late TabController _tabController; // Tambah ini

    @override
    void initState() {
      super.initState();
      _tabController = TabController(length: 2, vsync: this); 
      _refreshData();
    }

    @override
    void dispose() {
      _tabController.dispose(); 
      super.dispose();
    }

    void _refreshData() {
      setState(() {
        futureUangMasuk = DetailSakuService.fetchUangMasuk(widget.noInduk);
        futureUangKeluar = DetailSakuService.fetchUangKeluar(widget.noInduk);
      });
    }

  void _showAddUangKeluarDialog() async {
    final formKey = GlobalKey<FormState>();
    TextEditingController jumlahController = TextEditingController();
    TextEditingController catatanController = TextEditingController();
    TextEditingController tanggalController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    tanggalController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getInt('userId');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Uang Keluar'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: jumlahController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Masukkan jumlah' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: catatanController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Masukkan catatan' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: tanggalController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        tanggalController.text =
                            DateFormat('yyyy-MM-dd').format(picked);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final response = await DetailSakuService.postUangKeluar(
                      noInduk: widget.noInduk,
                      idUser: idUser ?? 0,
                      jumlah: int.parse(jumlahController.text),
                      catatan: catatanController.text,
                      tanggal: tanggalController.text,
                      allKamar: false,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response)),
                    );
                    Navigator.pop(context);
                    _refreshData();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }


  void _showAddUangMasukDialog() {
    final formKey = GlobalKey<FormState>();
    int? selectedDari;
    TextEditingController jumlahController = TextEditingController();
    TextEditingController tanggalController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    // Set initial date
    tanggalController.text = DateFormat('yyyy-MM-dd').format(selectedDate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    const Text(
                      'Tambah Uang Masuk',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // Sumber Uang
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Sumber Uang',
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                        fillColor: Colors.blue[50],
                        prefixIcon: const Icon(Icons.source, color: Colors.teal),
                      ),
                      value: selectedDari,
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Uang Saku'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('Kunjungan Walsan'),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('Sisa Bulan Kemarin'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedDari = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih sumber uang';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Jumlah
                    TextFormField(
                      controller: jumlahController,
                      decoration: InputDecoration(
                        labelText: 'Jumlah',
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                        fillColor: Colors.blue[50],
                        prefixIcon: const Icon(Icons.money, color: Colors.teal),
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan jumlah';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tanggal
                    TextFormField(
                      controller: tanggalController,
                      decoration: InputDecoration(
                        labelText: 'Tanggal',
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                        fillColor: Colors.blue[50],
                        prefixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
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
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.blue,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                            tanggalController.text =
                                DateFormat('yyyy-MM-dd').format(picked);
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih tanggal';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('BATAL'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              try {
                                final response = await DetailSakuService.postUangMasuk(
                                  noInduk: widget.noInduk,
                                  dari: selectedDari!,
                                  jumlah: int.parse(jumlahController.text),
                                  tanggal: tanggalController.text,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(response),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );

                                _refreshData();
                                Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('SIMPAN'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 229, 229), 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 64,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.namaSantri,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8), 
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF7B9080), 
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Uang Masuk'),
                  Tab(text: 'Uang Keluar'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUangMasukTab(),
                _buildUangKeluarTab(),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddUangMasukDialog();
          } else {
            _showAddUangKeluarDialog();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Data',
      ),
    );
  }



  Widget _buildUangMasukTab() {
    return FutureBuilder<DetailSakuResponse>(
      future: futureUangMasuk,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.dataUangMasuk == null) {
          return const Center(child: Text('Tidak ada data uang masuk'));
        }

        final data = snapshot.data!;
        final uangMasukList = data.dataUangMasuk!;

        return RefreshIndicator(
          onRefresh: () async {
            _refreshData();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: uangMasukList.length,
            itemBuilder: (context, index) {
              final uangMasuk = uangMasukList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            uangMasuk.uangAsal,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currencyFormat.format(uangMasuk.jumlahMasuk),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tanggal: ${_formatDate(uangMasuk.tanggalTransaksi)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUangKeluarTab() {
    return FutureBuilder<DetailSakuResponse>(
      future: futureUangKeluar,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.dataUangKeluar == null) {
          return const Center(child: Text('Tidak ada data uang keluar'));
        }

        final data = snapshot.data!;
        final uangKeluarList = data.dataUangKeluar!;

        return RefreshIndicator(
          onRefresh: () async {
            _refreshData();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: uangKeluarList.length,
            itemBuilder: (context, index) {
              final uangKeluar = uangKeluarList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            uangKeluar.catatan,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currencyFormat.format(uangKeluar.jumlahKeluar),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tanggal: ${_formatDate(uangKeluar.tanggalTransaksi)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Oleh: ${uangKeluar.namaMurroby}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }
}