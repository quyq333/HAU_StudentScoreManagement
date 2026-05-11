class SemesterModel {
  final int id;
  final String tenHocKy;
  final String namHoc;

  SemesterModel({
    required this.id,
    required this.tenHocKy,
    required this.namHoc,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      id: json['id'] ?? 0,
      tenHocKy: json['tenHocKy'] ?? '',
      namHoc: json['namHoc'] ?? '',
    );
  }
}
