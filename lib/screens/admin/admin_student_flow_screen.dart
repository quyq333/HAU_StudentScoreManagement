import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../models/user_model.dart';
import '../../utils/theme.dart';
import 'admin_score_management_screen.dart';

class AdminStudentFlowScreen extends StatefulWidget {
  final int semesterId;
  final String className;

  const AdminStudentFlowScreen({super.key, required this.semesterId, required this.className});

  @override
  State<AdminStudentFlowScreen> createState() => _AdminStudentFlowScreenState();
}

class _AdminStudentFlowScreenState extends State<AdminStudentFlowScreen> {
  final AdminApiService _apiService = AdminApiService();
  List<UserModel> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final data = await _apiService.getStudentsByClass(widget.className);
    setState(() {
      _students = data.where((s) => s.role != 'ROLE_ADMIN').toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Lớp ${widget.className}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? const Center(child: Text('Không có sinh viên trong lớp này'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: const Icon(Icons.person, color: Colors.blue),
                        ),
                        title: Text(
                          student.hoTen,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text('Mã SV: ${student.maSV}'),
                        trailing: const Icon(Icons.edit_note, size: 24, color: AppTheme.primaryBlue),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminScoreManagementScreen(
                                semesterId: widget.semesterId,
                                student: student,
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
