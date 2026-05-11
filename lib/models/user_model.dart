class UserModel {
  final String maSV;
  final String hoTen;
  final String lop;
  final String ngaySinh;
  final String role;

  UserModel({
    required this.maSV,
    required this.hoTen,
    required this.lop,
    required this.ngaySinh,
    this.role = 'ROLE_STUDENT',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      maSV: json['maSV'] ?? '',
      hoTen: json['hoTen'] ?? '',
      lop: json['lop'] ?? '',
      ngaySinh: json['ngaySinh'] ?? '',
      role: json['role'] ?? 'ROLE_STUDENT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maSV': maSV,
      'hoTen': hoTen,
      'lop': lop,
      'ngaySinh': ngaySinh,
      'role': role,
    };
  }
}
