class Pelanggaran {
  final int id;
  final String nama;
  final String tanggal;
  final String jenisPelanggaran;
  final String kategori;
  final String hukuman;
  final String? bukti;
  final String namaPengisi;

  Pelanggaran({
    required this.id,
    required this.nama,
    required this.tanggal,
    required this.jenisPelanggaran,
    required this.kategori,
    required this.hukuman,
    this.bukti,
    required this.namaPengisi,
  });

  factory Pelanggaran.fromJson(Map<String, dynamic> json) {
    return Pelanggaran(
      id: json['id'],
      nama: json['nama'],
      tanggal: json['tanggal'],
      jenisPelanggaran: json['jenisPelanggaran'],
      kategori: json['kategori'],
      hukuman: json['hukuman'],
      bukti: json['bukti'],
      namaPengisi: json['namaPengisi'],
    );
  }
}

class PelanggaranRequest {
  final String noInduk;
  final String tanggal;
  final String jenis;
  final String kategori;
  final String hukuman;
  final String? buktiPath;

  PelanggaranRequest({
    required this.noInduk,
    required this.tanggal,
    required this.jenis,
    required this.kategori,
    required this.hukuman,
    this.buktiPath,
  });
}
