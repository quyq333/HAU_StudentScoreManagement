class SubjectResultModel {
  final int id;
  final String maMonHoc;
  final String tenMonHoc;
  final int soTinChi;
  final double diemChuyenCan;
  final double diemKiemTra;
  final double diemThi;
  final double diemTongKet;
  final String diemChu;

  SubjectResultModel({
    required this.id,
    required this.maMonHoc,
    required this.tenMonHoc,
    required this.soTinChi,
    required this.diemChuyenCan,
    required this.diemKiemTra,
    required this.diemThi,
    required this.diemTongKet,
    required this.diemChu,
  });

  factory SubjectResultModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] ?? {};
    return SubjectResultModel(
      id: json['id'] ?? 0,
      maMonHoc: subject['maMonHoc'] ?? json['maMonHoc'] ?? '',
      tenMonHoc: subject['tenMonHoc'] ?? json['tenMonHoc'] ?? '',
      soTinChi: subject['soTinChi'] ?? json['soTinChi'] ?? 0,
      diemChuyenCan: (json['diemChuyenCan'] ?? 0).toDouble(),
      diemKiemTra: (json['diemKiemTra'] ?? 0).toDouble(),
      diemThi: (json['diemThi'] ?? 0).toDouble(),
      diemTongKet: (json['diemTongKet'] ?? 0).toDouble(),
      diemChu: json['diemChu'] ?? '',
    );
  }
}

class GpaModel {
  final double currentGpa;
  final double cumulativeGpa;
  final int totalCredits;

  GpaModel({
    required this.currentGpa,
    required this.cumulativeGpa,
    required this.totalCredits,
  });

  factory GpaModel.fromJson(Map<String, dynamic> json) {
    return GpaModel(
      currentGpa: (json['currentGpa'] ?? 0).toDouble(),
      cumulativeGpa: (json['cumulativeGpa'] ?? 0).toDouble(),
      totalCredits: json['totalCredits'] ?? 0,
    );
  }
}
