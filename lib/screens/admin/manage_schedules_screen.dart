import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../models/subject_model.dart';
import '../../utils/theme.dart';

class ManageSchedulesScreen extends StatefulWidget {
  const ManageSchedulesScreen({super.key});

  @override
  State<ManageSchedulesScreen> createState() => _ManageSchedulesScreenState();
}

class _ManageSchedulesScreenState extends State<ManageSchedulesScreen> {
  final AdminApiService _apiService = AdminApiService();
  List<dynamic> _schedules = [];
  List<dynamic> _classrooms = [];
  List<dynamic> _lecturers = [];
  List<SubjectModel> _subjects = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final sc = await _apiService.getSchedules();
      final cr = await _apiService.getClassrooms();
      final sub = await _apiService.getSubjects();
      final lec = await _apiService.getLecturers();
      if (mounted) {
        setState(() {
          _schedules = sc;
          _classrooms = cr;
          _subjects = sub;
          _lecturers = lec;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSubjects = _subjects.where((sub) {
      return sub.tenMonHoc.toLowerCase().contains(_searchQuery) ||
          sub.maMonHoc.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Lịch học'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm môn học...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.primaryBlue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryBlue,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.toLowerCase();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: filteredSubjects.isEmpty
                      ? const Center(child: Text('Không tìm thấy môn học nào'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredSubjects.length,
                          itemBuilder: (context, index) {
                            final sub = filteredSubjects[index];
                            final subSchedules = _schedules
                                .where(
                                  (s) =>
                                      s['subject']?['maMonHoc'] == sub.maMonHoc,
                                )
                                .toList();
                            final scheduleCount = subSchedules.length;

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      (scheduleCount > 0
                                              ? AppTheme.primaryBlue
                                              : Colors.grey)
                                          .withOpacity(0.1),
                                  child: Icon(
                                    Icons.book,
                                    color: scheduleCount > 0
                                        ? AppTheme.primaryBlue
                                        : Colors.grey,
                                  ),
                                ),
                                title: Text(
                                  sub.tenMonHoc,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  'Mã môn: ${sub.maMonHoc} • ${sub.soTinChi} Tín chỉ',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (scheduleCount > 0
                                                ? Colors.purple
                                                : Colors.grey)
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    scheduleCount > 0
                                        ? '$scheduleCount Lịch học'
                                        : 'Chưa xếp lịch',
                                    style: TextStyle(
                                      color: scheduleCount > 0
                                          ? Colors.purple
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SubjectSchedulesDetailScreen(
                                            subject: sub,
                                            initialSchedules: subSchedules,
                                            classrooms: _classrooms,
                                            lecturers: _lecturers,
                                            subjects: _subjects,
                                            apiService: _apiService,
                                            onRefresh: _loadData,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class SubjectSchedulesDetailScreen extends StatefulWidget {
  final SubjectModel subject;
  final List<dynamic> initialSchedules;
  final List<dynamic> classrooms;
  final List<dynamic> lecturers;
  final List<SubjectModel> subjects;
  final AdminApiService apiService;
  final Future<void> Function() onRefresh;

  const SubjectSchedulesDetailScreen({
    super.key,
    required this.subject,
    required this.initialSchedules,
    required this.classrooms,
    required this.lecturers,
    required this.subjects,
    required this.apiService,
    required this.onRefresh,
  });

  @override
  State<SubjectSchedulesDetailScreen> createState() =>
      _SubjectSchedulesDetailScreenState();
}

class _SubjectSchedulesDetailScreenState
    extends State<SubjectSchedulesDetailScreen> {
  late List<dynamic> _subjectSchedules;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subjectSchedules = List.from(widget.initialSchedules);
  }

  Future<void> _reloadData() async {
    setState(() => _isLoading = true);
    await widget.onRefresh();
    try {
      final allSchedules = await widget.apiService.getSchedules();
      if (mounted) {
        setState(() {
          _subjectSchedules = allSchedules
              .where(
                (s) => s['subject']?['maMonHoc'] == widget.subject.maMonHoc,
              )
              .toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String? _asNonEmptyString(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  List<String> _optionsWithCurrent(List<String> options, String? current) {
    if (current == null || options.contains(current)) {
      return options;
    }
    return [current, ...options];
  }

  void _showScheduleDialog({dynamic schedule, String? preselectedSubjectCode}) {
    final isEditing = schedule != null;
    final subjectCodes = widget.subjects.map((s) => s.maMonHoc).toSet();
    final classroomIds = widget.classrooms
        .map((cr) => _asInt(cr['id']))
        .whereType<int>()
        .toSet();
    final lecturerIds = widget.lecturers
        .map((lec) => _asNonEmptyString(lec['maGV']))
        .whereType<String>()
        .toSet();

    // Find initial values
    String? selectedSubjectCode =
        preselectedSubjectCode ?? schedule?['subject']?['maMonHoc'];
    if ((selectedSubjectCode == null ||
            !subjectCodes.contains(selectedSubjectCode)) &&
        widget.subjects.isNotEmpty) {
      selectedSubjectCode = widget.subjects.first.maMonHoc;
    }

    int? selectedClassroomId = _asInt(schedule?['classroom']?['id']);
    if ((selectedClassroomId == null ||
            !classroomIds.contains(selectedClassroomId)) &&
        classroomIds.isNotEmpty) {
      selectedClassroomId = classroomIds.first;
    }

    String? selectedLecturerId = _asNonEmptyString(
      schedule?['lecturer']?['maGV'],
    );
    if ((selectedLecturerId == null ||
            !lecturerIds.contains(selectedLecturerId)) &&
        lecturerIds.isNotEmpty) {
      selectedLecturerId = lecturerIds.first;
    }

    final List<String> defaultWeekdays = [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ nhật',
    ];
    String? selectedDay =
        _asNonEmptyString(schedule?['thuTrongTuan']) ?? defaultWeekdays.first;
    final weekdays = _optionsWithCurrent(defaultWeekdays, selectedDay);

    final List<String> defaultSlots = ['Ca sáng', 'Ca chiều', 'Ca tối'];
    String? selectedSlot =
        _asNonEmptyString(schedule?['caHoc']) ?? defaultSlots.first;
    final slots = _optionsWithCurrent(defaultSlots, selectedSlot);

    DateTime? startDate;
    if (schedule?['ngayBatDau'] != null) {
      startDate = DateTime.tryParse(schedule['ngayBatDau']);
    }

    DateTime? endDate;
    if (schedule?['ngayKetThuc'] != null) {
      endDate = DateTime.tryParse(schedule['ngayKetThuc']);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                isEditing ? 'Sửa Lịch Học' : 'Thêm Lịch Học',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedSubjectCode,
                      decoration: InputDecoration(
                        labelText: 'Môn học',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.book),
                      ),
                      items: widget.subjects.map((sub) {
                        return DropdownMenuItem<String>(
                          value: sub.maMonHoc,
                          child: Text(
                            sub.tenMonHoc,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: preselectedSubjectCode != null
                          ? null
                          : (val) {
                              setDialogState(() {
                                selectedSubjectCode = val;
                              });
                            },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedClassroomId,
                      decoration: InputDecoration(
                        labelText: 'Phòng học',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.room),
                      ),
                      items: widget.classrooms
                          .map((cr) {
                            final id = _asInt(cr['id']);
                            if (id == null) return null;
                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(
                                '${cr['tenPhong']} (${cr['toaNha'] ?? ''})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          })
                          .whereType<DropdownMenuItem<int>>()
                          .toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedClassroomId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedLecturerId,
                      decoration: InputDecoration(
                        labelText: 'Giảng viên',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      items: widget.lecturers
                          .map((lec) {
                            final maGV = _asNonEmptyString(lec['maGV']);
                            if (maGV == null) return null;
                            return DropdownMenuItem<String>(
                              value: maGV,
                              child: Text(
                                '${lec['hoTen']} (${lec['maGV']})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          })
                          .whereType<DropdownMenuItem<String>>()
                          .toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedLecturerId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedDay,
                      decoration: InputDecoration(
                        labelText: 'Thứ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      items: weekdays.map((day) {
                        return DropdownMenuItem<String>(
                          value: day,
                          child: Text(day),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedDay = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedSlot,
                      decoration: InputDecoration(
                        labelText: 'Ca học',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.schedule),
                      ),
                      items: slots.map((slot) {
                        return DropdownMenuItem<String>(
                          value: slot,
                          child: Text(slot),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedSlot = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          helpText: 'Chọn Ngày Bắt Đầu',
                        );
                        if (picked != null) {
                          setDialogState(() {
                            startDate = picked;
                            if (endDate != null &&
                                endDate!.isBefore(startDate!)) {
                              endDate = null;
                            }
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Ngày bắt đầu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.date_range),
                        ),
                        child: Text(
                          startDate != null
                              ? "${startDate!.day.toString().padLeft(2, '0')}/${startDate!.month.toString().padLeft(2, '0')}/${startDate!.year}"
                              : 'Chọn ngày bắt đầu',
                          style: TextStyle(
                            color: startDate != null
                                ? Colors.black87
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? startDate ?? DateTime.now(),
                          firstDate: startDate ?? DateTime(2000),
                          lastDate: DateTime(2100),
                          helpText: 'Chọn Ngày Kết Thúc',
                        );
                        if (picked != null) {
                          setDialogState(() {
                            endDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Ngày kết thúc',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.date_range),
                        ),
                        child: Text(
                          endDate != null
                              ? "${endDate!.day.toString().padLeft(2, '0')}/${endDate!.month.toString().padLeft(2, '0')}/${endDate!.year}"
                              : 'Chọn ngày kết thúc',
                          style: TextStyle(
                            color: endDate != null
                                ? Colors.black87
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (selectedSubjectCode == null ||
                        selectedClassroomId == null ||
                        selectedLecturerId == null ||
                        startDate == null ||
                        endDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Vui lòng điền đầy đủ thông tin bao gồm ngày bắt đầu và kết thúc!',
                          ),
                        ),
                      );
                      return;
                    }

                    final data = {
                      'maMonHoc': selectedSubjectCode,
                      'idPhong': selectedClassroomId,
                      'thuTrongTuan': selectedDay,
                      'caHoc': selectedSlot,
                      'maGV': selectedLecturerId,
                      'ngayBatDau': startDate!.toIso8601String().substring(
                        0,
                        10,
                      ),
                      'ngayKetThuc': endDate!.toIso8601String().substring(
                        0,
                        10,
                      ),
                    };

                    bool success;
                    if (isEditing) {
                      success = await widget.apiService.updateSchedule(
                        schedule['id'],
                        data,
                      );
                    } else {
                      success = await widget.apiService.createSchedule(data);
                    }

                    if (success) {
                      if (context.mounted) Navigator.pop(context);
                      _reloadData();
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lưu thông tin thất bại!'),
                          ),
                        );
                      }
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

  void _deleteSchedule(int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa lịch học này?'),
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

    if (confirm == true) {
      final success = await widget.apiService.deleteSchedule(id);
      if (success) {
        _reloadData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa lịch học thất bại!')),
          );
        }
      }
    }
  }

  Future<void> _setScheduleConfirmation(int id, bool shouldConfirm) async {
    if (!shouldConfirm) {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hủy xác nhận lịch'),
          content: const Text(
            'Lịch học này sẽ không còn hiển thị trong lịch học của sinh viên đã đăng ký. Bạn có chắc chắn muốn hủy xác nhận?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Đóng'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Hủy xác nhận',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    setState(() => _isLoading = true);
    final success = shouldConfirm
        ? await widget.apiService.confirmSchedule(id)
        : await widget.apiService.unconfirmSchedule(id);

    if (success) {
      await _reloadData();
      return;
    }

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            shouldConfirm
                ? 'Xác nhận lịch học thất bại!'
                : 'Hủy xác nhận lịch học thất bại!',
          ),
        ),
      );
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final parsed = DateTime.parse(dateStr);
      return "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}";
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch học: ${widget.subject.tenMonHoc}'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subjectSchedules.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Chưa có lịch học cho môn này',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nhấp vào nút bên dưới để thêm lịch học đầu tiên.',
                      style: TextStyle(color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _showScheduleDialog(
                        preselectedSubjectCode: widget.subject.maMonHoc,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm lịch học'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _subjectSchedules.length,
              itemBuilder: (context, index) {
                final s = _subjectSchedules[index];
                final room = s['classroom'];
                final roomText = room != null
                    ? 'Phòng: ${room['tenPhong']} (${room['toaNha']})'
                    : 'Chưa xếp phòng';
                final regList = s['registrations'] as List? ?? [];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      child: Icon(
                        Icons.calendar_month,
                        color: s['isConfirmed'] == true
                            ? Colors.green
                            : Colors.purple,
                      ),
                    ),
                    title: Text(
                      '${s['thuTrongTuan']} - ${s['caHoc']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'GV: ${s['lecturer']?['hoTen'] ?? 'Chưa phân công'}\n'
                      'Thời gian: ${_formatDate(s['ngayBatDau'])} - ${_formatDate(s['ngayKetThuc'])}\n'
                      '$roomText\n'
                      'Trạng thái: ${s['isConfirmed'] == true ? "Đã xác nhận" : "Chưa xác nhận"} (${regList.length}/10 HS)',
                    ),
                    children: [
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Danh sách sinh viên đã đăng ký:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      if (regList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Chưa có sinh viên nào đăng ký lớp học này.',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: regList.length,
                          itemBuilder: (context, i) {
                            final student = regList[i]['student'];
                            if (student == null) return const SizedBox.shrink();
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.person, size: 18),
                              title: Text(
                                '${student['hoTen']} (${student['maSV']})',
                              ),
                              subtitle: Text('Lớp: ${student['lop'] ?? 'N/A'}'),
                            );
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (s['isConfirmed'] == true) ...[
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.undo, size: 16),
                                label: const Text('Hủy xác nhận'),
                                onPressed: () =>
                                    _setScheduleConfirmation(s['id'], false),
                              ),
                              const SizedBox(width: 8),
                            ] else ...[
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('Xác nhận lịch'),
                                onPressed: () =>
                                    _setScheduleConfirmation(s['id'], true),
                              ),
                              const SizedBox(width: 8),
                            ],
                            TextButton.icon(
                              icon: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.blue,
                              ),
                              label: const Text(
                                'Sửa',
                                style: TextStyle(color: Colors.blue),
                              ),
                              onPressed: () => _showScheduleDialog(
                                schedule: s,
                                preselectedSubjectCode: widget.subject.maMonHoc,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              icon: const Icon(
                                Icons.delete,
                                size: 16,
                                color: Colors.red,
                              ),
                              label: const Text(
                                'Xóa',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () => _deleteSchedule(s['id']),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: _subjectSchedules.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showScheduleDialog(
                preselectedSubjectCode: widget.subject.maMonHoc,
              ),
              backgroundColor: AppTheme.primaryBlue,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Thêm lịch',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
