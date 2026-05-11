import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/admin_api_service.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final AdminApiService _apiService = AdminApiService();
  List<UserModel> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getStudents();
    setState(() {
      _students = data;
      _isLoading = false;
    });
  }

  void _showStudentDialog([UserModel? student]) {
    final isEditing = student != null;
    final maSVController = TextEditingController(text: student?.maSV);
    final hoTenController = TextEditingController(text: student?.hoTen);
    final lopController = TextEditingController(text: student?.lop);
    final passwordController = TextEditingController(); // Only used for creation or explicit change
    String role = student?.role ?? 'ROLE_STUDENT';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Sửa Sinh Viên' : 'Thêm Sinh Viên'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: maSVController,
                decoration: const InputDecoration(labelText: 'Mã Sinh Viên'),
                enabled: !isEditing,
              ),
              TextField(
                controller: hoTenController,
                decoration: const InputDecoration(labelText: 'Họ Tên'),
              ),
              TextField(
                controller: lopController,
                decoration: const InputDecoration(labelText: 'Lớp'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: isEditing ? 'Mật khẩu mới (để trống nếu ko đổi)' : 'Mật khẩu',
                ),
                obscureText: true,
              ),
              DropdownButtonFormField<String>(
                value: role,
                items: const [
                  DropdownMenuItem(value: 'ROLE_STUDENT', child: Text('Sinh Viên')),
                  DropdownMenuItem(value: 'ROLE_ADMIN', child: Text('Quản Trị Viên')),
                ],
                onChanged: (val) => role = val!,
                decoration: const InputDecoration(labelText: 'Phân Quyền'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'maSV': maSVController.text,
                'hoTen': hoTenController.text,
                'lop': lopController.text,
                'role': role,
              };
              if (passwordController.text.isNotEmpty || !isEditing) {
                data['matKhau'] = passwordController.text;
              }

              bool success;
              if (isEditing) {
                success = await _apiService.updateStudent(student.maSV, data);
              } else {
                success = await _apiService.createStudent(data);
              }

              if (success) {
                if (context.mounted) Navigator.pop(context);
                _loadStudents();
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Có lỗi xảy ra')),
                  );
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _deleteStudent(String maSV) async {
    final success = await _apiService.deleteStudent(maSV);
    if (success) {
      _loadStudents();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể xóa sinh viên này (có thể do đã có điểm)')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Sinh Viên')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(student.hoTen),
                  subtitle: Text('${student.maSV} - Lớp: ${student.lop} - Role: ${student.role}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showStudentDialog(student),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteStudent(student.maSV),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStudentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
