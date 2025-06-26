class Murroby {
  final int idUser;
  final String namaMurroby;
  final String? photo;
  final String accessToken;
  final int expiresIn;

  Murroby({
    required this.idUser,
    required this.namaMurroby,
    this.photo,
    required this.accessToken,
    required this.expiresIn,
  });

  factory Murroby.fromJson(Map<String, dynamic> json) {
    return Murroby(
      idUser: json['id'],
      namaMurroby: json['nama'],
      photo: json['photo'],
      accessToken: json['accesToken'],
      expiresIn: json['expiresIn'],
    );
  }
}
