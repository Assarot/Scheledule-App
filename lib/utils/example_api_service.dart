import 'dart:convert';
import '../utils/authenticated_http_client.dart';
import '../data/datasources/auth_local_datasource.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../utils/api_config.dart';

/// Ejemplo de cómo usar el AuthenticatedHttpClient para hacer peticiones
/// autenticadas al backend.
///
/// Este cliente automáticamente:
/// - Agrega el token de acceso a las peticiones
/// - Excluye rutas públicas
/// - Refresca el token si expira
/// - Cierra sesión si el refresh falla

class ExampleApiService {
  final AuthenticatedHttpClient client;

  ExampleApiService({required this.client});

  /// Factory para crear el servicio con el cliente autenticado
  static ExampleApiService create({Function()? onUnauthorized}) {
    final localDataSource = AuthLocalDataSource();
    final remoteDataSource = AuthRemoteDataSource();

    final authenticatedClient = AuthenticatedHttpClient(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      onUnauthorized: onUnauthorized,
    );

    return ExampleApiService(client: authenticatedClient);
  }

  /// Ejemplo: Obtener lista de ambientes (protegido)
  Future<List<dynamic>> getEnvironments() async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/environments'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Error al obtener ambientes: ${response.statusCode}');
    }
  }

  /// Ejemplo: Crear un ambiente (protegido)
  Future<Map<String, dynamic>> createEnvironment(
    Map<String, dynamic> data,
  ) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/environments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al crear ambiente: ${response.statusCode}');
    }
  }

  /// Ejemplo: Actualizar un ambiente (protegido)
  Future<Map<String, dynamic>> updateEnvironment(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await client.put(
      Uri.parse('${ApiConfig.baseUrl}/api/environments/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al actualizar ambiente: ${response.statusCode}');
    }
  }

  /// Ejemplo: Eliminar un ambiente (protegido, solo ADMIN)
  Future<void> deleteEnvironment(String id) async {
    final response = await client.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/environments/$id'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar ambiente: ${response.statusCode}');
    }
  }

  /// Ejemplo: Obtener recursos (protegido)
  Future<List<dynamic>> getResources() async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/resources'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Error al obtener recursos: ${response.statusCode}');
    }
  }
}

/// Ejemplo de uso en un widget:
/// 
/// ```dart
/// class MyPage extends StatefulWidget {
///   @override
///   _MyPageState createState() => _MyPageState();
/// }
/// 
/// class _MyPageState extends State<MyPage> {
///   late ExampleApiService apiService;
///   List<dynamic> environments = [];
///   bool isLoading = false;
/// 
///   @override
///   void initState() {
///     super.initState();
///     
///     // Crear servicio con callback para manejar sesión expirada
///     apiService = ExampleApiService.create(
///       onUnauthorized: () {
///         // Redirigir al login cuando la sesión expire
///         Navigator.of(context).pushAndRemoveUntil(
///           MaterialPageRoute(builder: (_) => LoginPage()),
///           (route) => false,
///         );
///       },
///     );
///     
///     _loadEnvironments();
///   }
/// 
///   Future<void> _loadEnvironments() async {
///     setState(() => isLoading = true);
///     try {
///       final data = await apiService.getEnvironments();
///       setState(() {
///         environments = data;
///         isLoading = false;
///       });
///     } catch (e) {
///       setState(() => isLoading = false);
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text('Error: $e')),
///       );
///     }
///   }
/// 
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: Text('Ambientes')),
///       body: isLoading
///           ? Center(child: CircularProgressIndicator())
///           : ListView.builder(
///               itemCount: environments.length,
///               itemBuilder: (context, index) {
///                 final env = environments[index];
///                 return ListTile(
///                   title: Text(env['name']),
///                   subtitle: Text(env['description']),
///                 );
///               },
///             ),
///     );
///   }
/// }
/// ```
