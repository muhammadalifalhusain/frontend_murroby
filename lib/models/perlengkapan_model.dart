class PerlengkapanModel {
  final int id;
  final String nama;
  final String tanggal;
  final String buku;
  final String bukuLayak;
  final String pensil;
  final String pensilLayak;
  final String bolpoin;
  final String bolpoinLayak;
  final String penghapus;
  final String penghapusLayak;
  final String penyerut;
  final String penyerutLayak;
  final String penggaris;
  final String penggarisLayak;
  final String boxPensil;
  final String boxPensilLayak;
  final String putih;
  final String putihLayak;
  final String batik;
  final String batikLayak;
  final String coklat;
  final String coklatLayak;
  final String kerudung;
  final String kerudungLayak;
  final String peci;
  final String peciLayak;
  final String kaosKaki;
  final String kaosKakiLayak;
  final String sepatu;
  final String sepatuLayak;
  final String ikatPinggang;
  final String ikatPinggangLayak;
  final String mukenah;
  final String mukenahLayak;
  final String alQuran;
  final String alQuranLayak;
  final String jubahPpatq;
  final String jubahPpatqLayak;
  final String bajuHijauStel;
  final String bajuHijauStelLayak;
  final String bajuUnguStel;
  final String bajuUnguStelLayak;
  final String bajuMerahStel;
  final String bajuMerahStelLayak;
  final String kaosHijauStel;
  final String kaosMerahStelLayak;
  final String kaosUnguStel;
  final String kaosUnguStelLayak;
  final String kaosKuningStel;
  final String kaosKuningStelLayak;
  final String sabun;
  final String sabunLayak;
  final String shampo;
  final String shampoLayak;
  final String sikat;
  final String sikatLayak;
  final String pastaGigi;
  final String pastaGigiLayak;
  final String kotakSabun;
  final String kotakSabunLayak;
  final String handuk;
  final String handukLayak;
  final String kasur;
  final String kasurLayak;
  final String bantal;
  final String bantalLayak;
  final String guling;
  final String gulingLayak;
  final String sarungBantal;
  final String sarungBantalLayak;
  final String sarungGuling;
  final String sarungGulingLayak;
  final String sandal;
  final String sandalLayak;
  final String keterangan;
  final String? namaPengisi;

  PerlengkapanModel({
    required this.id,
    required this.nama,
    required this.tanggal,
    required this.buku,
    required this.bukuLayak,
    required this.pensil,
    required this.pensilLayak,
    required this.bolpoin,
    required this.bolpoinLayak,
    required this.penghapus,
    required this.penghapusLayak,
    required this.penyerut,
    required this.penyerutLayak,
    required this.penggaris,
    required this.penggarisLayak,
    required this.boxPensil,
    required this.boxPensilLayak,
    required this.putih,
    required this.putihLayak,
    required this.batik,
    required this.batikLayak,
    required this.coklat,
    required this.coklatLayak,
    required this.kerudung,
    required this.kerudungLayak,
    required this.peci,
    required this.peciLayak,
    required this.kaosKaki,
    required this.kaosKakiLayak,
    required this.sepatu,
    required this.sepatuLayak,
    required this.ikatPinggang,
    required this.ikatPinggangLayak,
    required this.mukenah,
    required this.mukenahLayak,
    required this.alQuran,
    required this.alQuranLayak,
    required this.jubahPpatq,
    required this.jubahPpatqLayak,
    required this.bajuHijauStel,
    required this.bajuHijauStelLayak,
    required this.bajuUnguStel,
    required this.bajuUnguStelLayak,
    required this.bajuMerahStel,
    required this.bajuMerahStelLayak,
    required this.kaosHijauStel,
    required this.kaosMerahStelLayak,
    required this.kaosUnguStel,
    required this.kaosUnguStelLayak,
    required this.kaosKuningStel,
    required this.kaosKuningStelLayak,
    required this.sabun,
    required this.sabunLayak,
    required this.shampo,
    required this.shampoLayak,
    required this.sikat,
    required this.sikatLayak,
    required this.pastaGigi,
    required this.pastaGigiLayak,
    required this.kotakSabun,
    required this.kotakSabunLayak,
    required this.handuk,
    required this.handukLayak,
    required this.kasur,
    required this.kasurLayak,
    required this.bantal,
    required this.bantalLayak,
    required this.guling,
    required this.gulingLayak,
    required this.sarungBantal,
    required this.sarungBantalLayak,
    required this.sarungGuling,
    required this.sarungGulingLayak,
    required this.sandal,
    required this.sandalLayak,
    required this.keterangan,
    required this.namaPengisi,
  });

  factory PerlengkapanModel.fromJson(Map<String, dynamic> json) {
    return PerlengkapanModel(
      id: json['id'],
      nama: json['nama'],
      tanggal: json['tanggal'],
      buku: json['buku'],
      bukuLayak: json['bukuLayak'],
      pensil: json['pensil'],
      pensilLayak: json['pensilLayak'],
      bolpoin: json['bolpoin'],
      bolpoinLayak: json['bolpoinLayak'],
      penghapus: json['penghapus'],
      penghapusLayak: json['penghapusLayak'],
      penyerut: json['penyerut'],
      penyerutLayak: json['penyerutLayak'],
      penggaris: json['penggaris'],
      penggarisLayak: json['penggarisLayak'],
      boxPensil: json['boxPensil'],
      boxPensilLayak: json['boxPensilLayak'],
      putih: json['putih'],
      putihLayak: json['putihLayak'],
      batik: json['batik'],
      batikLayak: json['batikLayak'],
      coklat: json['coklat'],
      coklatLayak: json['coklatLayak'],
      kerudung: json['kerudung'],
      kerudungLayak: json['kerudungLayak'],
      peci: json['peci'],
      peciLayak: json['peciLayak'],
      kaosKaki: json['kaosKaki'],
      kaosKakiLayak: json['kaosKakiLayak'],
      sepatu: json['sepatu'],
      sepatuLayak: json['sepatuLayak'],
      ikatPinggang: json['ikatPinggang'],
      ikatPinggangLayak: json['ikatPinggangLayak'],
      mukenah: json['mukenah'],
      mukenahLayak: json['mukenahLayak'],
      alQuran: json['alQuran'],
      alQuranLayak: json['alQuranLayak'],
      jubahPpatq: json['jubahPpatq'],
      jubahPpatqLayak: json['jubahPpatqLayak'],
      bajuHijauStel: json['bajuHijauStel'],
      bajuHijauStelLayak: json['bajuHijauStelLayak'],
      bajuUnguStel: json['bajuUnguStel'],
      bajuUnguStelLayak: json['bajuUnguStelLayak'],
      bajuMerahStel: json['bajuMerahStel'],
      bajuMerahStelLayak: json['bajuMerahStelLayak'],
      kaosHijauStel: json['kaosHijauStel'],
      kaosMerahStelLayak: json['kaosMerahStelLayak'],
      kaosUnguStel: json['kaosUnguStel'],
      kaosUnguStelLayak: json['kaosUnguStelLayak'],
      kaosKuningStel: json['kaosKuningStel'],
      kaosKuningStelLayak: json['kaosKuningStelLayak'],
      sabun: json['sabun'],
      sabunLayak: json['sabunLayak'],
      shampo: json['shampo'],
      shampoLayak: json['shampoLayak'],
      sikat: json['sikat'],
      sikatLayak: json['sikatLayak'],
      pastaGigi: json['pastaGigi'],
      pastaGigiLayak: json['pastaGigiLayak'],
      kotakSabun: json['kotakSabun'],
      kotakSabunLayak: json['kotakSabunLayak'],
      handuk: json['handuk'],
      handukLayak: json['handukLayak'],
      kasur: json['kasur'],
      kasurLayak: json['kasurLayak'],
      bantal: json['bantal'],
      bantalLayak: json['bantalLayak'],
      guling: json['guling'],
      gulingLayak: json['gulingLayak'],
      sarungBantal: json['sarungBantal'],
      sarungBantalLayak: json['sarungBantalLayak'],
      sarungGuling: json['sarungGuling'],
      sarungGulingLayak: json['sarungGulingLayak'],
      sandal: json['sandal'],
      sandalLayak: json['sandalLayak'],
      keterangan: json['keterangan']?.toString() ?? '',
      namaPengisi: json['namaPengisi']?.toString() ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'tanggal': tanggal,
      'buku': buku,
      'bukuLayak': bukuLayak,
      'pensil': pensil,
      'pensilLayak': pensilLayak,
      'bolpoin': bolpoin,
      'bolpoinLayak': bolpoinLayak,
      'penghapus': penghapus,
      'penghapusLayak': penghapusLayak,
      'penyerut': penyerut,
      'penyerutLayak': penyerutLayak,
      'penggaris': penggaris,
      'penggarisLayak': penggarisLayak,
      'boxPensil': boxPensil,
      'boxPensilLayak': boxPensilLayak,
      'putih': putih,
      'putihLayak': putihLayak,
      'batik': batik,
      'batikLayak': batikLayak,
      'coklat': coklat,
      'coklatLayak': coklatLayak,
      'kerudung': kerudung,
      'kerudungLayak': kerudungLayak,
      'peci': peci,
      'peciLayak': peciLayak,
      'kaosKaki': kaosKaki,
      'kaosKakiLayak': kaosKakiLayak,
      'sepatu': sepatu,
      'sepatuLayak': sepatuLayak,
      'ikatPinggang': ikatPinggang,
      'ikatPinggangLayak': ikatPinggangLayak,
      'mukenah': mukenah,
      'mukenahLayak': mukenahLayak,
      'alQuran': alQuran,
      'alQuranLayak': alQuranLayak,
      'jubahPpatq': jubahPpatq,
      'jubahPpatqLayak': jubahPpatqLayak,
      'bajuHijauStel': bajuHijauStel,
      'bajuHijauStelLayak': bajuHijauStelLayak,
      'bajuUnguStel': bajuUnguStel,
      'bajuUnguStelLayak': bajuUnguStelLayak,
      'bajuMerahStel': bajuMerahStel,
      'bajuMerahStelLayak': bajuMerahStelLayak,
      'kaosHijauStel': kaosHijauStel,
      'kaosMerahStelLayak': kaosMerahStelLayak,
      'kaosUnguStel': kaosUnguStel,
      'kaosUnguStelLayak': kaosUnguStelLayak,
      'kaosKuningStel': kaosKuningStel,
      'kaosKuningStelLayak': kaosKuningStelLayak,
      'sabun': sabun,
      'sabunLayak': sabunLayak,
      'shampo': shampo,
      'shampoLayak': shampoLayak,
      'sikat': sikat,
      'sikatLayak': sikatLayak,
      'pastaGigi': pastaGigi,
      'pastaGigiLayak': pastaGigiLayak,
      'kotakSabun': kotakSabun,
      'kotakSabunLayak': kotakSabunLayak,
      'handuk': handuk,
      'handukLayak': handukLayak,
      'kasur': kasur,
      'kasurLayak': kasurLayak,
      'bantal': bantal,
      'bantalLayak': bantalLayak,
      'guling': guling,
      'gulingLayak': gulingLayak,
      'sarungBantal': sarungBantal,
      'sarungBantalLayak': sarungBantalLayak,
      'sarungGuling': sarungGuling,
      'sarungGulingLayak': sarungGulingLayak,
      'sandal': sandal,
      'sandalLayak': sandalLayak,
      'keterangan': keterangan,
      'namaPengisi': namaPengisi,
    };
  }
}
class EditPerlengkapanModel {
  final int id;
  final String noInduk;
  final String tanggal;
  final String buku;
  final String bukuLayak;
  final String pensil;
  final String pensilLayak;
  final String bolpoin;
  final String bolpoinLayak;
  final String penghapus;
  final String penghapusLayak;
  final String penyerut;
  final String penyerutLayak;
  final String penggaris;
  final String penggarisLayak;
  final String boxPensil;
  final String boxPensilLayak;
  final String putih;
  final String putihLayak;
  final String batik;
  final String batikLayak;
  final String coklat;
  final String coklatLayak;
  final String kerudung;
  final String kerudungLayak;
  final String peci;
  final String peciLayak;
  final String kaosKaki;
  final String kaosKakiLayak;
  final String sepatu;
  final String sepatuLayak;
  final String ikatPinggang;
  final String ikatPinggangLayak;
  final String mukenah;
  final String mukenahLayak;
  final String alQuran;
  final String alQuranLayak;
  final String jubahPpatq;
  final String jubahPpatqLayak;
  final String bajuHijauStel;
  final String bajuHijauStelLayak;
  final String bajuUnguStel;
  final String bajuUnguStelLayak;
  final String bajuMerahStel;
  final String bajuMerahStelLayak;
  final String kaosHijauStel;
  final String kaosMerahStelLayak;
  final String kaosUnguStel;
  final String kaosUnguStelLayak;
  final String kaosKuningStel;
  final String kaosKuningStelLayak;
  final String sabun;
  final String sabunLayak;
  final String shampo;
  final String shampoLayak;
  final String sikat;
  final String sikatLayak;
  final String pastaGigi;
  final String pastaGigiLayak;
  final String kotakSabun;
  final String kotakSabunLayak;
  final String handuk;
  final String handukLayak;
  final String kasur;
  final String kasurLayak;
  final String bantal;
  final String bantalLayak;
  final String guling;
  final String gulingLayak;
  final String sarungBantal;
  final String sarungBantalLayak;
  final String sarungGuling;
  final String sarungGulingLayak;
  final String sandal;
  final String sandalLayak;
  final String keterangan;
  final String? namaPengisi;

  EditPerlengkapanModel({
    required this.id,
    required this.noInduk,
    required this.tanggal,
    required this.buku,
    required this.bukuLayak,
    required this.pensil,
    required this.pensilLayak,
    required this.bolpoin,
    required this.bolpoinLayak,
    required this.penghapus,
    required this.penghapusLayak,
    required this.penyerut,
    required this.penyerutLayak,
    required this.penggaris,
    required this.penggarisLayak,
    required this.boxPensil,
    required this.boxPensilLayak,
    required this.putih,
    required this.putihLayak,
    required this.batik,
    required this.batikLayak,
    required this.coklat,
    required this.coklatLayak,
    required this.kerudung,
    required this.kerudungLayak,
    required this.peci,
    required this.peciLayak,
    required this.kaosKaki,
    required this.kaosKakiLayak,
    required this.sepatu,
    required this.sepatuLayak,
    required this.ikatPinggang,
    required this.ikatPinggangLayak,
    required this.mukenah,
    required this.mukenahLayak,
    required this.alQuran,
    required this.alQuranLayak,
    required this.jubahPpatq,
    required this.jubahPpatqLayak,
    required this.bajuHijauStel,
    required this.bajuHijauStelLayak,
    required this.bajuUnguStel,
    required this.bajuUnguStelLayak,
    required this.bajuMerahStel,
    required this.bajuMerahStelLayak,
    required this.kaosHijauStel,
    required this.kaosMerahStelLayak,
    required this.kaosUnguStel,
    required this.kaosUnguStelLayak,
    required this.kaosKuningStel,
    required this.kaosKuningStelLayak,
    required this.sabun,
    required this.sabunLayak,
    required this.shampo,
    required this.shampoLayak,
    required this.sikat,
    required this.sikatLayak,
    required this.pastaGigi,
    required this.pastaGigiLayak,
    required this.kotakSabun,
    required this.kotakSabunLayak,
    required this.handuk,
    required this.handukLayak,
    required this.kasur,
    required this.kasurLayak,
    required this.bantal,
    required this.bantalLayak,
    required this.guling,
    required this.gulingLayak,
    required this.sarungBantal,
    required this.sarungBantalLayak,
    required this.sarungGuling,
    required this.sarungGulingLayak,
    required this.sandal,
    required this.sandalLayak,
    required this.keterangan,
    required this.namaPengisi,
  });

  factory EditPerlengkapanModel.fromJson(Map<String, dynamic> json) {
    return EditPerlengkapanModel(
      id: json['id'],
      noInduk: json['noInduk'],
      tanggal: json['tanggal'],
      buku: json['buku'],
      bukuLayak: json['bukuLayak'],
      pensil: json['pensil'],
      pensilLayak: json['pensilLayak'],
      bolpoin: json['bolpoin'],
      bolpoinLayak: json['bolpoinLayak'],
      penghapus: json['penghapus'],
      penghapusLayak: json['penghapusLayak'],
      penyerut: json['penyerut'],
      penyerutLayak: json['penyerutLayak'],
      penggaris: json['penggaris'],
      penggarisLayak: json['penggarisLayak'],
      boxPensil: json['boxPensil'],
      boxPensilLayak: json['boxPensilLayak'],
      putih: json['putih'],
      putihLayak: json['putihLayak'],
      batik: json['batik'],
      batikLayak: json['batikLayak'],
      coklat: json['coklat'],
      coklatLayak: json['coklatLayak'],
      kerudung: json['kerudung'],
      kerudungLayak: json['kerudungLayak'],
      peci: json['peci'],
      peciLayak: json['peciLayak'],
      kaosKaki: json['kaosKaki'],
      kaosKakiLayak: json['kaosKakiLayak'],
      sepatu: json['sepatu'],
      sepatuLayak: json['sepatuLayak'],
      ikatPinggang: json['ikatPinggang'],
      ikatPinggangLayak: json['ikatPinggangLayak'],
      mukenah: json['mukenah'],
      mukenahLayak: json['mukenahLayak'],
      alQuran: json['alQuran'],
      alQuranLayak: json['alQuranLayak'],
      jubahPpatq: json['jubahPpatq'],
      jubahPpatqLayak: json['jubahPpatqLayak'],
      bajuHijauStel: json['bajuHijauStel'],
      bajuHijauStelLayak: json['bajuHijauStelLayak'],
      bajuUnguStel: json['bajuUnguStel'],
      bajuUnguStelLayak: json['bajuUnguStelLayak'],
      bajuMerahStel: json['bajuMerahStel'],
      bajuMerahStelLayak: json['bajuMerahStelLayak'],
      kaosHijauStel: json['kaosHijauStel'],
      kaosMerahStelLayak: json['kaosMerahStelLayak'],
      kaosUnguStel: json['kaosUnguStel'],
      kaosUnguStelLayak: json['kaosUnguStelLayak'],
      kaosKuningStel: json['kaosKuningStel'],
      kaosKuningStelLayak: json['kaosKuningStelLayak'],
      sabun: json['sabun'],
      sabunLayak: json['sabunLayak'],
      shampo: json['shampo'],
      shampoLayak: json['shampoLayak'],
      sikat: json['sikat'],
      sikatLayak: json['sikatLayak'],
      pastaGigi: json['pastaGigi'],
      pastaGigiLayak: json['pastaGigiLayak'],
      kotakSabun: json['kotakSabun'],
      kotakSabunLayak: json['kotakSabunLayak'],
      handuk: json['handuk'],
      handukLayak: json['handukLayak'],
      kasur: json['kasur'],
      kasurLayak: json['kasurLayak'],
      bantal: json['bantal'],
      bantalLayak: json['bantalLayak'],
      guling: json['guling'],
      gulingLayak: json['gulingLayak'],
      sarungBantal: json['sarungBantal'],
      sarungBantalLayak: json['sarungBantalLayak'],
      sarungGuling: json['sarungGuling'],
      sarungGulingLayak: json['sarungGulingLayak'],
      sandal: json['sandal'],
      sandalLayak: json['sandalLayak'],
      keterangan: json['keterangan'],
      namaPengisi: json['namaPengisi'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noInduk': noInduk,
      'tanggal': tanggal,
      'buku': buku,
      'bukuLayak': bukuLayak,
      'pensil': pensil,
      'pensilLayak': pensilLayak,
      'bolpoin': bolpoin,
      'bolpoinLayak': bolpoinLayak,
      'penghapus': penghapus,
      'penghapusLayak': penghapusLayak,
      'penyerut': penyerut,
      'penyerutLayak': penyerutLayak,
      'penggaris': penggaris,
      'penggarisLayak': penggarisLayak,
      'boxPensil': boxPensil,
      'boxPensilLayak': boxPensilLayak,
      'putih': putih,
      'putihLayak': putihLayak,
      'batik': batik,
      'batikLayak': batikLayak,
      'coklat': coklat,
      'coklatLayak': coklatLayak,
      'kerudung': kerudung,
      'kerudungLayak': kerudungLayak,
      'peci': peci,
      'peciLayak': peciLayak,
      'kaosKaki': kaosKaki,
      'kaosKakiLayak': kaosKakiLayak,
      'sepatu': sepatu,
      'sepatuLayak': sepatuLayak,
      'ikatPinggang': ikatPinggang,
      'ikatPinggangLayak': ikatPinggangLayak,
      'mukenah': mukenah,
      'mukenahLayak': mukenahLayak,
      'alQuran': alQuran,
      'alQuranLayak': alQuranLayak,
      'jubahPpatq': jubahPpatq,
      'jubahPpatqLayak': jubahPpatqLayak,
      'bajuHijauStel': bajuHijauStel,
      'bajuHijauStelLayak': bajuHijauStelLayak,
      'bajuUnguStel': bajuUnguStel,
      'bajuUnguStelLayak': bajuUnguStelLayak,
      'bajuMerahStel': bajuMerahStel,
      'bajuMerahStelLayak': bajuMerahStelLayak,
      'kaosHijauStel': kaosHijauStel,
      'kaosMerahStelLayak': kaosMerahStelLayak,
      'kaosUnguStel': kaosUnguStel,
      'kaosUnguStelLayak': kaosUnguStelLayak,
      'kaosKuningStel': kaosKuningStel,
      'kaosKuningStelLayak': kaosKuningStelLayak,
      'sabun': sabun,
      'sabunLayak': sabunLayak,
      'shampo': shampo,
      'shampoLayak': shampoLayak,
      'sikat': sikat,
      'sikatLayak': sikatLayak,
      'pastaGigi': pastaGigi,
      'pastaGigiLayak': pastaGigiLayak,
      'kotakSabun': kotakSabun,
      'kotakSabunLayak': kotakSabunLayak,
      'handuk': handuk,
      'handukLayak': handukLayak,
      'kasur': kasur,
      'kasurLayak': kasurLayak,
      'bantal': bantal,
      'bantalLayak': bantalLayak,
      'guling': guling,
      'gulingLayak': gulingLayak,
      'sarungBantal': sarungBantal,
      'sarungBantalLayak': sarungBantalLayak,
      'sarungGuling': sarungGuling,
      'sarungGulingLayak': sarungGulingLayak,
      'sandal': sandal,
      'sandalLayak': sandalLayak,
      'keterangan': keterangan,
      'namaPengisi': namaPengisi,
    };
  }
}

class PostPerlengkapanRequest {
  final String noInduk;
  final String tanggal;
  final Map<String, dynamic> items;
  final String keterangan;
  final String namaPengisi;

  PostPerlengkapanRequest({
    required this.noInduk,
    required this.tanggal,
    required this.items,
    required this.keterangan,
    required this.namaPengisi,
  });

  Map<String, dynamic> toJson() {
    return {
      "noInduk": noInduk,
      "tanggal": tanggal,
      ...items, 
      "keterangan": keterangan,
      "nama_pengisi": namaPengisi,
    };
  }
}
