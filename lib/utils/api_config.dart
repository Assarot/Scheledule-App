class ApiConfig {
  // IMPORTANTE: Configura esta URL según tu entorno

  // Para emulador Android (usa 10.0.2.2 para localhost de tu máquina)
  // static const String baseUrl = 'http://10.0.2.2:8080';

  // Para dispositivo físico en la misma red (usa la IP de tu máquina)
  static const String baseUrl = 'http://192.168.1.66:8080';

  // Para iOS Simulator (usa localhost)
  // static const String baseUrl = 'http://localhost:8080';

  // Para producción
  // static const String baseUrl = 'https://tu-backend.com';

  // Endpoints
  static const String authPath = '/api/auth';
  static const String loginPath = '$authPath/login';
  static const String loginRememberPath = '$authPath/login/remember';
  static const String registerPath = '$authPath/register';
  static const String refreshPath = '$authPath/refresh';
  
  // Course Management Endpoints (Puerto 8083 a través del Gateway 8080)
  static const String courseBasePath = '/api/courses';
  static const String coursesPath = '$courseBasePath/course/v1/api';
  static const String courseTypesPath = '$courseBasePath/course-type/v1/api';
  static const String teachersPath = '$courseBasePath/teacher/v1/api';
  static const String plansPath = '$courseBasePath/plan/v1/api';
  static const String groupsPath = '$courseBasePath/group/v1/api';
  static const String cyclesPath = '$courseBasePath/cycle/v1/api';
  static const String professionalSchoolsPath = '$courseBasePath/professional-school/v1/api';
  static const String courseAssignmentsPath = '$courseBasePath/course-assignment/v1/api';
}
