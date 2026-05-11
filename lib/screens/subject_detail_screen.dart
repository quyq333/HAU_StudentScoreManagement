import 'package:flutter/material.dart';
import '../models/subject_result_model.dart';
import '../utils/theme.dart';

class SubjectDetailScreen extends StatelessWidget {
  final SubjectResultModel result;

  const SubjectDetailScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isPassed = result.diemTongKet >= 4.0;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết môn học'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(context, isPassed),
            const SizedBox(height: 24),
            _buildScoresGrid(context),
            const SizedBox(height: 24),
            _buildStatusCard(context, isPassed),
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
          colors: [
            AppTheme.primaryBlue,
            AppTheme.secondaryBlue,
          ],
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
              result.maMonHoc,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            result.tenMonHoc,
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
                '${result.soTinChi} Tín chỉ',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isPassed ? Colors.greenAccent : Colors.redAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  result.diemChu,
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
            _buildScoreTile('Chuyên cần', result.diemChuyenCan, Icons.fact_check),
            _buildScoreTile('Giữa kỳ', result.diemKiemTra, Icons.assignment),
            _buildScoreTile('Cuối kỳ', result.diemThi, Icons.school),
            _buildScoreTile('Tổng kết', result.diemTongKet, Icons.stars, isHighlighted: true),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreTile(String title, double score, IconData icon, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted ? AppTheme.primaryBlue.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted ? AppTheme.primaryBlue.withOpacity(0.3) : Colors.grey.shade200,
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
              Icon(icon, size: 16, color: isHighlighted ? AppTheme.primaryBlue : Colors.grey.shade600),
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
            score.toStringAsFixed(1),
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
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPassed ? 'Đạt' : 'Chưa đạt (Cần học lại)',
                  style: TextStyle(
                    color: isPassed ? Colors.green.shade700 : Colors.red.shade700,
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
}
