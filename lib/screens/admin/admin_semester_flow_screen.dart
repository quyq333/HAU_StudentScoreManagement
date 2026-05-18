import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../models/semester_model.dart';
import '../../utils/theme.dart';
import 'admin_class_flow_screen.dart';

class AdminSemesterFlowScreen extends StatefulWidget {
  const AdminSemesterFlowScreen({super.key});

  @override
  State<AdminSemesterFlowScreen> createState() => _AdminSemesterFlowScreenState();
}

class _AdminSemesterFlowScreenState extends State<AdminSemesterFlowScreen> {
  final AdminApiService _apiService = AdminApiService();
  List<SemesterModel> _allSemesters = [];
  List<String> _years = [];
  String? _selectedYear;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSemesters();
  }

  Future<void> _loadSemesters() async {
    final data = await _apiService.getSemesters();
    final years = data
        .map((s) => s.namHoc)
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));

    setState(() {
      _allSemesters = data;
      _years = years;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(_selectedYear == null ? 'Chọn Năm Học' : 'Học kỳ - $_selectedYear'),
        leading: _selectedYear != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedYear = null;
                  });
                },
              )
            : const BackButton(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedYear == null
              ? _buildYearsList()
              : _buildSemestersList(),
    );
  }

  Widget _buildYearsList() {
    if (_years.isEmpty) {
      return const Center(child: Text('Không có dữ liệu năm học.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _years.length,
      itemBuilder: (context, index) {
        final year = _years[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
            ),
            title: Text(
              'Năm học $year',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              setState(() {
                _selectedYear = year;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildSemestersList() {
    final semestersInYear = _allSemesters.where((s) => s.namHoc == _selectedYear).toList();
    if (semestersInYear.isEmpty) {
      return const Center(child: Text('Năm học này không có học kỳ nào.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: semestersInYear.length,
      itemBuilder: (context, index) {
        final semester = semestersInYear[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              child: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.secondary),
            ),
            title: Text(
              semester.tenHocKy,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminClassFlowScreen(semesterId: semester.id, semesterName: '${semester.tenHocKy} ($_selectedYear)'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
