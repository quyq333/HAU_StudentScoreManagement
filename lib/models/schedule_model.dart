import 'subject_model.dart';
import 'classroom_model.dart';
import 'lecturer_model.dart';

class Schedule {
  final int id;
  final SubjectModel? subject;
  final Classroom? classroom;
  final String? thuTrongTuan;
  final String? caHoc;
  final LecturerModel? lecturer;
  final bool isConfirmed;
  final List<dynamic> registrations;
  final DateTime? ngayBatDau;
  final DateTime? ngayKetThuc;

  Schedule({
    required this.id,
    this.subject,
    this.classroom,
    this.thuTrongTuan,
    this.caHoc,
    this.lecturer,
    required this.isConfirmed,
    required this.registrations,
    this.ngayBatDau,
    this.ngayKetThuc,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      subject: json['subject'] != null ? SubjectModel.fromJson(json['subject']) : null,
      classroom: json['classroom'] != null ? Classroom.fromJson(json['classroom']) : null,
      thuTrongTuan: json['thuTrongTuan'],
      caHoc: json['caHoc'],
      lecturer: json['lecturer'] != null ? LecturerModel.fromJson(json['lecturer']) : null,
      isConfirmed: json['isConfirmed'] ?? false,
      registrations: json['registrations'] ?? [],
      ngayBatDau: json['ngayBatDau'] != null ? DateTime.parse(json['ngayBatDau']) : null,
      ngayKetThuc: json['ngayKetThuc'] != null ? DateTime.parse(json['ngayKetThuc']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject?.toJson(),
      'classroom': classroom?.toJson(),
      'thuTrongTuan': thuTrongTuan,
      'caHoc': caHoc,
      'lecturer': lecturer?.toJson(),
      'isConfirmed': isConfirmed,
      'registrations': registrations,
      'ngayBatDau': ngayBatDau?.toIso8601String().substring(0, 10),
      'ngayKetThuc': ngayKetThuc?.toIso8601String().substring(0, 10),
    };
  }
}
