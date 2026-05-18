import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../models/subject_model.dart';
import '../../models/semester_model.dart';
import '../../utils/theme.dart';

class ManageSubjectsScreen extends StatefulWidget {
  final int? semesterId;
  final String? semesterName;

  const ManageSubjectsScreen({super.key, this.semesterId, this.semesterName});

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
    final semesters = await _apiService.getSemesters();
    
    List<SubjectModel> subjects;
    if (widget.semesterId != null) {
      subjects = await _apiService.getSubjectsBySemester(widget.semesterId!);
    } else {
      subjects = await _apiService.getSubjects();
    }

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
    
    // Default to the current semester if provided, else use the subject's semester or the first available
    int? selectedSemesterId = subject?.idHocKy != 0 && subject?.idHocKy != null 
        ? subject?.idHocKy 
        : (widget.semesterId ?? (_semesters.isNotEmpty ? _semesters.first.id : null));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(isEditing ? 'Sửa Môn Học' : 'Thêm Môn Học', 
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: idController,
                      decoration: InputDecoration(
                        labelText: 'Mã Môn Học',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.badge),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên Môn Học',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.book),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: creditController,
                      decoration: InputDecoration(
                        labelText: 'Số Tín Chỉ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedSemesterId,
                      decoration: InputDecoration(
                        labelText: 'Học Kỳ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
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
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    if (idController.text.isEmpty || nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin'))
                      );
                      return;
                    }

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
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa môn học này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _apiService.deleteSubject(id);
      if (success) {
        _loadData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Môn học này đã có điểm hoặc đang được sử dụng.')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(widget.semesterName != null ? 'Môn Học - ${widget.semesterName}' : 'Quản lý Môn Học'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text('Không có môn học nào trong học kỳ này', 
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    final semester = _semesters.firstWhere(
                      (s) => s.id == subject.idHocKy, 
                      orElse: () => SemesterModel(id: 0, tenHocKy: 'Không rõ', namHoc: '')
                    );
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                          child: Icon(Icons.book, color: AppTheme.primaryBlue),
                        ),
                        title: Text(subject.tenMonHoc, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Mã: ${subject.maMonHoc} • ${subject.soTinChi} tín chỉ'),
                            if (widget.semesterId == null) Text('Học kỳ: ${semester.tenHocKy}'),
                          ],
                        ),
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
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSubjectDialog(),
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
