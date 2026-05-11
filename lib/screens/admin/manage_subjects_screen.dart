import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../models/subject_model.dart';
import '../../models/semester_model.dart';

class ManageSubjectsScreen extends StatefulWidget {
  const ManageSubjectsScreen({super.key});

  @override
  State<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  final AdminApiService _apiService = AdminApiService();
  List<SubjectModel> _subjects = [];
  List<SemesterModel> _semesters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final subjects = await _apiService.getSubjects();
    final semesters = await _apiService.getSemesters();
    setState(() {
      _subjects = subjects;
      _semesters = semesters;
      _isLoading = false;
    });
  }

  void _showSubjectDialog([SubjectModel? subject]) {
    final isEditing = subject != null;
    final idController = TextEditingController(text: subject?.maMonHoc);
    final nameController = TextEditingController(text: subject?.tenMonHoc);
    final creditController = TextEditingController(text: subject?.soTinChi.toString());
    int? selectedSemesterId = subject?.idHocKy != 0 ? subject?.idHocKy : (_semesters.isNotEmpty ? _semesters.first.id : null);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Sửa Môn Học' : 'Thêm Môn Học'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: idController,
                      decoration: const InputDecoration(labelText: 'Mã Môn Học'),
                      enabled: !isEditing,
                    ),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Tên Môn Học'),
                    ),
                    TextField(
                      controller: creditController,
                      decoration: const InputDecoration(labelText: 'Số Tín Chỉ'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedSemesterId,
                      decoration: const InputDecoration(labelText: 'Học Kỳ'),
                      items: _semesters.map((s) {
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text(s.tenHocKy),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedSemesterId = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    final data = {
                      'maMonHoc': idController.text,
                      'tenMonHoc': nameController.text,
                      'soTinChi': int.tryParse(creditController.text) ?? 3,
                      'idHocKy': selectedSemesterId,
                    };

                    bool success;
                    if (isEditing) {
                      success = await _apiService.updateSubject(subject.maMonHoc, data);
                    } else {
                      success = await _apiService.createSubject(data);
                    }

                    if (success) {
                      if (context.mounted) Navigator.pop(context);
                      _loadData();
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _deleteSubject(String id) async {
    final success = await _apiService.deleteSubject(id);
    if (success) {
      _loadData();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Môn học này đã có điểm.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Môn Học')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final subject = _subjects[index];
                final semesterName = _semesters.firstWhere((s) => s.id == subject.idHocKy, orElse: () => SemesterModel(id: 0, tenHocKy: 'Không rõ', namHoc: '')).tenHocKy;
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.book)),
                  title: Text(subject.tenMonHoc),
                  subtitle: Text('Mã: ${subject.maMonHoc} - Tín chỉ: ${subject.soTinChi}\nHọc kỳ: $semesterName'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showSubjectDialog(subject),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSubject(subject.maMonHoc),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSubjectDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
