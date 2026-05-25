import 'subject_model.dart';

class StudyMaterial {
  final int id;
  final SubjectModel? subject;
  final String tenTaiLieu;
  final String? loaiTaiLieu;
  final String? duongDan;
  final String? ngayTaiLen;

  StudyMaterial({
    required this.id,
    this.subject,
    required this.tenTaiLieu,
    this.loaiTaiLieu,
    this.duongDan,
    this.ngayTaiLen,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    return StudyMaterial(
      id: json['id'],
      subject: json['subject'] != null ? SubjectModel.fromJson(json['subject']) : null,
      tenTaiLieu: json['tenTaiLieu'] ?? '',
      loaiTaiLieu: json['loaiTaiLieu'],
      duongDan: json['duongDan'],
      ngayTaiLen: json['ngayTaiLen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject?.toJson(),
      'tenTaiLieu': tenTaiLieu,
      'loaiTaiLieu': loaiTaiLieu,
      'duongDan': duongDan,
      'ngayTaiLen': ngayTaiLen,
    };
  }
}
