class Murroby {
  final int idUser;
  final String namaMurroby;
  final String? photo;

  Murroby({
    required this.idUser,
    required this.namaMurroby,
    this.photo,
  });

  factory Murroby.fromJson(Map<String, dynamic> json) {
    return Murroby(
      idUser: json['idUser'],
      namaMurroby: json['namaMurroby'],
      photo: json['photo'],
    );
  }
}
