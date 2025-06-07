class DetailSakuResponse {
  final DataSantri dataSantri;
  final List<UangMasuk>? dataUangMasuk;
  final List<UangKeluar>? dataUangKeluar;

  DetailSakuResponse({
    required this.dataSantri,
    this.dataUangMasuk,
    this.dataUangKeluar,
  });

  factory DetailSakuResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data']; // ambil nested "data"

    return DetailSakuResponse(
      dataSantri: DataSantri.fromJson(data['dataSantri']),
      dataUangMasuk: data['dataUangMasuk'] != null
          ? (data['dataUangMasuk'] as List)
              .map((e) => UangMasuk.fromJson(e))
              .toList()
          : null,
      dataUangKeluar: data['dataUangKeluar'] != null
          ? (data['dataUangKeluar'] as List)
              .map((e) => UangKeluar.fromJson(e))
              .toList()
          : null,
    );
  }
}

class DataSantri {
  final int noInduk;
  final String namaSantri;

  DataSantri({
    required this.noInduk,
    required this.namaSantri,
  });

  factory DataSantri.fromJson(Map<String, dynamic> json) {
    return DataSantri(
      noInduk: json['noInduk'],
      namaSantri: json['namaSantri'],
    );
  }
}

class UangMasuk {
  final String uangAsal;
  final int jumlahMasuk;
  final String tanggalTransaksi;

  UangMasuk({
    required this.uangAsal,
    required this.jumlahMasuk,
    required this.tanggalTransaksi,
  });

  factory UangMasuk.fromJson(Map<String, dynamic> json) {
    return UangMasuk(
      uangAsal: json['uangAsal'],
      jumlahMasuk: json['jumlahMasuk'],
      tanggalTransaksi: json['tanggalTransaksi'],
    );
  }
}

class UangKeluar {
  final int jumlahKeluar;
  final String catatan;
  final String tanggalTransaksi;
  final String namaMurroby;

  UangKeluar({
    required this.jumlahKeluar,
    required this.catatan,
    required this.tanggalTransaksi,
    required this.namaMurroby,
  });

  factory UangKeluar.fromJson(Map<String, dynamic> json) {
    return UangKeluar(
      jumlahKeluar: json['jumlahKeluar'],
      catatan: json['catatan'],
      tanggalTransaksi: json['tanggalTransaksi'],
      namaMurroby: json['namaMurroby'],
    );
  }
}
