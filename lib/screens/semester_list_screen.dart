import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import 'subject_list_screen.dart';

class SemesterListScreen extends StatelessWidget {
  const SemesterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final semesters = studentProvider.semesters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Học kỳ'),
      ),
      body: studentProvider.isLoading && semesters.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: semesters.length,
              itemBuilder: (context, index) {
                final semester = semesters[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(
                      semester.tenHocKy,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text('Năm học: ${semester.namHoc}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubjectListScreen(semesterId: semester.id, semesterName: semester.tenHocKy),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
