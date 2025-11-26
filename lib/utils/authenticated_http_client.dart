import 'package:http/http.dart' as http;
import '../data/datasources/auth_local_datasource.dart';
import '../data/datasources/auth_remote_datasource.dart';

class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner;
  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final Function()? onUnauthorized;

  AuthenticatedHttpClient({
    http.Client? client,
    required AuthLocalDataSource localDataSource,
    required AuthRemoteDataSource remoteDataSource,
    this.onUnauthorized,
  }) : _inner = client ?? http.Client(),
       _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  static const List<String> _publicRoutes = [
    '/microservice-auth/api/auth/login',
    '/microservice-auth/api/auth/login/remember',
    '/microservice-auth/api/auth/register',
    '/microservice-auth/api/auth/refresh',
  ];

  bool _isPublicRoute(String url) {
    return _publicRoutes.any((route) => url.contains(route));
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // No agregar token a rutas públicas
    if (!_isPublicRoute(request.url.toString())) {
      final accessToken = await _localDataSource.getAccessToken();
      if (accessToken != null) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    // Ejecutar la petición original
    var response = await _inner.send(request);

    // Si hay error de autenticación (401 o 403), intentar refrescar el token
    if ((response.statusCode == 401 || response.statusCode == 403) &&
        !_isPublicRoute(request.url.toString())) {
      final refreshToken = await _localDataSource.getRefreshToken();

      if (refreshToken != null) {
        try {
          // Intentar refrescar el token
          final refreshResponse = await _remoteDataSource.refreshToken(
            refreshToken,
          );
          await _localDataSource.saveAccessToken(refreshResponse.accessToken);

          // Reintentar la petición original con el nuevo token
          final newRequest = _copyRequest(request);
          newRequest.headers['Authorization'] =
              'Bearer ${refreshResponse.accessToken}';
          response = await _inner.send(newRequest);
        } catch (e) {
          // Si falla el refresh, cerrar sesión
          await _localDataSource.clearAll();
          onUnauthorized?.call();
        }
      } else {
        // No hay refresh token, cerrar sesión
        await _localDataSource.clearAll();
        onUnauthorized?.call();
      }
    }

    return response;
  }

  http.BaseRequest _copyRequest(http.BaseRequest request) {
    http.BaseRequest requestCopy;

    if (request is http.Request) {
      requestCopy = http.Request(request.method, request.url)
        ..encoding = request.encoding
        ..bodyBytes = request.bodyBytes;
    } else if (request is http.MultipartRequest) {
      requestCopy = http.MultipartRequest(request.method, request.url)
        ..fields.addAll(request.fields)
        ..files.addAll(request.files);
    } else if (request is http.StreamedRequest) {
      throw Exception('copying streamed requests is not supported');
    } else {
      throw Exception('request type is unknown, cannot copy');
    }

    requestCopy
      ..persistentConnection = request.persistentConnection
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..headers.addAll(request.headers);

    return requestCopy;
  }

  @override
  void close() {
    _inner.close();
  }
}
