import 'package:dio/dio.dart';
import '../utils/app_constants.dart';
import 'api_client.dart';
import '../models/semester_model.dart';
import '../models/subject_result_model.dart';

class StudentService {
  Future<List<SemesterModel>> getSemesters() async {
    try {
      final response = await ApiClient.dio.get(AppConstants.semestersEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SemesterModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<SubjectResultModel>> getResultsBySemester(int semesterId) async {
    try {
      final response = await ApiClient.dio.get(
        '${AppConstants.resultsEndpoint}/$semesterId',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SubjectResultModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<SubjectResultModel>> getFailedSubjects() async {
    try {
      final response = await ApiClient.dio.get(AppConstants.failedSubjectsEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SubjectResultModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<GpaModel?> getGpaStats() async {
    try {
      final response = await ApiClient.dio.get(AppConstants.gpaEndpoint);
      if (response.statusCode == 200) {
        return GpaModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
