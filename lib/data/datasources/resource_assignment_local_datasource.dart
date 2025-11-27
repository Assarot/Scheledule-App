import '../../utils/cache_service.dart';
import '../models/resource_assignment_model.dart';

/// DataSource local para Resource Assignments (cache con Hive)
class ResourceAssignmentLocalDataSource {
  final CacheService _cacheService = CacheService();

  /// Obtener todas las asignaciones desde cache
  Future<List<ResourceAssignmentModel>> getAll() async {
    try {
      final cached = await _cacheService.getCachedResourceAssignments();
      return cached
          .map((json) => ResourceAssignmentModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error getting assignments from cache: $e');
      return [];
    }
  }

  /// Obtener asignaciones por ambiente académico desde cache
  Future<List<ResourceAssignmentModel>> getByAcademicSpace(
    int academicSpaceId,
  ) async {
    try {
      final cached = await _cacheService.getCachedAssignmentsByAcademicSpace(
        academicSpaceId,
      );
      return cached
          .map((json) => ResourceAssignmentModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error getting assignments by space from cache: $e');
      return [];
    }
  }

  /// Obtener asignaciones por recurso desde cache
  Future<List<ResourceAssignmentModel>> getByResource(int resourceId) async {
    try {
      final allAssignments = await getAll();
      return allAssignments
          .where((assignment) => assignment.idResource == resourceId)
          .toList();
    } catch (e) {
      print('❌ Error getting assignments by resource from cache: $e');
      return [];
    }
  }

  /// Guardar lista de asignaciones en cache
  Future<void> cacheAssignments(
    List<ResourceAssignmentModel> assignments,
  ) async {
    try {
      final jsonList = assignments.map((a) => a.toJson()).toList();
      await _cacheService.cacheResourceAssignments(jsonList);
    } catch (e) {
      print('❌ Error caching assignments: $e');
    }
  }

  /// Agregar una asignación al cache (para operaciones offline)
  Future<void> addAssignment(ResourceAssignmentModel assignment) async {
    try {
      await _cacheService.addCachedResourceAssignment(assignment.toJson());
    } catch (e) {
      print('❌ Error adding assignment to cache: $e');
    }
  }

  /// Eliminar una asignación del cache
  Future<void> deleteAssignment(int id) async {
    try {
      await _cacheService.removeCachedResourceAssignment(id);
    } catch (e) {
      print('❌ Error deleting assignment from cache: $e');
    }
  }

  /// Limpiar cache de asignaciones
  Future<void> clearCache() async {
    try {
      await _cacheService.clearResourceAssignmentsCache();
    } catch (e) {
      print('❌ Error clearing assignments cache: $e');
    }
  }

  /// Agregar operación pendiente de sincronización
  Future<void> addPendingSync(Map<String, dynamic> operation) async {
    try {
      await _cacheService.addPendingSync(operation);
    } catch (e) {
      print('❌ Error adding pending sync: $e');
    }
  }
}
