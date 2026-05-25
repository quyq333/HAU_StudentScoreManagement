import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/student_provider.dart';
import 'failed_subjects_screen.dart';
import 'student/student_schedule_screen.dart';
import 'student/student_material_screen.dart';
import 'student/register_schedule_screen.dart';

class GpaDashboardScreen extends StatelessWidget {
  const GpaDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final gpaStats = studentProvider.gpaStats;
    final theme = Theme.of(context);

    if (studentProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Tổng quan Học tập'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.primary,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Text(
              'Chào bạn,',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const Text(
              'Tiến độ học tập của bạn',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildGradientCard(
                    context, 
                    'GPA Tích lũy', 
                    gpaStats != null ? gpaStats.cumulativeGpa.toStringAsFixed(2) : '0.0',
                    Icons.trending_up,
                    [const Color(0xFF1E88E5), const Color(0xFF1565C0)],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGradientCard(
                    context, 
                    'Tín chỉ', 
                    gpaStats != null ? gpaStats.totalCredits.toString() : '0',
                    Icons.school,
                    [const Color(0xFF00ACC1), const Color(0xFF00838F)],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Quick Actions Row
            Row(
              children: [
                Expanded(
                  child: _buildGradientCard(
                    context, 
                    'Lịch Học', 
                    'Xem ngay',
                    Icons.calendar_month,
                    [const Color(0xFF8E24AA), const Color(0xFF6A1B9A)],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentScheduleScreen())),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGradientCard(
                    context, 
                    'Tài Liệu', 
                    'Mới nhất',
                    Icons.description,
                    [const Color(0xFF00ACC1), const Color(0xFF00838F)],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentMaterialScreen())),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Premium Register Schedule Card
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScheduleScreen())),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD32F2F).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_task, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đăng ký Lịch học',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'Biểu đồ GPA các kỳ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Chart Card
            Container(
              height: 280,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: gpaStats == null || gpaStats.semesterGpas.isEmpty 
                  ? const Center(child: Text('Chưa có dữ liệu GPA qua các kỳ'))
                  : LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, 
                        reservedSize: 30, 
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt() - 1;
                          if (index >= 0 && index < gpaStats.semesterGpas.length) {
                            String semName = gpaStats.semesterGpas[index].semesterName;
                            String shortName = semName.contains("1") ? "HK1" 
                                             : semName.contains("2") ? "HK2" 
                                             : semName.contains("3") ? "HK3" 
                                             : "HK";
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(shortName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 1,
                  maxX: gpaStats.semesterGpas.length.toDouble(),
                  minY: 0,
                  maxY: 4,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(gpaStats.semesterGpas.length, (index) {
                        return FlSpot((index + 1).toDouble(), gpaStats.semesterGpas[index].gpa);
                      }),
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                      ),
                      barWidth: 5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 6,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: const Color(0xFF1976D2),
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF64B5F6).withOpacity(0.3),
                            const Color(0xFF1976D2).withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            if (studentProvider.failedSubjects.isNotEmpty)
              _buildWarningCard(context, studentProvider.failedSubjects.length),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientCard(BuildContext context, String title, String value, IconData icon, List<Color> gradientColors, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors[1].withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildWarningCard(BuildContext context, int count) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FailedSubjectsScreen()),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.shade100, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade100.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_rounded, color: Colors.red, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cần chú ý',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  Text(
                    'Bạn có $count môn chưa đạt',
                    style: TextStyle(color: Colors.red.shade400),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
          ],
        ),
      ),
    );
  }
}
