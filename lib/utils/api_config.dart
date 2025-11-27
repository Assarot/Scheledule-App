class ApiConfig {
  // IMPORTANTE: Configura esta URL según tu entorno

  // Para emulador Android (usa 10.0.2.2 para localhost de tu máquina)
  // static const String baseUrl = 'http://10.0.2.2:8080';

  // Para dispositivo físico en la misma red (usa la IP de tu máquina)
  // static const String baseUrl = 'http://192.168.0.45:8080';

  static const String baseUrl = 'http://172.17.26.38:8080';

  // Endpoints
  static const String authPath = '/microservice-auth/api/auth';
  static const String loginPath = '$authPath/login';
  static const String loginRememberPath = '$authPath/login/remember';
  static const String registerPath = '$authPath/register';
  static const String refreshPath = '$authPath/refresh';
}
