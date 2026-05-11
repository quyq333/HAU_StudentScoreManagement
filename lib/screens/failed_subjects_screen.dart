import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';

class FailedSubjectsScreen extends StatelessWidget {
  const FailedSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final failedSubjects = studentProvider.failedSubjects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Các Môn Chưa Đạt'),
        backgroundColor: Colors.red.shade700,
      ),
      body: failedSubjects.isEmpty
          ? const Center(
              child: Text('Chúc mừng! Bạn không có môn học nào chưa đạt.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: failedSubjects.length,
              itemBuilder: (context, index) {
                final subject = failedSubjects[index];
                return Card(
                  color: Colors.red.shade50,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const Icon(Icons.error_outline, color: Colors.red),
                    title: Text(
                      subject.tenMonHoc,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Mã MH: ${subject.maMonHoc} | Số TC: ${subject.soTinChi}'),
                    trailing: Text(
                      'Tổng kết: ${subject.diemTongKet}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
