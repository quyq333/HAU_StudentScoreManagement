import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/student_service.dart';
import '../../models/study_material_model.dart';
import '../../utils/theme.dart';

class StudentMaterialScreen extends StatefulWidget {
  const StudentMaterialScreen({super.key});

  @override
  State<StudentMaterialScreen> createState() => _StudentMaterialScreenState();
}

class _StudentMaterialScreenState extends State<StudentMaterialScreen> {
  final StudentService _studentService = StudentService();
  List<StudyMaterial> _materials = [];
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
        final data = await _studentService.getMaterialsByStudent(user.maSV);
        if (mounted) {
          setState(() {
            _materials = data.map((e) => StudyMaterial.fromJson(e)).toList();
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
        title: const Text('Tài Liệu Học Tập'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _materials.isEmpty
              ? const Center(child: Text('Chưa có tài liệu học tập nào.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _materials.length,
                  itemBuilder: (context, index) {
                    final material = _materials[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.brown.withOpacity(0.1),
                          child: const Icon(Icons.description, color: Colors.brown),
                        ),
                        title: Text(material.tenTaiLieu, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Loại: ${material.loaiTaiLieu ?? ''}\nMôn: ${material.subject?.tenMonHoc ?? ''}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.download, color: AppTheme.primaryBlue),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tính năng đang được phát triển')),
                            );
                          },
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
