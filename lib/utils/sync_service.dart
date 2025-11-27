import '../data/datasources/academic_space_remote_datasource.dart';
import '../data/datasources/resource_remote_datasource.dart';
import '../data/datasources/resource_assignment_remote_datasource.dart';
import '../data/datasources/auth_local_datasource.dart';
import '../data/models/academic_space_model.dart';
import '../data/models/resource_model.dart';
import '../data/models/resource_assignment_model.dart';
import 'cache_service.dart';

/// Servicio para sincronizar operaciones offline con el backend
class SyncService {
  final AcademicSpaceRemoteDataSource _academicSpaceDataSource =
      AcademicSpaceRemoteDataSource();
  final ResourceRemoteDataSource _resourceDataSource =
      ResourceRemoteDataSource();
  final ResourceAssignmentRemoteDataSource _assignmentDataSource =
      ResourceAssignmentRemoteDataSource();
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();
  final CacheService _cacheService = CacheService();

  /// Sincronizar todas las operaciones pendientes
  Future<SyncResult> syncPendingOperations() async {
    print('🔄 Starting sync...');

    try {
      final accessToken = await _authLocalDataSource.getAccessToken();
      if (accessToken == null) {
        return SyncResult(success: false, message: 'No access token');
      }

      final pendingOps = await _cacheService.getPendingSync();

      if (pendingOps.isEmpty) {
        print('✅ No pending operations to sync');
        return SyncResult(success: true, message: 'No hay cambios pendientes');
      }

      print('📤 Syncing ${pendingOps.length} operations...');

      int successCount = 0;
      int failCount = 0;
      final errors = <String>[];
      final List<int> processedIndices = [];

      for (var i = 0; i < pendingOps.length; i++) {
        final op = pendingOps[i];
        try {
          final opType = op['type'] as String;
          final data = op['data'] as Map<String, dynamic>;

          // Determinar el tipo de entidad (environment o resource)
          final entity = data['entity'] as String? ?? 'environment';

          switch (opType) {
            case 'create':
              if (entity == 'resource') {
                await _syncCreateResource(data, accessToken);
              } else {
                await _syncCreate(data, accessToken);
              }
              successCount++;
              processedIndices.add(i);
              break;
            case 'update':
              if (entity == 'resource') {
                await _syncUpdateResource(data, accessToken);
              } else {
                await _syncUpdate(data, accessToken);
              }
              successCount++;
              processedIndices.add(i);
              break;
            case 'delete':
              if (entity == 'resource') {
                await _syncDeleteResource(data, accessToken);
              } else {
                await _syncDelete(data, accessToken);
              }
              successCount++;
              processedIndices.add(i);
              break;
            case 'create_assignment':
              await _syncCreateAssignment(data, op['tempId'], accessToken);
              successCount++;
              processedIndices.add(i);
              break;
            case 'delete_assignment':
              await _syncDeleteAssignment(data, accessToken);
              successCount++;
              processedIndices.add(i);
              break;
            default:
              print('⚠️ Unknown operation type: $opType');
          }
        } catch (e) {
          failCount++;
          errors.add(e.toString());
          print('❌ Failed to sync operation: $e');
        }
      }

      // Limpiar todas las operaciones procesadas exitosamente
      if (processedIndices.isNotEmpty) {
        await _cacheService.clearPendingSync();
        print('✅ Cleared ${processedIndices.length} synced operations');
      }

      if (failCount == 0) {
        print('✅ All operations synced successfully');
        return SyncResult(
          success: true,
          message: successCount > 0
              ? 'Sincronizados $successCount cambio(s)'
              : 'No hay cambios pendientes',
        );
      } else {
        return SyncResult(
          success: false,
          message: 'Sincronizados $successCount, fallaron $failCount',
        );
      }
    } catch (e) {
      print('❌ Sync error: $e');
      return SyncResult(success: false, message: 'Error: $e');
    }
  }

  Future<void> _syncCreate(
    Map<String, dynamic> data,
    String accessToken,
  ) async {
    print('📝 Creating with data: $data');

    final request = AcademicSpaceCreateRequest(
      spaceName: data['spaceName'] as String,
      capacity: data['capacity'] as int,
      idFloor: data['idFloor'] as int,
      idState: data['idState'] as int,
      idTypeAcademicSpace: data['idTypeAcademicSpace'] as int,
      location: data['location'] as String?,
      observation: data['observation'] as String?,
    );

    print(
      '📤 Sending create request: ${request.spaceName}, capacity: ${request.capacity}',
    );

    await _academicSpaceDataSource.create(request, accessToken);
    print('✅ Created: ${data['spaceName']}');
  }

  Future<void> _syncUpdate(
    Map<String, dynamic> data,
    String accessToken,
  ) async {
    final id = data['id'] as int;
    final request = AcademicSpaceCreateRequest(
      spaceName: data['spaceName'] as String,
      capacity: data['capacity'] as int,
      idFloor: data['idFloor'] as int,
      idState: data['idState'] as int,
      idTypeAcademicSpace: data['idTypeAcademicSpace'] as int,
      location: data['location'] as String?,
      observation: data['observation'] as String?,
    );

    await _academicSpaceDataSource.update(id, request, accessToken);
    print('✅ Updated: ${data['spaceName']}');
  }

  Future<void> _syncDelete(
    Map<String, dynamic> data,
    String accessToken,
  ) async {
    final id = data['id'] as int;
    await _academicSpaceDataSource.delete(id, accessToken);
    print('✅ Deleted: ID $id');
  }

  // ============ RESOURCE SYNC METHODS ============

  Future<void> _syncCreateResource(
    Map<String, dynamic> data,
    String accessToken,
  ) async {
    print('📝 Creating resource with data: $data');

    final request = ResourceCreateRequest(
      stock: data['stock'] as int,
      idResourceType: data['idResourceType'] as int,
      idState: data['idState'] as int,
      code: data['code'] as String,
      observation: data['observation'] as String?,
    );

    print('📤 Sending create resource request: ${request.code}');

    await _resourceDataSource.create(request, accessToken);
    print('✅ Created resource: ${data['code']}');
  }

  Future<void> _syncUpdateResource(
    Map<String, dynamic> data,
    String accessToken,
  ) async {
    final id = data['id'] as int;
    final request = ResourceCreateRequest(
      stock: data['stock'] as int,
      idResourceType: data['idResourceType'] as int,
      idState: data['idState'] as int,
      code: data['code'] as String,
      observation: data['observation'] as String?,
    );

    await _resourceDataSource.update(id, request, accessToken);
    print('✅ Updated resource: ${data['code']}');
  }

  Future<void> _syncDeleteResource(
    Map<String, dynamic> data,
    String accessToken,
  ) async {
    final id = data['id'] as int;
    await _resourceDataSource.delete(id, accessToken);
    print('✅ Deleted resource: ID $id');
  }

  // ============ RESOURCE ASSIGNMENT SYNC ============

  Future<void> _syncCreateAssignment(
    Map<String, dynamic> data,
    dynamic tempId,
    String accessToken,
  ) async {
    final request = ResourceAssignmentCreateRequest(
      idResource: data['idResource'] as int,
      idAcademicSpace: data['idAcademicSpace'] as int,
      observations: data['observations'] as String?,
    );

    print(
      '📤 Sending create assignment request: Resource ${data['idResource']} -> Space ${data['idAcademicSpace']}',
    );

    final createdAssignment = await _assignmentDataSource.create(
      request,
      accessToken,
    );

    // Si había un tempId negativo, actualizar el cache con el ID real
    if (tempId != null && tempId is int && tempId < 0) {
      await _cacheService.removeCachedResourceAssignment(tempId);
      await _cacheService.addCachedResourceAssignment(
        createdAssignment.toJson(),
      );
      print(
        '✅ Replaced temp assignment $tempId with real ID ${createdAssignment.id}',
      );
    }

    print('✅ Created assignment: ID ${createdAssignment.id}');
  }

  Future<void> _syncDeleteAssignment(
    Map<String, dynamic> data,
    String accessToken,
  ) async {
    final id = data['id'] as int;
    await _assignmentDataSource.delete(id, accessToken);
    print('✅ Deleted assignment: ID $id');
  }
}

/// Resultado de la sincronización
class SyncResult {
  final bool success;
  final String message;

  SyncResult({required this.success, required this.message});
}
