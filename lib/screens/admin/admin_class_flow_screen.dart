import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../utils/theme.dart';
import 'admin_student_flow_screen.dart';

class AdminClassFlowScreen extends StatefulWidget {
  final int semesterId;
  final String semesterName;

  const AdminClassFlowScreen({super.key, required this.semesterId, required this.semesterName});

  @override
  State<AdminClassFlowScreen> createState() => _AdminClassFlowScreenState();
}

class _AdminClassFlowScreenState extends State<AdminClassFlowScreen> {
  final AdminApiService _apiService = AdminApiService();
  List<String> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final data = await _apiService.getClasses();
    setState(() {
      _classes = data.where((c) => c != 'ADMIN' && c.isNotEmpty).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('${widget.semesterName} - Chọn Lớp'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
              ? const Center(child: Text('Không có dữ liệu lớp học'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    final className = _classes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.withOpacity(0.1),
                          child: const Icon(Icons.class_, color: Colors.orange),
                        ),
                        title: Text(
                          className,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminStudentFlowScreen(
                                semesterId: widget.semesterId,
                                className: className,
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
