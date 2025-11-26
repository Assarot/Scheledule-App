import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/refresh_token_response.dart';
import '../models/user_model.dart';
import '../../utils/api_config.dart';

class AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  Future<LoginResponse> login(LoginRequest request, bool rememberMe) async {
    final endpoint = rememberMe
        ? '${ApiConfig.baseUrl}${ApiConfig.loginRememberPath}'
        : '${ApiConfig.baseUrl}${ApiConfig.loginPath}';

    print('🔐 Attempting login to: $endpoint');
    print('🔐 Request body: ${jsonEncode(request.toJson())}');

    try {
      final response = await client
          .post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Timeout: El servidor no respondió en 10 segundos',
              );
            },
          );

      print('🔐 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          final loginResponse = LoginResponse.fromJson(jsonResponse);

          // Decodificar el JWT para obtener información del usuario
          final tokenParts = loginResponse.accessToken.split('.');
          if (tokenParts.length != 3) {
            throw Exception('Token JWT inválido');
          }

          // Decodificar el payload (segunda parte del JWT)
          final payloadBase64 = tokenParts[1];
          final normalizedPayload = base64Url.normalize(payloadBase64);
          final payloadString = utf8.decode(
            base64Url.decode(normalizedPayload),
          );
          final payload = jsonDecode(payloadString) as Map<String, dynamic>;

          // Extraer información del payload del JWT
          final userId = payload['userId'] as int?;
          final userProfileId = payload['userProfileId'] as int?;
          final username = payload['sub'] as String?;
          final roles =
              (payload['roles'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];

          print(
            'JWT payload - userId: $userId, userProfileId: $userProfileId, username: $username',
          );

          if (userId == null || username == null) {
            throw Exception('Token no contiene información de usuario válida');
          }

          // Crear un UserModel con la información del JWT
          final user = UserModel(
            id: userId.toString(),
            username: username,
            email: username,
            name: username,
            lastName: '',
            roles: roles,
            userProfileId: userProfileId,
          );

          // Crear una nueva respuesta con los datos del usuario
          return LoginResponse(
            accessToken: loginResponse.accessToken,
            refreshToken:
                loginResponse.refreshToken ?? loginResponse.accessToken,
            tokenType: loginResponse.tokenType,
            expiresIn: loginResponse.expiresIn,
            user: user,
          );
        } catch (e) {
          print('Error parsing login response: $e');
          throw Exception('Error al procesar respuesta del servidor: $e');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Credenciales inválidas');
      } else {
        throw Exception('Error al iniciar sesión: ${response.statusCode}');
      }
    } catch (e) {
      print('🔐 Login error: $e');
      rethrow;
    }
  }

  Future<RefreshTokenResponse> refreshToken(String refreshToken) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.refreshPath}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      return RefreshTokenResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al refrescar token');
    }
  }
}
