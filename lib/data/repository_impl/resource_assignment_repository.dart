import '../datasources/resource_assignment_remote_datasource.dart';
import '../datasources/resource_assignment_local_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/resource_assignment_model.dart';
import '../../utils/connectivity_service.dart';

/// Repository para Resource Assignments con soporte offline
class ResourceAssignmentRepository {
  final ResourceAssignmentRemoteDataSource _remoteDataSource;
  final ResourceAssignmentLocalDataSource _localDataSource;
  final AuthLocalDataSource _authLocalDataSource;
  final ConnectivityService _connectivityService;

  ResourceAssignmentRepository({
    ResourceAssignmentRemoteDataSource? remoteDataSource,
    ResourceAssignmentLocalDataSource? localDataSource,
    AuthLocalDataSource? authLocalDataSource,
    ConnectivityService? connectivityService,
  }) : _remoteDataSource =
           remoteDataSource ?? ResourceAssignmentRemoteDataSource(),
       _localDataSource =
           localDataSource ?? ResourceAssignmentLocalDataSource(),
       _authLocalDataSource = authLocalDataSource ?? AuthLocalDataSource(),
       _connectivityService = connectivityService ?? ConnectivityService();

  /// Obtener asignaciones por ambiente académico (cache-first)
  Future<List<ResourceAssignmentModel>> getByAcademicSpace(
    int academicSpaceId,
  ) async {
    try {
      // Intentar obtener desde cache primero
      final cachedAssignments = await _localDataSource.getByAcademicSpace(
        academicSpaceId,
      );

      // Si hay conexión, actualizar desde backend
      if (_connectivityService.isOnline) {
        final accessToken = await _authLocalDataSource.getAccessToken();
        if (accessToken != null) {
          try {
            final remoteAssignments = await _remoteDataSource
                .getByAcademicSpace(academicSpaceId, accessToken);

            // Actualizar cache con datos del servidor
            await _localDataSource.cacheAssignments(remoteAssignments);

            return remoteAssignments;
          } catch (e) {
            print('⚠️ Error fetching from server, using cache: $e');
            // Si falla la petición al servidor, usar cache
            return cachedAssignments;
          }
        }
      }

      // Sin conexión o sin token, usar cache
      print('📴 Offline mode: using cached assignments');
      return cachedAssignments;
    } catch (e) {
      print('❌ Error in getByAcademicSpace: $e');
      return [];
    }
  }

  /// Crear una nueva asignación
  Future<ResourceAssignmentModel?> create(
    ResourceAssignmentCreateRequest request,
  ) async {
    try {
      if (_connectivityService.isOnline) {
        // MODO ONLINE: Crear en el backend
        final accessToken = await _authLocalDataSource.getAccessToken();
        if (accessToken == null) {
          throw Exception('No se encontró token de acceso');
        }

        final assignment = await _remoteDataSource.create(request, accessToken);

        // Agregar al cache
        await _localDataSource.addAssignment(assignment);

        return assignment;
      } else {
        // MODO OFFLINE: Agregar a cola de sincronización
        print('📴 Offline: adding assignment to pending sync');

        // Crear asignación temporal con ID negativo
        final tempId = -DateTime.now().millisecondsSinceEpoch;
        final tempAssignment = ResourceAssignmentModel(
          id: tempId,
          idResource: request.idResource,
          idAcademicSpace: request.idAcademicSpace,
          observations: request.observations,
        );

        // Guardar en cache local
        await _localDataSource.addAssignment(tempAssignment);

        // Agregar a cola de sincronización
        await _localDataSource.addPendingSync({
          'type': 'create_assignment',
          'data': request.toJson(),
          'tempId': tempId,
        });

        return tempAssignment;
      }
    } catch (e) {
      print('❌ Error creating assignment: $e');
      rethrow;
    }
  }

  /// Eliminar una asignación
  Future<void> delete(int id) async {
    try {
      if (_connectivityService.isOnline) {
        // MODO ONLINE: Eliminar del backend
        final accessToken = await _authLocalDataSource.getAccessToken();
        if (accessToken == null) {
          throw Exception('No se encontró token de acceso');
        }

        await _remoteDataSource.delete(id, accessToken);

        // Eliminar del cache
        await _localDataSource.deleteAssignment(id);
      } else {
        // MODO OFFLINE: Verificar si es ID temporal (negativo)
        if (id < 0) {
          // Si es temporal, simplemente eliminarlo del cache
          await _localDataSource.deleteAssignment(id);
          print('🗑️ Deleted temporary assignment from cache');
        } else {
          // Si es ID real, agregar a cola de sincronización
          print('📴 Offline: adding delete operation to pending sync');

          await _localDataSource.addPendingSync({
            'type': 'delete_assignment',
            'data': {'id': id},
          });

          // Eliminar del cache local para que no aparezca
          await _localDataSource.deleteAssignment(id);
        }
      }
    } catch (e) {
      print('❌ Error deleting assignment: $e');
      rethrow;
    }
  }

  /// Limpiar cache local
  Future<void> clearCache() async {
    await _localDataSource.clearCache();
  }
}
