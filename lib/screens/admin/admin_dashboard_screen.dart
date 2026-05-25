import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';
import 'manage_students_screen.dart';
import 'manage_subjects_screen.dart';
import 'manage_semesters_screen.dart';
import 'admin_semester_flow_screen.dart';
import 'admin_subject_semester_flow_screen.dart';
import 'manage_semesters_screen.dart';
import 'manage_classrooms_screen.dart';
import 'manage_schedules_screen.dart';
import 'manage_materials_screen.dart';
import '../../utils/theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Bảng Điều Khiển'),
        elevation: 0,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeCard(user?.hoTen ?? "Admin"),
            const SizedBox(height: 24),
            const Text(
              'Quản lý hệ thống',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  context,
                  title: 'Nhập điểm',
                  subtitle: 'Theo lớp & SV',
                  icon: Icons.edit_document,
                  color: const Color(0xFFE53935), // Red
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSemesterFlowScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: 'Sinh Viên',
                  subtitle: 'QL Hồ sơ SV',
                  icon: Icons.people,
                  color: const Color(0xFFF57C00), // Orange
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageStudentsScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: 'Môn Học',
                  subtitle: 'Khung chương trình',
                  icon: Icons.book,
                  color: const Color(0xFF43A047), // Green
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSubjectSemesterFlowScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: 'Học Kỳ',
                  subtitle: 'QL Thời gian',
                  icon: Icons.calendar_month,
                  color: const Color(0xFF8E24AA),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageSemestersScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: 'Phòng học',
                  subtitle: 'QL Tòa nhà, Sức chứa',
                  icon: Icons.room,
                  color: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageClassroomsScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: 'Lịch học',
                  subtitle: 'QL Lịch giảng dạy',
                  icon: Icons.calendar_month,
                  color: Colors.indigo,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageSchedulesScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: 'Tài liệu',
                  subtitle: 'QL File & Đường dẫn',
                  icon: Icons.description,
                  color: Colors.brown,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageMaterialsScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String name) {
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
          const Icon(Icons.admin_panel_settings, size: 48, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'Xin chào, $name',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Trung tâm điều hành Quản lý Đào tạo',
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
