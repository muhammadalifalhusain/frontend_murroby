class SantriUangSaku {
  final int noIndukSantri;
  final String namaSantri;
  final int jumlahSaldo;

  SantriUangSaku({
    required this.noIndukSantri,
    required this.namaSantri,
    required this.jumlahSaldo,
  });

  factory SantriUangSaku.fromJson(Map<String, dynamic> json) {
    return SantriUangSaku(
      noIndukSantri: json['noIndukSantri'] ?? 0,
      namaSantri: json['namaSantri'] ?? '',
      jumlahSaldo: json['jumlahSaldo'] ?? 0,
    );
  }
}



class MurrobyData {
  final String nama;
  final String foto;
  final String kodeKamar;

  MurrobyData({
    required this.nama,
    required this.foto,
    required this.kodeKamar,
  });

  factory MurrobyData.fromJson(Map<String, dynamic> json) {
    return MurrobyData(
      nama: json['namaMurroby'] ?? '',
      foto: json['fotoMurroby'] ?? '',
      kodeKamar: json['kodeKamar'] ?? '',
    );
  }
}

