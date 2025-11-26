import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_user_response_dto.dart';
import '../../utils/api_config.dart';

class AuthUserRemoteDataSource {
  final http.Client client;

  AuthUserRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  /// Obtener información del usuario autenticado usando el endpoint /me
  Future<AuthUserResponseDto> getCurrentUser(String accessToken) async {
    final url = '${ApiConfig.baseUrl}/microservice-auth/api/auth/me';

    print('Calling /me endpoint: $url');
    print('Token (first 20 chars): ${accessToken.substring(0, 20)}...');

    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('Response status from /me: ${response.statusCode}');
    print('Response body from /me: ${response.body}');

    if (response.statusCode == 200) {
      return AuthUserResponseDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al obtener usuario actual: ${response.statusCode}',
      );
    }
  }
}
