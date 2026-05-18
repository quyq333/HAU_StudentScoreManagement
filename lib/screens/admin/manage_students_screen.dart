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
  List<UserModel> _allStudents = [];
  List<String> _classes = [];
  String? _selectedClass;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getStudents();
    
    final classes = data
        .where((s) => s.lop != 'ADMIN' && s.role != 'ROLE_ADMIN' && s.lop.isNotEmpty)
        .map((s) => s.lop)
        .toSet()
        .toList();
    classes.sort();

    setState(() {
      _allStudents = data;
      _classes = classes;
      _isLoading = false;
    });
  }

  void _showStudentDialog([UserModel? student, String? defaultClass]) {
    final isEditing = student != null;
    final maSVController = TextEditingController(text: student?.maSV);
    final hoTenController = TextEditingController(text: student?.hoTen);
    final lopController = TextEditingController(text: student?.lop ?? defaultClass);
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
                _loadData();
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
      _loadData();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể xóa sinh viên này (có thể do đã có điểm)')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedClass == null ? 'Quản lý Sinh Viên' : 'Lớp $_selectedClass'),
        leading: _selectedClass != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedClass = null;
                  });
                },
              )
            : const BackButton(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedClass == null
              ? _buildClassesList()
              : _buildStudentsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStudentDialog(null, _selectedClass),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildClassesList() {
    if (_classes.isEmpty) {
      return const Center(child: Text('Chưa có lớp nào được tạo.'));
    }
    return ListView.builder(
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        final className = _classes[index];
        final studentCount = _allStudents.where((s) => s.lop == className && s.role != 'ROLE_ADMIN').length;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.class_, color: Colors.white),
            ),
            title: Text('Lớp $className', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$studentCount sinh viên'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              setState(() {
                _selectedClass = className;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildStudentsList() {
    final studentsInClass = _allStudents.where((s) => s.lop == _selectedClass && s.role != 'ROLE_ADMIN').toList();
    if (studentsInClass.isEmpty) {
      return const Center(child: Text('Lớp này không có sinh viên nào.'));
    }
    return ListView.builder(
      itemCount: studentsInClass.length,
      itemBuilder: (context, index) {
        final student = studentsInClass[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(student.hoTen),
          subtitle: Text('${student.maSV} - Lớp: ${student.lop} - Role: ${student.role}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showStudentDialog(student, _selectedClass),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteStudent(student.maSV),
              ),
            ],
          ),
        );
      },
    );
  }
}
