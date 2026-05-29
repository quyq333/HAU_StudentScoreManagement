import 'classroom_model.dart';
import 'subject_model.dart';

class ExamSchedule {
  final int id;
  final SubjectModel? subject;
  final Classroom? classroom;
  final DateTime? ngayThi;
  final String? caThi;
  final String? ghiChu;
  final List<dynamic> registrations;

  ExamSchedule({
    required this.id,
    this.subject,
    this.classroom,
    this.ngayThi,
    this.caThi,
    this.ghiChu,
    required this.registrations,
  });

  factory ExamSchedule.fromJson(Map<String, dynamic> json) {
    return ExamSchedule(
      id: json['id'] ?? 0,
      subject: json['subject'] != null
          ? SubjectModel.fromJson(json['subject'])
          : null,
      classroom: json['classroom'] != null
          ? Classroom.fromJson(json['classroom'])
          : null,
      ngayThi: json['ngayThi'] != null ? DateTime.parse(json['ngayThi']) : null,
      caThi: json['caThi'],
      ghiChu: json['ghiChu'],
      registrations: json['registrations'] ?? [],
    );
  }
}
