import 'package:flutter/material.dart';
import '../models/semester_model.dart';
import '../models/subject_result_model.dart';
import '../services/student_service.dart';

class StudentProvider with ChangeNotifier {
  final StudentService _studentService = StudentService();

  bool _isLoading = false;
  List<SemesterModel> _semesters = [];
  List<SubjectResultModel> _currentSemesterResults = [];
  List<SubjectResultModel> _failedSubjects = [];
  GpaModel? _gpaStats;

  bool get isLoading => _isLoading;
  List<SemesterModel> get semesters => _semesters;
  List<SubjectResultModel> get currentSemesterResults => _currentSemesterResults;
  List<SubjectResultModel> get failedSubjects => _failedSubjects;
  GpaModel? get gpaStats => _gpaStats;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      fetchSemesters(),
      fetchGpaStats(),
      fetchFailedSubjects(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSemesters() async {
    _semesters = await _studentService.getSemesters();
    notifyListeners();
  }

  Future<void> fetchResultsForSemester(int semesterId) async {
    _isLoading = true;
    notifyListeners();

    _currentSemesterResults = await _studentService.getResultsBySemester(semesterId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFailedSubjects() async {
    _failedSubjects = await _studentService.getFailedSubjects();
    notifyListeners();
  }

  Future<void> fetchGpaStats() async {
    _gpaStats = await _studentService.getGpaStats();
    notifyListeners();
  }
}
