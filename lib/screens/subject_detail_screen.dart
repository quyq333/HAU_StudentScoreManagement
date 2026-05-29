import 'package:flutter/material.dart';
import '../models/subject_result_model.dart';
import '../models/schedule_model.dart';
import '../models/study_material_model.dart';
import '../services/student_service.dart';
import '../utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SubjectDetailScreen extends StatefulWidget {
  final SubjectResultModel result;

  const SubjectDetailScreen({super.key, required this.result});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  final StudentService _studentService = StudentService();
  bool _isLoading = true;
  List<Schedule> _schedules = [];
  List<StudyMaterial> _materials = [];

  @override
  void initState() {
    super.initState();
    _loadExtraData();
  }

  bool get _hasGradeA => widget.result.diemChu.toUpperCase() == 'A';

  Future<void> _loadExtraData() async {
    setState(() => _isLoading = true);
    try {
      final schedulesData = _hasGradeA
          ? <dynamic>[]
          : await _studentService.getSchedulesBySubject(widget.result.maMonHoc);
      final materialsData = await _studentService.getMaterialsBySubject(
        widget.result.maMonHoc,
      );

      if (mounted) {
        setState(() {
          _schedules = schedulesData.map((e) => Schedule.fromJson(e)).toList();
          _materials = materialsData
              .map((e) => StudyMaterial.fromJson(e))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPassed = widget.result.diemTongKet >= 4.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết môn học'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(context, isPassed),
                  const SizedBox(height: 24),
                  _buildScoresGrid(context),
                  const SizedBox(height: 24),
                  _buildStatusCard(context, isPassed),
                  const SizedBox(height: 24),
                  _buildSchedules(context),
                  const SizedBox(height: 24),
                  _buildMaterials(context),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isPassed) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.result.maMonHoc,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.result.tenMonHoc,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.menu_book, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                '${widget.result.soTinChi} Tín chỉ',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isPassed ? Colors.greenAccent : Colors.redAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.result.diemChu,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoresGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chi tiết điểm',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildScoreTile(
              'Chuyên cần',
              widget.result.diemChuyenCan,
              Icons.fact_check,
            ),
            _buildScoreTile(
              'Giữa kỳ',
              widget.result.diemKiemTra,
              Icons.assignment,
            ),
            _buildScoreTile('Cuối kỳ', widget.result.diemThi, Icons.school),
            _buildScoreTile(
              'Tổng kết',
              widget.result.diemTongKetHienThi,
              Icons.stars,
              isHighlighted: true,
            ),
            _buildScoreTile(
              'Hệ 4',
              widget.result.diemHe4,
              Icons.grade,
              isHighlighted: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreTile(
    String title,
    Object score,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    final scoreText = score is num
        ? score.toStringAsFixed(1)
        : score.toString();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppTheme.primaryBlue.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted
              ? AppTheme.primaryBlue.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isHighlighted
                    ? AppTheme.primaryBlue
                    : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            scoreText,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? AppTheme.primaryBlue : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, bool isPassed) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPassed ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPassed ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPassed ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPassed ? Icons.check : Icons.close,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trạng thái môn học',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  isPassed ? 'Đạt' : 'Chưa đạt (Cần học lại)',
                  style: TextStyle(
                    color: isPassed
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedules(BuildContext context) {
    if (_hasGradeA) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Bạn đã đạt điểm A môn này. Lịch học hiện có sẽ không hiển thị.',
                style: TextStyle(
                  color: Colors.brown.shade800,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_schedules.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lịch học',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 16),
        ..._schedules
            .map(
              (schedule) => Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    child: const Icon(
                      Icons.calendar_month,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  title: Text(
                    '${schedule.thuTrongTuan} - ${schedule.caHoc}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Thời gian: ${_formatDate(schedule.ngayBatDau)} - ${_formatDate(schedule.ngayKetThuc)}\n'
                    'Phòng: ${schedule.classroom?.tenPhong ?? ''} | GV: ${schedule.lecturer?.hoTen ?? ''}',
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildMaterials(BuildContext context) {
    if (_materials.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tài liệu học tập',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 16),
        ..._materials
            .map(
              (material) {
                final typeColor = _getTypeColor(material.loaiTaiLieu);
                final typeIcon = _getTypeIcon(material.loaiTaiLieu);
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    onTap: () async {
                      if (material.duongDan != null && material.duongDan!.isNotEmpty) {
                        final Uri url = Uri.parse(material.duongDan!);
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Không thể mở liên kết: ${material.duongDan}')),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tài liệu này không có liên kết hợp lệ')),
                        );
                      }
                    },
                    leading: CircleAvatar(
                      backgroundColor: typeColor.withOpacity(0.1),
                      child: Icon(typeIcon, color: typeColor),
                    ),
                    title: Text(
                      material.tenTaiLieu,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            material.loaiTaiLieu ?? 'LINK',
                            style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.open_in_new, color: AppTheme.primaryBlue, size: 20),
                    isThreeLine: false,
                  ),
                );
              },
            )
            .toList(),
      ],
    );
  }

  Color _getTypeColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'PDF':
        return Colors.red;
      case 'DOCX':
        return Colors.blue;
      case 'VIDEO':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'DOCX':
        return Icons.description;
      case 'VIDEO':
        return Icons.play_circle;
      default:
        return Icons.link;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
