class AppConstants {
  // Thay thế bằng địa chỉ IP của máy bạn nếu test trên thiết bị thật
  // 10.0.2.2 là localhost cho Android Emulator
  static const String baseUrl = 'http://10.65.130.55:8080/api/v1';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String profileEndpoint = '/student/profile';
  static const String semestersEndpoint = '/semesters';
  static const String resultsEndpoint = '/results';
  static const String gpaEndpoint = '/results/gpa';
  static const String failedSubjectsEndpoint = '/results/failed';

  // Admin Endpoints
  static const String adminStudentsEndpoint = '/admin/students';
  static const String adminSubjectsEndpoint = '/admin/subjects';
  static const String adminSemestersEndpoint = '/admin/semesters';
  static const String adminResultsEndpoint = '/admin/results';
  static const String adminClassroomsEndpoint = '/admin/classrooms';
  static const String adminSchedulesEndpoint = '/admin/schedules';
  static const String adminExamSchedulesEndpoint = '/admin/exam-schedules';
  static const String adminMaterialsEndpoint = '/admin/materials';
  static const String adminLecturersEndpoint = '/admin/lecturers';

  // Student Endpoints
  static const String schedulesEndpoint = '/schedules';
  static const String examSchedulesEndpoint = '/exam-schedules';
  static const String materialsEndpoint = '/materials';

  // Shared Preferences Keys
  static const String tokenKey = 'jwt_token';
  static const String userKey = 'user_data';
}
