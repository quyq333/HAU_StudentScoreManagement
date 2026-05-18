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
  final double diemHe4;

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
    required this.diemHe4,
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
      diemHe4: (json['diemHe4'] ?? 0).toDouble(),
    );
  }
}

class GpaModel {
  final double currentGpa;
  final double cumulativeGpa;
  final int totalCredits;
  final List<SemesterGpaModel> semesterGpas;

  GpaModel({
    required this.currentGpa,
    required this.cumulativeGpa,
    required this.totalCredits,
    required this.semesterGpas,
  });

  factory GpaModel.fromJson(Map<String, dynamic> json) {
    var list = json['semesterGpas'] as List? ?? [];
    List<SemesterGpaModel> semesterGpasList = list.map((i) => SemesterGpaModel.fromJson(i)).toList();

    return GpaModel(
      currentGpa: (json['currentGpa'] ?? 0).toDouble(),
      cumulativeGpa: (json['cumulativeGpa'] ?? 0).toDouble(),
      totalCredits: json['totalCredits'] ?? 0,
      semesterGpas: semesterGpasList,
    );
  }
}

class SemesterGpaModel {
  final String semesterName;
  final double gpa;

  SemesterGpaModel({
    required this.semesterName,
    required this.gpa,
  });

  factory SemesterGpaModel.fromJson(Map<String, dynamic> json) {
    return SemesterGpaModel(
      semesterName: json['semesterName'] ?? '',
      gpa: (json['gpa'] ?? 0).toDouble(),
    );
  }
}
