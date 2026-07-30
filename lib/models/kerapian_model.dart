class KerapianResponse {
  final int status;
  final String message;
  final List<KerapianItem> data;

  KerapianResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory KerapianResponse.fromJson(Map<String, dynamic> json) {
    return KerapianResponse(
      status: json['status'] is int ? json['status'] : 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => KerapianItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
class KerapianItem {
  final int? id;
  final String? tanggal;
  final String? nama;
  final String? sandal;
  final String? sepatu;
  final String? boxJajan;
  final String? alatMandi;
  final String? tindakLanjut;
  final String? namaPengisi;

  KerapianItem({
    this.id,
    this.tanggal,
    this.nama,
    this.sandal,
    this.sepatu,
    this.boxJajan,
    this.alatMandi,
    this.tindakLanjut,
    this.namaPengisi,
  });

  factory KerapianItem.fromJson(Map<String, dynamic> json) {
    return KerapianItem(
      id: json['id'],
      tanggal: json['tanggal'],
      nama: json['nama'],
      sandal: json['sandal'],
      sepatu: json['sepatu'],
      boxJajan: json['boxJajan'],
      alatMandi: json['alatMandi'],
      tindakLanjut: json['tindakLanjut'],
      namaPengisi: json['namaPengisi'],
    );
  }
}

class KerapianDetail {
  final int id;
  final int noInduk;
  final String? tanggal;
  final int sandal;
  final int sepatu;
  final int boxJajan;
  final int alatMandi;
  final String? tindakLanjut;

  KerapianDetail({
    required this.id,
    required this.noInduk,
    required this.tanggal,
    required this.sandal,
    required this.sepatu,
    required this.boxJajan,
    required this.alatMandi,
    required this.tindakLanjut,
  });

  factory KerapianDetail.fromJson(Map<String, dynamic> json) {
    return KerapianDetail(
      id: json['id'],
      noInduk: json['noInduk'],
      tanggal: json['tanggal'],
      sandal: json['sandal'],
      sepatu: json['sepatu'],
      boxJajan: json['boxJajan'],
      alatMandi: json['alatMandi'],
      tindakLanjut: json['tindakLanjut'],
    );
  }
}


class PostKerapianRequest {
  final String noInduk;
  final String tanggal;
  final int sandal;
  final int sepatu;
  final int boxJajan;
  final int alatMandi;
  final String tindakLanjut;

  PostKerapianRequest({
    required this.noInduk,
    required this.tanggal,
    required this.sandal,
    required this.sepatu,
    required this.boxJajan,
    required this.alatMandi,
    required this.tindakLanjut,
  });

  Map<String, dynamic> toJson() {
    return {
      'noInduk': noInduk,
      'tanggal': tanggal,
      'sandal': sandal,
      'sepatu': sepatu,
      'boxJajan': boxJajan,
      'alatMandi': alatMandi,
      'tindakLanjut': tindakLanjut,
    };
  }
}

