import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import 'student_schedule_screen.dart';
import 'student_exam_schedule_screen.dart';

class StudentSchedulesGroupScreen extends StatelessWidget {
  const StudentSchedulesGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch Trình'),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.calendar_month), text: 'Lịch Học'),
              Tab(icon: Icon(Icons.event_available), text: 'Lịch Thi'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            StudentScheduleScreen(showAppBar: false),
            StudentExamScheduleScreen(showAppBar: false),
          ],
        ),
      ),
    );
  }
}
