import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/student_service.dart';
import '../../models/subject_model.dart';
import '../../models/schedule_model.dart';
import '../../models/subject_result_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class RegisterScheduleScreen extends StatefulWidget {
  const RegisterScheduleScreen({super.key});

  @override
  State<RegisterScheduleScreen> createState() => _RegisterScheduleScreenState();
}

class _RegisterScheduleScreenState extends State<RegisterScheduleScreen> {
  final StudentService _studentService = StudentService();

  List<SubjectModel> _subjects = [];
  List<Schedule> _schedulesOfSelectedSubject = [];
  List<Schedule> _registeredSchedules = [];
  List<SubjectResultModel> _studentResults = [];

  String? _selectedSubjectId;
  bool _isLoading = true;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final subs = await _studentService.getSubjects();
      final regsData = await _studentService.getRegisteredSchedules(user.maSV);
      final results = await _studentService.getAllResults();

      setState(() {
        _subjects = subs;
        _registeredSchedules = regsData
            .map((e) => Schedule.fromJson(e))
            .toList();
        _studentResults = results;

        if (_subjects.isNotEmpty) {
          _selectedSubjectId = _subjects.first.maMonHoc;
        }
        _isLoading = false;
      });

      if (_selectedSubjectId != null && !_hasGradeA(_selectedSubjectId!)) {
        _loadSchedulesForSubject(_selectedSubjectId!);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSchedulesForSubject(String subjectId) async {
    if (_hasGradeA(subjectId)) {
      if (mounted) {
        setState(() {
          _schedulesOfSelectedSubject = [];
        });
      }
      return;
    }

    try {
      final data = await _studentService.getSchedulesBySubject(subjectId);
      if (!mounted ||
          _selectedSubjectId != subjectId ||
          _hasGradeA(subjectId)) {
        return;
      }
      setState(() {
        _schedulesOfSelectedSubject = data
            .map((e) => Schedule.fromJson(e))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi tải lịch học của môn')),
      );
    }
  }

  Future<void> _toggleRegistration(Schedule schedule, bool isRegistered) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    if (!isRegistered) {
      if (_hasRegisteredSubject(schedule)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn đã đăng ký một lịch học của môn này rồi.'),
          ),
        );
        return;
      }

      if (_hasTimeConflict(schedule)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lịch học này bị trùng với lịch đã đăng ký.'),
          ),
        );
        return;
      }
    }

    setState(() => _isActionLoading = true);

    try {
      String? error;
      if (isRegistered) {
        // Hủy đăng ký
        error = await _studentService.cancelRegistration(
          user.maSV,
          schedule.id,
        );
      } else {
        // Đăng ký mới
        error = await _studentService.registerSchedule(user.maSV, schedule.id);
      }

      if (error == null) {
        // Reload registered schedules
        final regsData = await _studentService.getRegisteredSchedules(
          user.maSV,
        );
        setState(() {
          _registeredSchedules = regsData
              .map((e) => Schedule.fromJson(e))
              .toList();
        });
        // Reload schedules of the selected subject to update counts
        if (_selectedSubjectId != null) {
          await _loadSchedulesForSubject(_selectedSubjectId!);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isRegistered
                    ? 'Đã hủy đăng ký thành công!'
                    : 'Đăng ký lịch học thành công!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại sau.')),
        );
      }
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  bool _hasGradeA(String subjectCode) {
    for (var r in _studentResults) {
      if (r.maMonHoc == subjectCode && r.diemChu.toUpperCase() == 'A') {
        return true;
      }
    }
    return false;
  }

  String _selectedSubjectName() {
    for (final subject in _subjects) {
      if (subject.maMonHoc == _selectedSubjectId) {
        return subject.tenMonHoc;
      }
    }
    return 'môn học này';
  }

  bool _hasRegisteredSubject(Schedule schedule) {
    final subjectCode = schedule.subject?.maMonHoc ?? _selectedSubjectId;
    if (subjectCode == null) return false;

    return _registeredSchedules.any(
      (registered) => registered.subject?.maMonHoc == subjectCode,
    );
  }

  bool _hasTimeConflict(Schedule schedule) {
    final subjectCode = schedule.subject?.maMonHoc ?? _selectedSubjectId;

    return _registeredSchedules.any((registered) {
      if (registered.id == schedule.id) return false;

      final registeredSubjectCode = registered.subject?.maMonHoc;
      if (subjectCode != null && registeredSubjectCode == subjectCode) {
        return false;
      }

      return _schedulesOverlap(registered, schedule);
    });
  }

  bool _schedulesOverlap(Schedule first, Schedule second) {
    if (first.thuTrongTuan != second.thuTrongTuan ||
        first.caHoc != second.caHoc) {
      return false;
    }

    final firstStart = first.ngayBatDau;
    final firstEnd = first.ngayKetThuc;
    final secondStart = second.ngayBatDau;
    final secondEnd = second.ngayKetThuc;

    if (firstStart == null ||
        firstEnd == null ||
        secondStart == null ||
        secondEnd == null) {
      return true;
    }

    return !firstStart.isAfter(secondEnd) && !secondStart.isAfter(firstEnd);
  }

  @override
  Widget build(BuildContext context) {
    final isA = _selectedSubjectId != null && _hasGradeA(_selectedSubjectId!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng Ký Lịch Học'),
        elevation: 0,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInitialData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card with beautiful HSL themed style
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0F2027),
                            Color(0xFF203A43),
                            Color(0xFF2C5364),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.cyanAccent,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Quy định Đăng ký',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '- Không được phép đăng ký nếu môn học đã đạt điểm A.\n'
                            '- Không thể tự hủy lịch sau khi lớp đã được khóa.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Dropdown for Subject Selection
                    const Text(
                      'Chọn Môn học cần Đăng ký',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedSubjectId,
                          hint: const Text('Chọn môn học'),
                          items: _subjects.map((sub) {
                            return DropdownMenuItem<String>(
                              value: sub.maMonHoc,
                              child: Text(
                                '${sub.tenMonHoc} (${sub.maMonHoc})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedSubjectId = val;
                                _schedulesOfSelectedSubject = [];
                              });
                              if (!_hasGradeA(val)) {
                                _loadSchedulesForSubject(val);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    if (isA) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.amber,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Bạn đã đạt điểm A môn ${_selectedSubjectName()}. Lịch học hiện có của môn này sẽ không hiển thị và hệ thống không cho phép đăng ký học lại.',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown.shade800,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Schedules List Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Danh sách Lịch học hiện có',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_isActionLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Schedules List view
                      if (_schedulesOfSelectedSubject.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 60,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Chưa có lịch học môn này',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _schedulesOfSelectedSubject.length,
                          itemBuilder: (context, index) {
                            final schedule = _schedulesOfSelectedSubject[index];

                            // Check if registered
                            final isReg = _registeredSchedules.any(
                              (r) => r.id == schedule.id,
                            );
                            final hasRegisteredSubject = _hasRegisteredSubject(
                              schedule,
                            );
                            final hasTimeConflict =
                                !hasRegisteredSubject &&
                                _hasTimeConflict(schedule);
                            final currentCount = schedule.registrations.length;
                            final isFull = currentCount >= 10;

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: isReg || hasRegisteredSubject
                                      ? Border.all(
                                          color: Colors.green.shade400,
                                          width: 2,
                                        )
                                      : hasTimeConflict
                                      ? Border.all(
                                          color: Colors.orange.shade400,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Row with Weekday, Slot and Confirmed Badge
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '${schedule.thuTrongTuan}',
                                                  style: TextStyle(
                                                    color: Colors.blue.shade800,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.purple.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '${schedule.caHoc}',
                                                  style: TextStyle(
                                                    color:
                                                        Colors.purple.shade800,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),

                                      // Classroom & Lecturer details
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.room_outlined,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Phòng: ${schedule.classroom?.tenPhong ?? ''} (${schedule.classroom?.toaNha ?? ''})',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person_outline,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Giảng viên: ${schedule.lecturer?.hoTen ?? ''} (${schedule.lecturer?.khoa ?? ''})',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.date_range_outlined,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Thời gian: ${_formatDate(schedule.ngayBatDau)} - ${_formatDate(schedule.ngayKetThuc)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24),

                                      // Capacity Count & Register Button Row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Student Registration count indicator
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.people_outline,
                                                size: 20,
                                                color: isFull
                                                    ? Colors.red
                                                    : Colors.green,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Sĩ số: ',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              Text(
                                                '$currentCount/10',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isFull
                                                      ? Colors.red
                                                      : Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Registration Action Button
                                          _buildActionButton(
                                            schedule,
                                            isReg,
                                            isA,
                                            isFull,
                                            hasRegisteredSubject,
                                            hasTimeConflict,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildActionButton(
    Schedule schedule,
    bool isReg,
    bool isA,
    bool isFull,
    bool hasRegisteredSubject,
    bool hasTimeConflict,
  ) {
    if (schedule.isConfirmed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isReg ? Colors.green.shade50 : Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isReg ? Colors.green.shade300 : Colors.blueGrey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isReg ? Icons.check_circle : Icons.lock,
              size: 14,
              color: isReg ? Colors.green.shade700 : Colors.blueGrey.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              isReg ? 'Lớp đã được xác nhận (Đã ĐK)' : 'Lớp đã được xác nhận',
              style: TextStyle(
                color: isReg ? Colors.green.shade700 : Colors.blueGrey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (isA) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.grey.shade200,
          disabledForegroundColor: Colors.grey.shade500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Khóa học'),
      );
    }

    if (isReg) {
      // Registered but Not Confirmed (Can cancel)
      return ElevatedButton.icon(
        onPressed: _isActionLoading
            ? null
            : () => _toggleRegistration(schedule, true),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(Icons.close, size: 16),
        label: const Text('Hủy Đăng ký'),
      );
    }

    if (hasRegisteredSubject) {
      return ElevatedButton.icon(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.green.shade50,
          disabledForegroundColor: Colors.green.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(Icons.check_circle, size: 16),
        label: const Text('Đã đăng ký'),
      );
    }

    if (hasTimeConflict) {
      return ElevatedButton.icon(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.orange.shade50,
          disabledForegroundColor: Colors.orange.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(Icons.warning_amber, size: 16),
        label: const Text('Trùng lịch'),
      );
    }

    if (isFull) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.grey.shade200,
          disabledForegroundColor: Colors.grey.shade500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Lớp đã đầy'),
      );
    }

    return ElevatedButton.icon(
      onPressed: _isActionLoading
          ? null
          : () => _toggleRegistration(schedule, false),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.add, size: 16),
      label: const Text('Đăng ký'),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
