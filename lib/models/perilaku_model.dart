class PerilakuResponse {
  final int status;
  final String message;
  final DataPerilaku data;

  PerilakuResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PerilakuResponse.fromJson(Map<String, dynamic> json) {
    return PerilakuResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: DataPerilaku.fromJson(json['data'] ?? {}),
    );
  }
}

class DataPerilaku {
  final DataUser dataUser;
  final List<DataSantri> dataSantri;

  DataPerilaku({
    required this.dataUser,
    required this.dataSantri,
  });

  factory DataPerilaku.fromJson(Map<String, dynamic> json) {
    return DataPerilaku(
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
  final String ketertiban;
  final String kedisiplinan;
  final String kerapian;
  final String kesopanan;
  final String kepekaanLingkungan;
  final String ketaatanPeraturan;

  DataSantri({
    required this.noInduk,
    required this.nama,
    required this.tanggal,
    required this.ketertiban,
    required this.kedisiplinan,
    required this.kerapian,
    required this.kesopanan,
    required this.kepekaanLingkungan,
    required this.ketaatanPeraturan,
  });

  factory DataSantri.fromJson(Map<String, dynamic> json) {
    return DataSantri(
      noInduk: json['noInduk'] ?? 0,
      nama: json['nama'] ?? '-',
      tanggal: json['tanggal'] ?? '-',
      ketertiban: json['ketertiban'] ?? '-',
      kedisiplinan: json['kedisiplinan'] ?? '-',
      kerapian: json['kerapian'] ?? '-',
      kesopanan: json['kesopanan'] ?? '-',
      kepekaanLingkungan: json['kepekaanLingkungan'] ?? '-',
      ketaatanPeraturan: json['ketaatanPeraturan'] ?? '-',
    );
  }
}


class DetailPerilakuResponse {
  final int status;
  final String message;
  final DetailPerilakuData data;

  DetailPerilakuResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DetailPerilakuResponse.fromJson(Map<String, dynamic> json) {
    return DetailPerilakuResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: DetailPerilakuData.fromJson(json['data']),
    );
  }
}

class DetailPerilakuData {
  final String namaSantri;
  final List<ItemPerilaku> dataPerilaku;

  DetailPerilakuData({
    required this.namaSantri,
    required this.dataPerilaku,
  });

  factory DetailPerilakuData.fromJson(Map<String, dynamic> json) {
    return DetailPerilakuData(
      namaSantri: json['namaSantri'] ?? '',
      dataPerilaku: (json['dataPerilaku'] as List)
          .map((e) => ItemPerilaku.fromJson(e))
          .toList(),
    );
  }
}

class ItemPerilaku {
  final String tanggal;
  final String ketertiban;
  final String kebersihan;
  final String kedisiplinan;
  final String kerapian;
  final String kesopanan;
  final String kepekaanLingkungan;
  final String ketaatanPeraturan;

  ItemPerilaku({
    required this.tanggal,
    required this.ketertiban,
    required this.kebersihan,
    required this.kedisiplinan,
    required this.kerapian,
    required this.kesopanan,
    required this.kepekaanLingkungan,
    required this.ketaatanPeraturan,
  });

  factory ItemPerilaku.fromJson(Map<String, dynamic> json) {
    return ItemPerilaku(
      tanggal: json['tanggal'] ?? '',
      ketertiban: json['ketertiban'] ?? '-',
      kebersihan: json['kebersihan'] ?? '-',
      kedisiplinan: json['kedisiplinan'] ?? '-',
      kerapian: json['kerapian'] ?? '-',
      kesopanan: json['kesopanan'] ?? '-',
      kepekaanLingkungan: json['kepekaanLingkungan'] ?? '-',
      ketaatanPeraturan: json['ketaatanPeraturan'] ?? '-',
    );
  }
}

