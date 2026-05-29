import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exam_schedule_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/student_service.dart';
import '../../utils/theme.dart';

class StudentExamScheduleScreen extends StatefulWidget {
  const StudentExamScheduleScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<StudentExamScheduleScreen> createState() =>
      _StudentExamScheduleScreenState();
}

class _StudentExamScheduleScreenState extends State<StudentExamScheduleScreen> {
  final StudentService _studentService = StudentService();
  List<ExamSchedule> _examSchedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final data = await _studentService.getExamSchedulesByStudent(user.maSV);
    if (!mounted) return;
    setState(() {
      _examSchedules = data.map((e) => ExamSchedule.fromJson(e)).toList();
      _isLoading = false;
    });
  }

  Map<String, List<ExamSchedule>> _groupBySemester() {
    final groups = <String, List<ExamSchedule>>{};
    for (final exam in _examSchedules) {
      final subject = exam.subject;
      final namHoc = subject?.namHoc?.isNotEmpty == true
          ? subject!.namHoc!
          : 'Chưa rõ năm học';
      final tenHocKy = subject?.tenHocKy?.isNotEmpty == true
          ? subject!.tenHocKy!
          : 'Chưa rõ học kỳ';
      groups.putIfAbsent('$namHoc - $tenHocKy', () => []).add(exam);
    }
    return groups;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Lịch Thi Của Tôi'),
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _examSchedules.isEmpty
          ? const Center(child: Text('Chưa có lịch thi nào.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: _groupBySemester().entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: entry.value.map((exam) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepOrange.withOpacity(0.1),
                          child: const Icon(
                            Icons.event_available,
                            color: Colors.deepOrange,
                          ),
                        ),
                        title: Text(
                          exam.subject?.tenMonHoc ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Ngày thi: ${_formatDate(exam.ngayThi)} - ${exam.caThi ?? ''}\n'
                          'Phòng: ${exam.classroom?.tenPhong ?? 'Chưa xếp'} - Toà: ${exam.classroom?.toaNha ?? ''}\n'
                          '${exam.ghiChu?.isNotEmpty == true ? 'Ghi chú: ${exam.ghiChu}' : ''}',
                        ),
                        isThreeLine: true,
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
