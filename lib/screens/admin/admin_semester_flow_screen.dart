import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../models/semester_model.dart';
import '../../utils/theme.dart';
import 'admin_class_flow_screen.dart';

class AdminSemesterFlowScreen extends StatefulWidget {
  const AdminSemesterFlowScreen({super.key});

  @override
  State<AdminSemesterFlowScreen> createState() => _AdminSemesterFlowScreenState();
}

class _AdminSemesterFlowScreenState extends State<AdminSemesterFlowScreen> {
  final AdminApiService _apiService = AdminApiService();
  List<SemesterModel> _semesters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSemesters();
  }

  Future<void> _loadSemesters() async {
    final data = await _apiService.getSemesters();
    setState(() {
      _semesters = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Chọn Học Kỳ'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _semesters.length,
              itemBuilder: (context, index) {
                final semester = _semesters[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(
                      semester.tenHocKy,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text('Năm học: ${semester.namHoc}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminClassFlowScreen(semesterId: semester.id, semesterName: semester.tenHocKy),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
