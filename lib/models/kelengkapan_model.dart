class KelengkapanResponse {
  final int status;
  final String message;
  final DataKelengkapan data;

  KelengkapanResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory KelengkapanResponse.fromJson(Map<String, dynamic> json) {
    return KelengkapanResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: DataKelengkapan.fromJson(json['data'] ?? {}),
    );
  }
}

class DataKelengkapan {
  final DataUser dataUser;
  final List<DataSantri> dataSantri;

  DataKelengkapan({
    required this.dataUser,
    required this.dataSantri,
  });

  factory DataKelengkapan.fromJson(Map<String, dynamic> json) {
    return DataKelengkapan(
      dataUser: DataUser.fromJson(json['dataUser'] ?? {}),
      dataSantri: (json['dataSantri'] as List<dynamic>?)
              ?.map((x) => DataSantri.fromJson(x))
              .toList() ??
          [],
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
      namaMurroby: json['namaMurroby'] ?? '-',
      fotoMurroby: json['fotoMurroby'] ?? '',
      kodeKamar: json['kodeKamar'] ?? '-',
      idKamar: json['idKamar'] ?? 0,
    );
  }
}

class DataSantri {
  final int noInduk;
  final String nama;
  final String tanggal;
  final String perlengkapanMandi;
  final String peralatanSekolah;
  final String perlengkapanDiri;
  DataSantri({
    required this.noInduk,
    required this.nama,
    required this.tanggal,
    required this.perlengkapanMandi,
    required this.peralatanSekolah,
    required this.perlengkapanDiri,
  });

  factory DataSantri.fromJson(Map<String, dynamic> json) {
    return DataSantri(
      noInduk: json['noInduk'] ?? 0,
      nama: json['nama'] ?? '-',
      tanggal: json['tanggal'] ?? '-',
      perlengkapanMandi: json['perlengkapanMandi'] ?? '-',
      peralatanSekolah: json['peralatanSekolah'] ?? '-',
      perlengkapanDiri: json['perlengkapanDiri'] ?? '-',
    );
  }
}

class DetailKelengkapanResponse {
  final int status;
  final String message;
  final DetailKelengkapanData data;

  DetailKelengkapanResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DetailKelengkapanResponse.fromJson(Map<String, dynamic> json) {
    return DetailKelengkapanResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: DetailKelengkapanData.fromJson(json['data'] ?? {}),
    );
  }
}

class DetailKelengkapanData {
  final String namaSantri;
  final int noInduk;
  final List<ItemKelengkapan> dataKelengkapan;

  DetailKelengkapanData({
    required this.namaSantri,
    required this.noInduk,
    required this.dataKelengkapan,
  });

  factory DetailKelengkapanData.fromJson(Map<String, dynamic> json) {
    return DetailKelengkapanData(
      namaSantri: json['namaSantri'] ?? '-',
      noInduk: json['noInduk'] ?? 0,
      dataKelengkapan: (json['dataKelengkapan'] as List<dynamic>?)
              ?.map((e) => ItemKelengkapan.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ItemKelengkapan {
  final int id;
  final String tanggal;
  final String perlengkapanMandi;
  final String catatanMandi;
  final String peralatanSekolah;
  final String catatanSekolah;
  final String perlengkapanDiri;
  final String catatanDiri;

  ItemKelengkapan({
    required this.id,
    required this.tanggal,
    required this.perlengkapanMandi,
    required this.catatanMandi,
    required this.peralatanSekolah,
    required this.catatanSekolah,
    required this.perlengkapanDiri,
    required this.catatanDiri,
  });

  factory ItemKelengkapan.fromJson(Map<String, dynamic> json) {
    return ItemKelengkapan(
      id: json['id'] ?? 0,
      tanggal: json['tanggal'] ?? '-',
      perlengkapanMandi: json['perlengkapanMandi'] ?? '-',
      catatanMandi: json['catatanMandi'] ?? '-',
      peralatanSekolah: json['peralatanSekolah'] ?? '-',
      catatanSekolah: json['catatanSekolah'] ?? '-',
      perlengkapanDiri: json['perlengkapanDiri'] ?? '-',
      catatanDiri: json['catatanDiri'] ?? '-',
    );
  }
}

class PostKelengkapanRequest {
  final int noInduk;
  final String tanggal;
  final int perlengkapanMandi;
  final String catatanMandi;
  final int peralatanSekolah;
  final String catatanSekolah;
  final int perlengkapanDiri;
  final String catatanDiri;

  PostKelengkapanRequest({
    required this.noInduk,
    required this.tanggal,
    required this.perlengkapanMandi,
    required this.catatanMandi,
    required this.peralatanSekolah,
    required this.catatanSekolah,
    required this.perlengkapanDiri,
    required this.catatanDiri,
  });

  Map<String, dynamic> toJson() {
    return {
      'noInduk': noInduk,
      'tanggal': tanggal,
      'perlengkapanMandi': perlengkapanMandi,
      'catatanMandi': catatanMandi,
      'peralatanSekolah': peralatanSekolah,
      'catatanSekolah': catatanSekolah,
      'perlengkapanDiri': perlengkapanDiri,
      'catatanDiri': catatanDiri,
    };
  }
}


