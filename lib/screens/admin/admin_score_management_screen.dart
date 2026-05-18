import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../models/user_model.dart';
import '../../models/subject_model.dart';
import '../../models/subject_result_model.dart';
import '../../utils/theme.dart';

class AdminScoreManagementScreen extends StatefulWidget {
  final int semesterId;
  final UserModel student;

  const AdminScoreManagementScreen({
    super.key,
    required this.semesterId,
    required this.student,
  });

  @override
  State<AdminScoreManagementScreen> createState() => _AdminScoreManagementScreenState();
}

class _AdminScoreManagementScreenState extends State<AdminScoreManagementScreen> {
  final AdminApiService _apiService = AdminApiService();
  List<SubjectModel> _subjects = [];
  List<SubjectResultModel> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final subjects = await _apiService.getSubjectsBySemester(widget.semesterId);
    final results = await _apiService.getResultsByStudentAndSemester(widget.student.maSV, widget.semesterId);
    
    setState(() {
      _subjects = subjects;
      _results = results;
      _isLoading = false;
    });
  }

  SubjectResultModel? _getResultForSubject(String maMonHoc) {
    try {
      return _results.firstWhere((r) => r.maMonHoc == maMonHoc);
    } catch (e) {
      return null;
    }
  }

  void _showScoreDialog(SubjectModel subject, SubjectResultModel? existingResult) {
    final ccController = TextEditingController(text: existingResult?.diemChuyenCan.toString() ?? '');
    final ktController = TextEditingController(text: existingResult?.diemKiemTra.toString() ?? '');
    final thiController = TextEditingController(text: existingResult?.diemThi.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nhập điểm: ${subject.tenMonHoc}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ccController,
                decoration: const InputDecoration(labelText: 'Điểm chuyên cần'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ktController,
                decoration: const InputDecoration(labelText: 'Điểm kiểm tra'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: thiController,
                decoration: const InputDecoration(labelText: 'Điểm thi'),
                keyboardType: TextInputType.number,
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
              final payload = {
                'maSV': widget.student.maSV,
                'maMonHoc': subject.maMonHoc,
                'idHocKy': widget.semesterId,
                'diemChuyenCan': double.tryParse(ccController.text),
                'diemKiemTra': double.tryParse(ktController.text),
                'diemThi': double.tryParse(thiController.text),
              };

              bool success;
              if (existingResult != null) {
                success = await _apiService.updateResult(existingResult.id, payload);
              } else {
                success = await _apiService.createResult(payload);
              }

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu điểm thành công')));
                  _loadData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi lưu điểm')));
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Điểm: ${widget.student.hoTen}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
              ? const Center(child: Text('Không có môn học nào trong học kỳ này'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    final result = _getResultForSubject(subject.maMonHoc);
                    final hasScore = result != null;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        title: Text(
                          subject.tenMonHoc,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Mã MH: ${subject.maMonHoc} • ${subject.soTinChi} TC'),
                            const SizedBox(height: 4),
                            if (hasScore)
                              Text(
                                'Tổng kết: ${result.diemTongKet} • Chữ: ${result.diemChu} • Hệ 4: ${result.diemHe4}',
                                style: TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else
                              const Text(
                                'Chưa nhập điểm',
                                style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasScore ? Colors.orange : AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: () => _showScoreDialog(subject, result),
                          child: Text(hasScore ? 'Sửa' : 'Nhập'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
