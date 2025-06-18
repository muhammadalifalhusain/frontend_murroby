// user_data_model.dart
class UserDataResponse {
  final int status;
  final String message;
  final UserData data;

  UserDataResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserDataResponse.fromJson(Map<String, dynamic> json) {
    return UserDataResponse(
      status: json['status'],
      message: json['message'],
      data: UserData.fromJson(json['data']),
    );
  }
}

class UserData {
  final DataUser dataUser;
  final List<Santri> listSantri;

  UserData({
    required this.dataUser,
    required this.listSantri,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    var santriList = json['listSantri'] as List;
    List<Santri> santris = santriList.map((i) => Santri.fromJson(i)).toList();

    return UserData(
      dataUser: DataUser.fromJson(json['dataUser']),
      listSantri: santris,
    );
  }
}

class DataUser {
  final int idPegawai;
  final String namaMurroby;
  final String fotoMurroby;
  final String alamatMurroby;
  final String kodeKamar;

  DataUser({
    required this.idPegawai,
    required this.namaMurroby,
    required this.fotoMurroby,
    required this.alamatMurroby,
    required this.kodeKamar,
  });

  factory DataUser.fromJson(Map<String, dynamic> json) {
    return DataUser(
      idPegawai: json['idPegawai'] ?? 0,
      namaMurroby: json['namaMurroby'] ?? '',
      fotoMurroby: json['fotoMurroby'] ?? '', // ← tambahkan default di sini
      alamatMurroby: json['alamatMurroby'] ?? '',
      kodeKamar: json['kodeKamar'] ?? '',
    );
  }
}


class Santri {
  final int noIndukSantri;
  final String namaSantri;
  final String kelasSantri;
  final String noHpSantri;
  final String alamatLengkap;

  Santri({
    required this.noIndukSantri,
    required this.namaSantri,
    required this.kelasSantri,
    required this.noHpSantri,
    required this.alamatLengkap,
  });

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(
      noIndukSantri: json['noIndukSantri'] ?? 0,
      namaSantri: json['namaSantri'] ?? '',
      kelasSantri: json['kelasSantri'] ?? '',
      noHpSantri: json['noHpSantri'] ?? '', // ← FIX DI SINI
      alamatLengkap: json['alamatLengkap'] ?? '',
    );
  }
}
