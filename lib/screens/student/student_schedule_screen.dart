import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/student_service.dart';
import '../../models/schedule_model.dart';
import '../../utils/theme.dart';

class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({super.key});

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
            _schedules = data.map((e) => Schedule.fromJson(e)).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Học Của Tôi'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
              ? const Center(child: Text('Chưa có lịch học nào.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _schedules[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.withOpacity(0.1),
                          child: const Icon(Icons.calendar_month, color: Colors.indigo),
                        ),
                        title: Text('${schedule.thuTrongTuan} - ${schedule.caHoc}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Môn: ${schedule.subject?.tenMonHoc ?? ''}\n'
                          'Thời gian: ${_formatDate(schedule.ngayBatDau)} - ${_formatDate(schedule.ngayKetThuc)}\n'
                          'Phòng: ${schedule.classroom?.tenPhong ?? ''} - Toà: ${schedule.classroom?.toaNha ?? ''}\n'
                          'GV: ${schedule.lecturer?.hoTen ?? ''}'
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
