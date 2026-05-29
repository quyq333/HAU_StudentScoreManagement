class SubjectModel {
  final String maMonHoc;
  final String tenMonHoc;
  final int soTinChi;
  final int idHocKy;
  final String? tenHocKy;
  final String? namHoc;

  SubjectModel({
    required this.maMonHoc,
    required this.tenMonHoc,
    required this.soTinChi,
    required this.idHocKy,
    this.tenHocKy,
    this.namHoc,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    final semester = json['semester'];
    return SubjectModel(
      maMonHoc: json['maMonHoc'] ?? '',
      tenMonHoc: json['tenMonHoc'] ?? '',
      soTinChi: json['soTinChi'] ?? 0,
      idHocKy: semester != null ? semester['id'] : (json['idHocKy'] ?? 0),
      tenHocKy: semester != null ? semester['tenHocKy'] : json['tenHocKy'],
      namHoc: semester != null ? semester['namHoc'] : json['namHoc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maMonHoc': maMonHoc,
      'tenMonHoc': tenMonHoc,
      'soTinChi': soTinChi,
      'idHocKy': idHocKy,
      'tenHocKy': tenHocKy,
      'namHoc': namHoc,
    };
  }
}
