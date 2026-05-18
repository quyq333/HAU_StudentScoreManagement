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
  List<SemesterModel> _allSemesters = [];
  List<String> _years = [];
  String? _selectedYear;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSemesters();
  }

  Future<void> _loadSemesters() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getSemesters();
    
    final years = data
        .map((s) => s.namHoc)
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));

    setState(() {
      _allSemesters = data;
      _years = years;
      _isLoading = false;
    });
  }

  void _showSemesterDialog([SemesterModel? semester, String? defaultYear]) {
    final isEditing = semester != null;
    final nameController = TextEditingController(text: semester?.tenHocKy);
    final yearController = TextEditingController(text: semester?.namHoc ?? defaultYear);

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
      appBar: AppBar(
        title: Text(_selectedYear == null ? 'Quản lý Học Kỳ' : 'Năm học $_selectedYear'),
        leading: _selectedYear != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedYear = null;
                  });
                },
              )
            : const BackButton(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedYear == null
              ? _buildYearsList()
              : _buildSemestersList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSemesterDialog(null, _selectedYear),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildYearsList() {
    if (_years.isEmpty) {
      return const Center(child: Text('Chưa có năm học nào được tạo.'));
    }
    return ListView.builder(
      itemCount: _years.length,
      itemBuilder: (context, index) {
        final year = _years[index];
        final semesterCount = _allSemesters.where((s) => s.namHoc == year).length;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.purple,
              child: Icon(Icons.calendar_month, color: Colors.white),
            ),
            title: Text('Năm học $year', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$semesterCount học kỳ'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              setState(() {
                _selectedYear = year;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildSemestersList() {
    final semestersInYear = _allSemesters.where((s) => s.namHoc == _selectedYear).toList();
    if (semestersInYear.isEmpty) {
      return const Center(child: Text('Năm học này không có học kỳ nào.'));
    }
    return ListView.builder(
      itemCount: semestersInYear.length,
      itemBuilder: (context, index) {
        final semester = semestersInYear[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.calendar_today)),
          title: Text(semester.tenHocKy),
          subtitle: Text('Năm học: ${semester.namHoc}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showSemesterDialog(semester, _selectedYear),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteSemester(semester.id),
              ),
            ],
          ),
        );
      },
    );
  }
}
