class LecturerModel {
  final String maGV;
  final String hoTen;
  final String? email;
  final String? soDienThoai;
  final String? khoa;

  LecturerModel({
    required this.maGV,
    required this.hoTen,
    this.email,
    this.soDienThoai,
    this.khoa,
  });

  factory LecturerModel.fromJson(Map<String, dynamic> json) {
    return LecturerModel(
      maGV: json['maGV'] ?? '',
      hoTen: json['hoTen'] ?? '',
      email: json['email'],
      soDienThoai: json['soDienThoai'],
      khoa: json['khoa'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maGV': maGV,
      'hoTen': hoTen,
      'email': email,
      'soDienThoai': soDienThoai,
      'khoa': khoa,
    };
  }
}
