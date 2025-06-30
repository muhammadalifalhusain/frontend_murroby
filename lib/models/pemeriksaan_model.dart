class PemeriksaanResponse {
  final int status;
  final String message;
  final PemeriksaanData data;

  PemeriksaanResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PemeriksaanResponse.fromJson(Map<String, dynamic> json) {
    return PemeriksaanResponse(
      status: json['status'] is int ? json['status'] : int.parse(json['status']),
      message: json['message'].toString(),
      data: PemeriksaanData.fromJson(json['data']),
    );
  }
}

class PemeriksaanData {
  final DataUser dataUser;
  final List<DataSantri> dataSantri;

  PemeriksaanData({
    required this.dataUser,
    required this.dataSantri,
  });

  factory PemeriksaanData.fromJson(Map<String, dynamic> json) {
    var santriList = json['dataSantri'] as List;
    List<DataSantri> santriItems = santriList.map((i) => DataSantri.fromJson(i)).toList();

    return PemeriksaanData(
      dataUser: DataUser.fromJson(json['dataUser']),
      dataSantri: santriItems,
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
      namaMurroby: json['namaMurroby'].toString(),
      fotoMurroby: json['fotoMurroby'].toString(),
      kodeKamar: json['kodeKamar'].toString(),
      idKamar: json['idKamar'] is int ? json['idKamar'] : int.parse(json['idKamar']),
    );
  }
}

class DataSantri {
  final int noInduk;
  final String nama;
  final String? tanggalPemeriksaan;
  final double? tinggiBadan;
  final double? beratBadan;
  final double? lingkarPinggul;
  final double? lingkarDada;
  final String? kondisiGigi;
  final String? tanggalPemeriksaanFormatted;

  DataSantri({
    required this.noInduk,
    required this.nama,
    this.tanggalPemeriksaan,
    this.tinggiBadan,
    this.beratBadan,
    this.lingkarPinggul,
    this.lingkarDada,
    this.kondisiGigi,
    this.tanggalPemeriksaanFormatted,
  });

  factory DataSantri.fromJson(Map<String, dynamic> json) {
    return DataSantri(
      noInduk: json['noInduk'] is int ? json['noInduk'] : int.parse(json['noInduk']),
      nama: json['nama'].toString(),
      tanggalPemeriksaan: json['tanggalPemeriksaan']?.toString(),
      tinggiBadan: _parseDouble(json['tinggiBadan']),
      beratBadan: _parseDouble(json['beratBadan']),
      lingkarPinggul: _parseDouble(json['lingkarPinggul']),
      lingkarDada: _parseDouble(json['lingkarDada']),
      kondisiGigi: json['kondisiGigi']?.toString(),
      tanggalPemeriksaanFormatted: json['tanggalPemeriksaanFormatted']?.toString(),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class PemeriksaanDetailResponse {
  final int status;
  final String message;
  final PemeriksaanDetailData data;

  PemeriksaanDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PemeriksaanDetailResponse.fromJson(Map<String, dynamic> json) {
    return PemeriksaanDetailResponse(
      status: json['status'] is int ? json['status'] : int.parse(json['status']),
      message: json['message'].toString(),
      data: PemeriksaanDetailData.fromJson(json['data']),
    );
  }
}

class PemeriksaanDetailData {
  final DataSantriDetail dataSantri;
  final List<DataPemeriksaan> dataPemeriksaan;

  PemeriksaanDetailData({
    required this.dataSantri,
    required this.dataPemeriksaan,
  });

  factory PemeriksaanDetailData.fromJson(Map<String, dynamic> json) {
    var pemeriksaanList = json['dataPemeriksaan'] as List;
    List<DataPemeriksaan> pemeriksaanItems = pemeriksaanList.map((i) => DataPemeriksaan.fromJson(i)).toList();

    return PemeriksaanDetailData(
      dataSantri: DataSantriDetail.fromJson(json['dataSantri']),
      dataPemeriksaan: pemeriksaanItems,
    );
  }
}

class DataSantriDetail {
  final String nama;
  final int noInduk;

  DataSantriDetail({
    required this.nama,
    required this.noInduk,
  });

  factory DataSantriDetail.fromJson(Map<String, dynamic> json) {
    return DataSantriDetail(
      nama: json['nama'].toString(),
      noInduk: json['noInduk'] is int ? json['noInduk'] : int.parse(json['noInduk']),
    );
  }
}

class DataPemeriksaan {
  final int id;
  final int tanggalPemeriksaan;
  final double? tinggiBadan;
  final double? beratBadan;
  final double? lingkarPinggul;
  final double? lingkarDada;
  final String? kondisiGigi;
  final String? tanggalPemeriksaanFormatted;

  DataPemeriksaan({
    required this.id,
    required this.tanggalPemeriksaan,
    this.tinggiBadan,
    this.beratBadan,
    this.lingkarPinggul,
    this.lingkarDada,
    this.kondisiGigi,
    this.tanggalPemeriksaanFormatted,
  });

  factory DataPemeriksaan.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return DataPemeriksaan(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      tanggalPemeriksaan: json['tanggalPemeriksaan'] is int
          ? json['tanggalPemeriksaan']
          : int.tryParse(json['tanggalPemeriksaan'].toString()) ?? 0,
      tinggiBadan: parseDouble(json['tinggiBadan']),
      beratBadan: parseDouble(json['beratBadan']),
      lingkarPinggul: parseDouble(json['lingkarPinggul']),
      lingkarDada: parseDouble(json['lingkarDada']),
      kondisiGigi: json['kondisiGigi']?.toString(),
      tanggalPemeriksaanFormatted: json['tanggalPemeriksaanFormatted']?.toString(),
    );
  }

  DateTime? get tanggalPemeriksaanDate {
    if (tanggalPemeriksaan == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(tanggalPemeriksaan * 1000);
  }
}

class PemeriksaanPostRequest {
  final String noInduk;
  final String tanggalPemeriksaan;
  final int tinggiBadan;
  final int beratBadan;
  final int lingkarPinggul;
  final int lingkarDada;
  final String kondisiGigi;

  PemeriksaanPostRequest({
    required this.noInduk,
    required this.tanggalPemeriksaan,
    required this.tinggiBadan,
    required this.beratBadan,
    required this.lingkarPinggul,
    required this.lingkarDada,
    required this.kondisiGigi,
  });

  Map<String, dynamic> toJson() => {
        'noInduk': noInduk,
        'tanggalPemeriksaan': tanggalPemeriksaan,
        'tinggiBadan': tinggiBadan,
        'beratBadan': beratBadan,
        'lingkarPinggul': lingkarPinggul,
        'lingkarDada': lingkarDada,
        'kondisiGigi': kondisiGigi,
      };
}

class PemeriksaanPostResponse {
  final bool success;
  final String message;
  final dynamic data; 

  PemeriksaanPostResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PemeriksaanPostResponse.fromJson(Map<String, dynamic> json) =>
      PemeriksaanPostResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'],
      );
}