class Santri {
  final String id;
  final String nama;
  final String? kelas; 
  final String noInduk; 

  Santri({
    required this.id,
    required this.nama,
    this.kelas,
    required this.noInduk,
  });

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(
      id: json['id'].toString(),
      nama: json['nama'].toString(),
      kelas: json['kelas']?.toString(),      
      noInduk: json['no_induk']?.toString() ?? '',
    );
  }

}

class SantriResponse {
  final int status;
  final String message;
  final List<Santri> data;

  SantriResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SantriResponse.fromJson(Map<String, dynamic> json) {
    return SantriResponse(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => Santri.fromJson(item))
          .toList(),
    );
  }
}