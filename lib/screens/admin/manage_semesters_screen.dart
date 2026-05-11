import 'package:flutter/material.dart';
import '../../models/semester_model.dart';
import '../../services/admin_api_service.dart';

class ManageSemestersScreen extends StatefulWidget {
  const ManageSemestersScreen({super.key});

  @override
  State<ManageSemestersScreen> createState() => _ManageSemestersScreenState();
}

class _ManageSemestersScreenState extends State<ManageSemestersScreen> {
  final AdminApiService _apiService = AdminApiService();
  List<SemesterModel> _semesters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSemesters();
  }

  Future<void> _loadSemesters() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getSemesters();
    setState(() {
      _semesters = data;
      _isLoading = false;
    });
  }

  void _showSemesterDialog([SemesterModel? semester]) {
    final isEditing = semester != null;
    final nameController = TextEditingController(text: semester?.tenHocKy);
    final yearController = TextEditingController(text: semester?.namHoc);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Sửa Học Kỳ' : 'Thêm Học Kỳ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tên Học Kỳ (vd: Học kỳ 1)'),
            ),
            TextField(
              controller: yearController,
              decoration: const InputDecoration(labelText: 'Năm Học (vd: 2023-2024)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'tenHocKy': nameController.text,
                'namHoc': yearController.text,
              };

              bool success;
              if (isEditing) {
                success = await _apiService.updateSemester(semester.id, data);
              } else {
                success = await _apiService.createSemester(data);
              }

              if (success) {
                if (context.mounted) Navigator.pop(context);
                _loadSemesters();
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _deleteSemester(int id) async {
    final success = await _apiService.deleteSemester(id);
    if (success) {
      _loadSemesters();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Học kỳ này đang chứa điểm.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Học Kỳ')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _semesters.length,
              itemBuilder: (context, index) {
                final semester = _semesters[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.calendar_today)),
                  title: Text(semester.tenHocKy),
                  subtitle: Text('Năm học: ${semester.namHoc}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showSemesterDialog(semester),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSemester(semester.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSemesterDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
