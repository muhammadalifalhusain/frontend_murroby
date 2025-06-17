class TambahPemeriksaan {
  final String noInduk;
  final String tanggalPemeriksaan;
  final int tinggiBadan;
  final int beratBadan;
  final int lingkarPinggul;
  final int lingkarDada;
  final String kondisiGigi;

  TambahPemeriksaan({
    required this.noInduk,
    required this.tanggalPemeriksaan,
    required this.tinggiBadan,
    required this.beratBadan,
    required this.lingkarPinggul,
    required this.lingkarDada,
    required this.kondisiGigi,
  });

  Map<String, dynamic> toJson() {
    return {
      'noInduk': noInduk,
      'tanggalPemeriksaan': tanggalPemeriksaan,
      'tinggiBadan': tinggiBadan,
      'beratBadan': beratBadan,
      'lingkarPinggul': lingkarPinggul,
      'lingkarDada': lingkarDada,
      'kondisiGigi': kondisiGigi,
    };
  }
}


class PemeriksaanResponse {
  final int status;
  final String message;
  final Data data;

  PemeriksaanResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PemeriksaanResponse.fromJson(Map<String, dynamic> json) {
    return PemeriksaanResponse(
      status: json['status'],
      message: json['message'],
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  final DataUser dataUser;
  final List<DataSantri> dataSantri;

  Data({
    required this.dataUser,
    required this.dataSantri,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      dataUser: DataUser.fromJson(json['dataUser']),
      dataSantri: List<DataSantri>.from(
        json['dataSantri'].map((x) => DataSantri.fromJson(x)),
      ),
    );
  }
}

class DataUser {
  final String namaMurroby;
  final String fotoMurroby;
  final String kodeKamar;
  final int idKamar;

  DataUser({
    required this.namaMurroby,
    required this.fotoMurroby,
    required this.kodeKamar,
    required this.idKamar,
  });

  factory DataUser.fromJson(Map<String, dynamic> json) {
    return DataUser(
      namaMurroby: json['namaMurroby'],
      fotoMurroby: json['fotoMurroby'],
      kodeKamar: json['kodeKamar'],
      idKamar: json['idKamar'],
    );
  }
}

class DataSantri {
  final int noInduk;
  final String nama;
  final DateTime? tanggalPemeriksaan;
  final double? tinggiBadan;
  final double? beratBadan;
  final double? lingkarPinggul;
  final double? lingkarDada;
  final String? kondisiGigi;

  DataSantri({
    required this.noInduk,
    required this.nama,
    this.tanggalPemeriksaan,
    this.tinggiBadan,
    this.beratBadan,
    this.lingkarPinggul,
    this.lingkarDada,
    this.kondisiGigi,
  });

  factory DataSantri.fromJson(Map<String, dynamic> json) {
    return DataSantri(
      noInduk: json['noInduk'],
      nama: json['nama'],
      tanggalPemeriksaan: json['tanggalPemeriksaan'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['tanggalPemeriksaan'] * 1000)
          : null,
      tinggiBadan: (json['tinggiBadan'] != null)
          ? (json['tinggiBadan'] as num).toDouble()
          : null,
      beratBadan: (json['beratBadan'] != null)
          ? (json['beratBadan'] as num).toDouble()
          : null,
      lingkarPinggul: (json['lingkarPinggul'] != null)
          ? (json['lingkarPinggul'] as num).toDouble()
          : null,
      lingkarDada: (json['lingkarDada'] != null)
          ? (json['lingkarDada'] as num).toDouble()
          : null,
      kondisiGigi: json['kondisiGigi'],
    );
  }
}
