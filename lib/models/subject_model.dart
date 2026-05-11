class SubjectModel {
  final String maMonHoc;
  final String tenMonHoc;
  final int soTinChi;
  final int idHocKy;

  SubjectModel({
    required this.maMonHoc,
    required this.tenMonHoc,
    required this.soTinChi,
    required this.idHocKy,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      maMonHoc: json['maMonHoc'] ?? '',
      tenMonHoc: json['tenMonHoc'] ?? '',
      soTinChi: json['soTinChi'] ?? 0,
      idHocKy: json['semester'] != null ? json['semester']['id'] : (json['idHocKy'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maMonHoc': maMonHoc,
      'tenMonHoc': tenMonHoc,
      'soTinChi': soTinChi,
      'idHocKy': idHocKy,
    };
  }
}
