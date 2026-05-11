import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../models/subject_result_model.dart';

class SubjectResultScreen extends StatefulWidget {
  final int semesterId;
  final String semesterName;

  const SubjectResultScreen({
    super.key,
    required this.semesterId,
    required this.semesterName,
  });

  @override
  State<SubjectResultScreen> createState() => _SubjectResultScreenState();
}

class _SubjectResultScreenState extends State<SubjectResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchResultsForSemester(widget.semesterId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final results = studentProvider.currentSemesterResults;

    return Scaffold(
      appBar: AppBar(
        title: Text('Điểm ${widget.semesterName}'),
      ),
      body: studentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : results.isEmpty
              ? const Center(child: Text('Chưa có dữ liệu điểm cho học kỳ này'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return _buildResultCard(context, result);
                  },
                ),
    );
  }

  Widget _buildResultCard(BuildContext context, SubjectResultModel result) {
    final bool isPassed = result.diemTongKet >= 4.0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${result.maMonHoc} - ${result.tenMonHoc}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPassed ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result.diemChu,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPassed ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Số tín chỉ: ${result.soTinChi}'),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildScoreItem('Chuyên cần', result.diemChuyenCan),
                _buildScoreItem('Kiểm tra', result.diemKiemTra),
                _buildScoreItem('Thi', result.diemThi),
                _buildScoreItem('Tổng kết', result.diemTongKet, isBold: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, double score, {bool isBold = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          score.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
