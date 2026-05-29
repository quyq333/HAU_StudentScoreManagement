import 'package:flutter/material.dart';
import '../../models/subject_model.dart';
import '../../services/admin_api_service.dart';
import '../../utils/theme.dart';

class ManageExamSchedulesScreen extends StatefulWidget {
  const ManageExamSchedulesScreen({super.key});

  @override
  State<ManageExamSchedulesScreen> createState() =>
      _ManageExamSchedulesScreenState();
}

class _ManageExamSchedulesScreenState extends State<ManageExamSchedulesScreen> {
  final AdminApiService _apiService = AdminApiService();
  List<Map<String, dynamic>> _examSchedules = [];
  List<SubjectModel> _subjects = [];
  List<Map<String, dynamic>> _classrooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final exams = await _apiService.getExamSchedules();
    final subjects = await _apiService.getSubjects();
    final classrooms = await _apiService.getClassrooms();
    if (!mounted) return;
    setState(() {
      _examSchedules = exams;
      _subjects = subjects;
      _classrooms = classrooms;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Lịch thi'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
          ? const Center(child: Text('Chưa có môn học.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final subject = _subjects[index];
                final count = _examSchedules
                    .where((exam) => exam['subject']?['maMonHoc'] == subject.maMonHoc)
                    .length;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                      child: Icon(Icons.book, color: AppTheme.primaryBlue),
                    ),
                    title: Text(
                      subject.tenMonHoc,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Mã môn: ${subject.maMonHoc} • $count lịch thi/phòng thi',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubjectExamSchedulesScreen(
                            subject: subject,
                            classrooms: _classrooms,
                            apiService: _apiService,
                          ),
                        ),
                      ).then((_) => _loadData());
                    },
                  ),
                );
              },
            ),
    );
  }
}

class SubjectExamSchedulesScreen extends StatefulWidget {
  final SubjectModel subject;
  final List<Map<String, dynamic>> classrooms;
  final AdminApiService apiService;

  const SubjectExamSchedulesScreen({
    super.key,
    required this.subject,
    required this.classrooms,
    required this.apiService,
  });

  @override
  State<SubjectExamSchedulesScreen> createState() =>
      _SubjectExamSchedulesScreenState();
}

class _SubjectExamSchedulesScreenState
    extends State<SubjectExamSchedulesScreen> {
  List<Map<String, dynamic>> _allExamSchedules = [];
  List<Map<String, dynamic>> _subjectExamSchedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final exams = await widget.apiService.getExamSchedules();
    if (!mounted) return;
    setState(() {
      _allExamSchedules = exams;
      _subjectExamSchedules = exams
          .where((exam) => exam['subject']?['maMonHoc'] == widget.subject.maMonHoc)
          .toList();
      _isLoading = false;
    });
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'N/A';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
  }

  String _datePayload(DateTime date) => date.toIso8601String().substring(0, 10);

  String _nameSortKey(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return fullName;
    return '${parts.last} $fullName';
  }

  Map<String, String>? _getStudentConflict(
    String maSV,
    Map<String, dynamic> currentExam,
  ) {
    final currentExamId = currentExam['id'];
    final currentSubjectCode = widget.subject.maMonHoc;
    final currentDateStr = currentExam['ngayThi']?.toString();
    final currentSlot = currentExam['caThi']?.toString();

    for (var exam in _allExamSchedules) {
      if (exam['id'] == currentExamId) continue;

      final regs = exam['registrations'] as List? ?? [];
      final isRegisteredInOther =
          regs.any((reg) => reg['student']?['maSV']?.toString() == maSV);

      if (isRegisteredInOther) {
        final otherSubjectCode = exam['subject']?['maMonHoc'];
        if (otherSubjectCode == currentSubjectCode) {
          return {
            'type': 'subject',
            'message':
                'Đã xếp phòng thi môn này (${exam['classroom']?['tenPhong'] ?? 'Chưa xếp'})',
          };
        }

        final otherDateStr = exam['ngayThi']?.toString();
        final otherSlot = exam['caThi']?.toString();
        if (otherDateStr == currentDateStr && otherSlot == currentSlot) {
          return {
            'type': 'schedule',
            'message':
                'Trùng ca thi môn ${exam['subject']?['tenMonHoc'] ?? ''} (${exam['classroom']?['tenPhong'] ?? 'Chưa xếp'})',
          };
        }
      }
    }
    return null;
  }

  Future<void> _showExamDialog([Map<String, dynamic>? exam]) async {
    final isEditing = exam != null;
    int? selectedClassroomId = _asInt(exam?['classroom']?['id']);
    DateTime? examDate = exam?['ngayThi'] != null
        ? DateTime.tryParse(exam!['ngayThi'].toString())
        : null;
    String selectedSlot = exam?['caThi'] ?? 'Ca sáng';
    final noteController = TextEditingController(text: exam?['ghiChu'] ?? '');
    const slots = ['Ca sáng', 'Ca chiều', 'Ca tối'];

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Sửa lịch thi' : 'Thêm lịch thi'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputDecorator(
                      decoration: const InputDecoration(labelText: 'Môn học'),
                      child: Text(
                        '${widget.subject.tenMonHoc} (${widget.subject.maMonHoc})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      value: selectedClassroomId,
                      decoration: const InputDecoration(labelText: 'Phòng thi'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Chưa xếp phòng'),
                        ),
                        ...widget.classrooms.map((room) {
                          final id = _asInt(room['id']);
                          return DropdownMenuItem<int?>(
                            value: id,
                            child: Text(
                              '${room['tenPhong']} (${room['toaNha'] ?? ''})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setDialogState(() => selectedClassroomId = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: slots.contains(selectedSlot)
                          ? selectedSlot
                          : slots.first,
                      decoration: const InputDecoration(labelText: 'Ca thi'),
                      items: slots.map((slot) {
                        return DropdownMenuItem(value: slot, child: Text(slot));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedSlot = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: examDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => examDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ngày thi',
                        ),
                        child: Text(
                          examDate == null
                              ? 'Chọn ngày thi'
                              : _formatDate(_datePayload(examDate!)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(labelText: 'Ghi chú'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (examDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng chọn ngày thi.'),
                        ),
                      );
                      return;
                    }

                    final data = {
                      'maMonHoc': widget.subject.maMonHoc,
                      'idPhong': selectedClassroomId,
                      'ngayThi': _datePayload(examDate!),
                      'caThi': selectedSlot,
                      'ghiChu': noteController.text,
                    };

                    final success = isEditing
                        ? await widget.apiService
                            .updateExamSchedule(exam['id'], data)
                        : await widget.apiService.createExamSchedule(data);

                    if (!context.mounted) return;
                    if (success) {
                      Navigator.pop(context);
                      await _loadData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lưu lịch thi thất bại.')),
                      );
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _manageStudents(Map<String, dynamic> exam) async {
    final eligibleStudents = await widget.apiService.getEligibleExamStudents(
      exam['id'],
    );
    final initialRegistrations = (exam['registrations'] as List? ?? [])
        .map((reg) => reg['student']?['maSV']?.toString())
        .whereType<String>()
        .toSet();
    final selectedStudentIds = Set<String>.from(initialRegistrations);

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Sinh viên dự thi'),
              content: SizedBox(
                width: double.maxFinite,
                child: eligibleStudents.isEmpty
                    ? const Text('Chưa có sinh viên đăng ký lịch học môn này.')
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: eligibleStudents.length,
                        itemBuilder: (context, index) {
                          final student = eligibleStudents[index];
                          final maSV = student['maSV']?.toString() ?? '';
                          final selected = selectedStudentIds.contains(maSV);
                          final conflict =
                              selected ? null : _getStudentConflict(maSV, exam);
                          final hasConflict = conflict != null;

                          return CheckboxListTile(
                            value: selected,
                            title: Text(
                              student['hoTen'] ?? '',
                              style: TextStyle(
                                color:
                                    hasConflict ? Colors.grey : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${student['maSV']} - ${student['lop'] ?? ''}',
                                ),
                                if (hasConflict)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      conflict['message']!,
                                      style: TextStyle(
                                        color: Colors.orange.shade800,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onChanged: hasConflict
                                ? null
                                : (checked) async {
                                    final success = checked == true
                                        ? await widget.apiService
                                            .addStudentToExamSchedule(
                                            exam['id'],
                                            maSV,
                                          )
                                        : await widget.apiService
                                            .removeStudentFromExamSchedule(
                                            exam['id'],
                                            maSV,
                                          );
                                    if (!success) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Lỗi khi cập nhật sinh viên dự thi.',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                      return;
                                    }
                                    setDialogState(() {
                                      if (checked == true) {
                                        selectedStudentIds.add(maSV);
                                      } else {
                                        selectedStudentIds.remove(maSV);
                                      }
                                    });
                                  },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      },
    );

    await _loadData();
  }

  Future<void> _deleteExam(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch thi'),
        content: const Text('Bạn có chắc chắn muốn xóa lịch thi này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final success = await widget.apiService.deleteExamSchedule(id);
    if (success) {
      await _loadData();
    }
  }

  List<dynamic> _sortedRegistrations(Map<String, dynamic> exam) {
    final registrations = List<dynamic>.from(exam['registrations'] ?? []);
    registrations.sort((a, b) {
      final first = a['student']?['hoTen']?.toString() ?? '';
      final second = b['student']?['hoTen']?.toString() ?? '';
      return _nameSortKey(first).compareTo(_nameSortKey(second));
    });
    return registrations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch thi: ${widget.subject.tenMonHoc}'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subjectExamSchedules.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có lịch thi cho môn học này',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nhấn nút "+" bên dưới để thêm lịch thi đầu tiên.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _subjectExamSchedules.length,
              itemBuilder: (context, index) {
                final exam = _subjectExamSchedules[index];
                final room = exam['classroom'];
                final registrations = _sortedRegistrations(exam);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: const Icon(Icons.event_available),
                    title: Text(
                      'Phòng: ${room?['tenPhong'] ?? 'Chưa xếp'} (${room?['toaNha'] ?? ''})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${_formatDate(exam['ngayThi'])} - ${exam['caThi'] ?? ''}\n'
                      'Số lượng sinh viên: ${registrations.length}',
                    ),
                    children: [
                      if (registrations.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Chưa có sinh viên trong lịch thi này.'),
                        )
                      else
                        ...registrations.map((reg) {
                          final student = reg['student'];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.person, size: 18),
                            title: Text(student?['hoTen'] ?? ''),
                            subtitle: Text(
                              '${student?['maSV'] ?? ''} - ${student?['lop'] ?? ''}',
                            ),
                          );
                        }),
                      ButtonBar(
                        children: [
                          TextButton.icon(
                            onPressed: () => _manageStudents(exam),
                            icon: const Icon(Icons.group_add),
                            label: const Text('Sinh viên'),
                          ),
                          TextButton.icon(
                            onPressed: () => _showExamDialog(exam),
                            icon: const Icon(Icons.edit),
                            label: const Text('Sửa'),
                          ),
                          TextButton.icon(
                            onPressed: () => _deleteExam(exam['id']),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'Xóa',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExamDialog(),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm lịch thi'),
      ),
    );
  }
}
