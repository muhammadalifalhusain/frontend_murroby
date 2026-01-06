class DetailSakuResponse {
  final int status;
  final String message;
  final DataSantri? dataSantri;
  final Map<String, Map<String, List<UangMasuk>>>? dataUangMasuk; 
  final Map<String, Map<String, List<UangKeluar>>>? dataUangKeluar; 

  DetailSakuResponse({
    required this.status,
    required this.message,
    this.dataSantri,
    this.dataUangMasuk,
    this.dataUangKeluar,
  });

  factory DetailSakuResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return DetailSakuResponse(
      status: json['status'] ?? 0,
      message: (json['message'] ?? '').toString(),
      dataSantri: data['dataSantri'] != null
          ? DataSantri.fromJson(data['dataSantri'])
          : null,
      dataUangMasuk: _parseUangMasuk(data['dataUangMasuk']),
      dataUangKeluar: _parseUangKeluar(data['dataUangKeluar']),
    );
  }

  static Map<String, Map<String, List<UangMasuk>>>? _parseUangMasuk(dynamic json) {
    if (json == null || json is! Map) return null;
    final Map<String, Map<String, List<UangMasuk>>> result = {};

    json.forEach((tahun, bulanData) {
      if (bulanData is Map) {
        final Map<String, List<UangMasuk>> bulanMap = {};
        bulanData.forEach((bulan, listData) {
          bulanMap[bulan] = (listData as List?)
                  ?.map((e) => UangMasuk.fromJson(e))
                  .toList() ??
              [];
        });
        result[tahun] = bulanMap;
      }
    });

    return result;
  }

  static Map<String, Map<String, List<UangKeluar>>>? _parseUangKeluar(dynamic json) {
    if (json == null || json is! Map) return null;
    final Map<String, Map<String, List<UangKeluar>>> result = {};

    json.forEach((tahun, bulanData) {
      if (bulanData is Map) {
        final Map<String, List<UangKeluar>> bulanMap = {};
        bulanData.forEach((bulan, listData) {
          bulanMap[bulan] = (listData as List?)
                  ?.map((e) => UangKeluar.fromJson(e))
                  .toList() ??
              [];
        });
        result[tahun] = bulanMap;
      }
    });

    return result;
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
      noInduk: json['noInduk'] is int
          ? json['noInduk']
          : int.tryParse(json['noInduk']?.toString() ?? '0') ?? 0,
      namaSantri: (json['namaSantri'] ?? '').toString().trim(),
    );
  }
}

class UangMasuk {
  final String uangAsal;
  final int jumlahMasuk;
  final String tanggalTransaksi;
  final String teksBulan;

  UangMasuk({
    required this.uangAsal,
    required this.jumlahMasuk,
    required this.tanggalTransaksi,
    required this.teksBulan,
  });

  factory UangMasuk.fromJson(Map<String, dynamic> json) {
    return UangMasuk(
      uangAsal: (json['uangAsal'] ?? '').toString().trim(),
      jumlahMasuk: json['jumlahMasuk'] is int
          ? json['jumlahMasuk']
          : int.tryParse(json['jumlahMasuk']?.toString() ?? '0') ?? 0,
      tanggalTransaksi: (json['tanggalTransaksi'] ?? '').toString(),
      teksBulan: (json['teksBulan'] ?? '').toString(),
    );
  }
}

class UangKeluar {
  final int jumlahKeluar;
  final String catatan;
  final String tanggalTransaksi;
  final String namaMurroby;
  final String teksBulan;

  UangKeluar({
    required this.jumlahKeluar,
    required this.catatan,
    required this.tanggalTransaksi,
    required this.namaMurroby,
    required this.teksBulan,
  });

  factory UangKeluar.fromJson(Map<String, dynamic> json) {
    return UangKeluar(
      jumlahKeluar: json['jumlahKeluar'] is int
          ? json['jumlahKeluar']
          : int.tryParse(json['jumlahKeluar']?.toString() ?? '0') ?? 0,
      catatan: (json['catatan'] ?? '').toString().trim(),
      tanggalTransaksi: (json['tanggalTransaksi'] ?? '').toString(),
      namaMurroby: (json['namaMurroby'] ?? '').toString().trim(),
      teksBulan: (json['teksBulan'] ?? '').toString(),
    );
  }
}
