class Classroom {
  final int id;
  final String tenPhong;
  final String? toaNha;
  final int? sucChua;
  final String? loaiPhong;

  Classroom({
    required this.id,
    required this.tenPhong,
    this.toaNha,
    this.sucChua,
    this.loaiPhong,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'],
      tenPhong: json['tenPhong'] ?? '',
      toaNha: json['toaNha'],
      sucChua: json['sucChua'],
      loaiPhong: json['loaiPhong'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenPhong': tenPhong,
      'toaNha': toaNha,
      'sucChua': sucChua,
      'loaiPhong': loaiPhong,
    };
  }
}
