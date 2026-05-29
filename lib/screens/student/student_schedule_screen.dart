import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/student_service.dart';
import '../../models/schedule_model.dart';
import '../../utils/theme.dart';

class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  final StudentService _studentService = StudentService();
  List<Schedule> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        final data = await _studentService.getSchedulesByStudent(user.maSV);
        if (mounted) {
          setState(() {
            _schedules = data
                .map((e) => Schedule.fromJson(e))
                .where((schedule) => schedule.isConfirmed)
                .toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, List<Schedule>> _groupSchedulesBySemester() {
    final groups = <String, List<Schedule>>{};
    for (final schedule in _schedules) {
      final subject = schedule.subject;
      final namHoc = subject?.namHoc?.isNotEmpty == true
          ? subject!.namHoc!
          : 'Chưa rõ năm học';
      final tenHocKy = subject?.tenHocKy?.isNotEmpty == true
          ? subject!.tenHocKy!
          : 'Chưa rõ học kỳ';
      final key = '$namHoc - $tenHocKy';
      groups.putIfAbsent(key, () => []).add(schedule);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Lịch Học Của Tôi'),
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
          ? const Center(child: Text('Chưa có lịch học nào.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: _groupSchedulesBySemester().entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: entry.value.map((schedule) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.withOpacity(0.1),
                          child: const Icon(
                            Icons.calendar_month,
                            color: Colors.indigo,
                          ),
                        ),
                        title: Text(
                          '${schedule.thuTrongTuan} - ${schedule.caHoc}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Môn: ${schedule.subject?.tenMonHoc ?? ''}\n'
                          'Thời gian: ${_formatDate(schedule.ngayBatDau)} - ${_formatDate(schedule.ngayKetThuc)}\n'
                          'Phòng: ${schedule.classroom?.tenPhong ?? ''} - Toà: ${schedule.classroom?.toaNha ?? ''}\n'
                          'GV: ${schedule.lecturer?.hoTen ?? ''}',
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
