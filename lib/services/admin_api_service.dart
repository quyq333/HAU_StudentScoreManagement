import 'package:dio/dio.dart';
import '../utils/app_constants.dart';
import 'api_client.dart';
import '../models/user_model.dart';
import '../models/semester_model.dart';
import '../models/subject_model.dart';
import '../models/subject_result_model.dart';

class AdminApiService {
  // --- Students ---
  Future<List<UserModel>> getStudents() async {
    try {
      final response = await ApiClient.dio.get(AppConstants.adminStudentsEndpoint);
      return (response.data as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getClasses() async {
    try {
      final response = await ApiClient.dio.get('${AppConstants.adminStudentsEndpoint}/classes');
      return List<String>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> getStudentsByClass(String className) async {
    try {
      final response = await ApiClient.dio.get('${AppConstants.adminStudentsEndpoint}/class/$className');
      return (response.data as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createStudent(Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.post(AppConstants.adminStudentsEndpoint, data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStudent(String maSV, Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.put('${AppConstants.adminStudentsEndpoint}/$maSV', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteStudent(String maSV) async {
    try {
      await ApiClient.dio.delete('${AppConstants.adminStudentsEndpoint}/$maSV');
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- Subjects ---
  Future<List<SubjectModel>> getSubjects() async {
    try {
      final response = await ApiClient.dio.get(AppConstants.adminSubjectsEndpoint);
      return (response.data as List).map((e) => SubjectModel.fromJson(e)).toList();
    } catch (e) {
      print('Error getSubjects: $e');
      return [];
    }
  }

  Future<List<SubjectModel>> getSubjectsBySemester(int semesterId) async {
    try {
      final response = await ApiClient.dio.get('${AppConstants.adminSubjectsEndpoint}/semester/$semesterId');
      return (response.data as List).map((e) => SubjectModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createSubject(Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.post(AppConstants.adminSubjectsEndpoint, data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateSubject(String maMonHoc, Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.put('${AppConstants.adminSubjectsEndpoint}/$maMonHoc', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSubject(String maMonHoc) async {
    try {
      await ApiClient.dio.delete('${AppConstants.adminSubjectsEndpoint}/$maMonHoc');
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- Semesters ---
  Future<List<SemesterModel>> getSemesters() async {
    try {
      final response = await ApiClient.dio.get(AppConstants.adminSemestersEndpoint);
      return (response.data as List).map((e) => SemesterModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createSemester(Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.post(AppConstants.adminSemestersEndpoint, data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateSemester(int id, Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.put('${AppConstants.adminSemestersEndpoint}/$id', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSemester(int id) async {
    try {
      await ApiClient.dio.delete('${AppConstants.adminSemestersEndpoint}/$id');
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- Results ---
  Future<List<Map<String, dynamic>>> getResults() async {
    try {
      final response = await ApiClient.dio.get(AppConstants.adminResultsEndpoint);
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  Future<List<SubjectResultModel>> getResultsByStudentAndSemester(String studentId, int semesterId) async {
    try {
      final response = await ApiClient.dio.get('${AppConstants.adminResultsEndpoint}/student/$studentId/semester/$semesterId');
      return (response.data as List).map((e) => SubjectResultModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createResult(Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.post(AppConstants.adminResultsEndpoint, data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateResult(int id, Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.put('${AppConstants.adminResultsEndpoint}/$id', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteResult(int id) async {
    try {
      await ApiClient.dio.delete('${AppConstants.adminResultsEndpoint}/$id');
      return true;
    } catch (e) {
      return false;
    }
  }
}
