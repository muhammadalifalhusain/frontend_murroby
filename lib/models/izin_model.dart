class Izin {
  final int id;
  final String nama;
  final String tanggal;
  final String keluar;
  final String kembali;
  final String status;
  final String kategori;
  final String kategoriPelanggaran;
  final String namaPengisi;

  Izin({
    required this.id,
    required this.nama,
    required this.tanggal,
    required this.keluar,
    required this.kembali,
    required this.status,
    required this.kategori,
    required this.kategoriPelanggaran,
    required this.namaPengisi,
  });

  factory Izin.fromJson(Map<String, dynamic> json) {
    return Izin(
      id: json['id'],
      nama: json['nama'] ?? '-',
      tanggal: json['tanggal'] ?? '-',
      keluar: json['keluar'] ?? '-',
      kembali: json['kembali'] ?? '-',
      status: json['status'] ?? '-',
      kategori: json['kategori'] ?? '-',
      kategoriPelanggaran: json['kategoriPelanggaran'] ?? '-',
      namaPengisi: json['namaPengisi'] ?? '-',
    );
  }
}

class IzinResponse {
  final int status;
  final String message;
  final List<Izin> data;

  IzinResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory IzinResponse.fromJson(Map<String, dynamic> json) {
    return IzinResponse(
      status: json['status'],
      message: json['message'],
      data: List<Izin>.from(json['data'].map((x) => Izin.fromJson(x))),
    );
  }
}

class IzinRequest {
  final String noInduk;
  final String tanggal;
  final String keluar;
  final String kembali;
  final int status;
  final int kategori;

  IzinRequest({
    required this.noInduk,
    required this.tanggal,
    required this.keluar,
    required this.kembali,
    required this.status,
    required this.kategori,
  });

  Map<String, dynamic> toJson() {
    final keluarFull = '$tanggal $keluar:00';
    final kembaliFull = '$tanggal $kembali:00';
    return {
      'noInduk': noInduk,
      'tanggal': tanggal,
      'keluar': keluarFull,
      'kembali': kembaliFull,
      'status': status,
      'kategori': kategori,
    };
  }
}

