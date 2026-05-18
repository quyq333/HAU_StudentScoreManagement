import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../models/semester_model.dart';
import '../../utils/theme.dart';
import 'manage_subjects_screen.dart';

class AdminSubjectSemesterFlowScreen extends StatefulWidget {
  const AdminSubjectSemesterFlowScreen({super.key});

  @override
  State<AdminSubjectSemesterFlowScreen> createState() => _AdminSubjectSemesterFlowScreenState();
}

class _AdminSubjectSemesterFlowScreenState extends State<AdminSubjectSemesterFlowScreen> {
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
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.calendar_month, color: AppTheme.primaryBlue),
                    ),
                    title: Text(
                      semester.tenHocKy,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                    ),
                    subtitle: Text('Năm học: ${semester.namHoc}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageSubjectsScreen(
                            semesterId: semester.id,
                            semesterName: semester.tenHocKy,
                          ),
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
