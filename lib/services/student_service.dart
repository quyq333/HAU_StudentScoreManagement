import 'package:dio/dio.dart';
import '../utils/app_constants.dart';
import 'api_client.dart';
import '../models/semester_model.dart';
import '../models/subject_result_model.dart';
import '../models/subject_model.dart';

class StudentService {
  Future<List<SubjectModel>> getSubjects() async {
    try {
      final response = await ApiClient.dio.get('/subjects');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SubjectModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

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
      final response = await ApiClient.dio.get(
        AppConstants.failedSubjectsEndpoint,
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

  Future<List<dynamic>> getSchedulesBySubject(String subjectId) async {
    try {
      final response = await ApiClient.dio.get(
        '${AppConstants.schedulesEndpoint}/subject/$subjectId',
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getMaterialsBySubject(String subjectId) async {
    try {
      final response = await ApiClient.dio.get(
        '${AppConstants.materialsEndpoint}/subject/$subjectId',
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getSchedulesByStudent(String maSV) async {
    try {
      final response = await ApiClient.dio.get(
        '${AppConstants.schedulesEndpoint}/student/$maSV',
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getExamSchedulesByStudent(String maSV) async {
    try {
      final response = await ApiClient.dio.get(
        '${AppConstants.examSchedulesEndpoint}/student/$maSV',
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getMaterialsByStudent(String maSV) async {
    try {
      final response = await ApiClient.dio.get(
        '${AppConstants.materialsEndpoint}/student/$maSV',
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<String?> registerSchedule(String maSV, int scheduleId) async {
    try {
      final response = await ApiClient.dio.post(
        '${AppConstants.schedulesEndpoint}/register',
        data: {'maSV': maSV, 'scheduleId': scheduleId},
      );
      if (response.statusCode == 200) {
        return null; // success
      }
      return 'Không thể đăng ký';
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response?.data?.toString() ?? 'Có lỗi xảy ra khi đăng ký';
      }
      return 'Có lỗi xảy ra khi đăng ký';
    }
  }

  Future<String?> cancelRegistration(String maSV, int scheduleId) async {
    try {
      final response = await ApiClient.dio.delete(
        '${AppConstants.schedulesEndpoint}/cancel',
        queryParameters: {'maSV': maSV, 'scheduleId': scheduleId},
      );
      if (response.statusCode == 200) {
        return null; // success
      }
      return 'Không thể hủy đăng ký';
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response?.data?.toString() ?? 'Có lỗi xảy ra khi hủy đăng ký';
      }
      return 'Có lỗi xảy ra khi hủy đăng ký';
    }
  }

  Future<List<dynamic>> getRegisteredSchedules(String maSV) async {
    try {
      final response = await ApiClient.dio.get(
        '${AppConstants.schedulesEndpoint}/registered/$maSV',
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<SubjectResultModel>> getAllResults() async {
    try {
      final response = await ApiClient.dio.get(AppConstants.resultsEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SubjectResultModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
