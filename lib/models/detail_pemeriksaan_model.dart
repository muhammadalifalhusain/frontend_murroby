class DetailPemeriksaan {
  final int status;
  final String message;
  final PemeriksaanData data;

  DetailPemeriksaan({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DetailPemeriksaan.fromJson(Map<String, dynamic> json) {
    return DetailPemeriksaan(
      status: json['status'],
      message: json['message'],
      data: PemeriksaanData.fromJson(json['data']),
    );
  }
}

class PemeriksaanData {
  final DataSantri dataSantri;
  final List<DataPemeriksaan> dataPemeriksaan;

  PemeriksaanData({
    required this.dataSantri,
    required this.dataPemeriksaan,
  });

  factory PemeriksaanData.fromJson(Map<String, dynamic> json) {
    return PemeriksaanData(
      dataSantri: DataSantri.fromJson(json['dataSantri']),
      dataPemeriksaan: (json['dataPemeriksaan'] as List)
          .map((item) => DataPemeriksaan.fromJson(item))
          .toList(),
    );
  }
}

class DataSantri {
  final String nama;
  final int noInduk;

  DataSantri({
    required this.nama,
    required this.noInduk,
  });

  factory DataSantri.fromJson(Map<String, dynamic> json) {
    return DataSantri(
      nama: json['nama'],
      noInduk: json['noInduk'],
    );
  }
}

class DataPemeriksaan {
  final int id;
  final int tanggalPemeriksaan;
  final int tinggiBadan;
  final int beratBadan;
  final int lingkarPinggul;
  final int lingkarDada;
  final String kondisiGigi;

  DataPemeriksaan({
    required this.id,
    required this.tanggalPemeriksaan,
    required this.tinggiBadan,
    required this.beratBadan,
    required this.lingkarPinggul,
    required this.lingkarDada,
    required this.kondisiGigi,
  });

  factory DataPemeriksaan.fromJson(Map<String, dynamic> json) {
    return DataPemeriksaan(
      id: json['id'],
      tanggalPemeriksaan: json['tanggalPemeriksaan'],
      tinggiBadan: json['tinggiBadan'],
      beratBadan: json['beratBadan'],
      lingkarPinggul: json['lingkarPinggul'],
      lingkarDada: json['lingkarDada'],
      kondisiGigi: json['kondisiGigi'],
    );
  }

  DateTime get tanggal =>
      DateTime.fromMillisecondsSinceEpoch(tanggalPemeriksaan * 1000);
}
