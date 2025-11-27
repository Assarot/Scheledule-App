import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/user_profile_model.dart';
import '../data/models/academic_space_model.dart';
import '../data/models/resource_model.dart';
import '../data/models/state_model.dart';
import '../data/models/floor_model.dart';
import '../data/models/type_academic_space_model.dart';
import '../data/models/resource_type_model.dart';

/// Servicio de cache local usando Hive
class CacheService {
  static const String _profileBoxName = 'user_profiles';
  static const String _pendingSyncBoxName = 'pending_sync';
  static const String _academicSpacesBoxName = 'academic_spaces';
  static const String _resourcesBoxName = 'resources';
  static const String _resourceAssignmentsBoxName = 'resource_assignments';

  /// Inicializar Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    // Registrar adaptadores cuando se generen
    // Hive.registerAdapter(CachedUserProfileAdapter());
  }

  /// Guardar perfil de usuario en cache
  Future<void> cacheUserProfile(UserProfileModel profile) async {
    try {
      final box = await Hive.openBox<Map>(_profileBoxName);
      await box.put('profile_${profile.id}', {
        'id': profile.id,
        'names': profile.names,
        'lastName': profile.lastName,
        'email': profile.email,
        'phoneNumber': profile.phoneNumber,
        'address': profile.address,
        'dob': profile.dob?.toIso8601String(),
        'profilePicture': profile.profilePicture,
        'isActive': profile.isActive,
        'cachedAt': DateTime.now().toIso8601String(),
      });
      print('💾 Profile cached: ${profile.id}');
    } catch (e) {
      print('❌ Error caching profile: $e');
    }
  }

  /// Obtener perfil de usuario desde cache
  Future<UserProfileModel?> getCachedUserProfile(int profileId) async {
    try {
      final box = await Hive.openBox<Map>(_profileBoxName);
      final cached = box.get('profile_$profileId');

      if (cached == null) {
        print('📭 No cached profile found for: $profileId');
        return null;
      }

      print('💾 Profile loaded from cache: $profileId');

      return UserProfileModel(
        id: cached['id'] as int,
        names: cached['names'] as String,
        lastName: cached['lastName'] as String,
        email: cached['email'] as String,
        phoneNumber: cached['phoneNumber'] as String?,
        address: cached['address'] as String?,
        dob: cached['dob'] != null
            ? DateTime.parse(cached['dob'] as String)
            : null,
        profilePicture: cached['profilePicture'] as String?,
        isActive: cached['isActive'] as bool,
      );
    } catch (e) {
      print('❌ Error loading cached profile: $e');
      return null;
    }
  }

  /// Obtener el último perfil cacheado (útil cuando no se conoce el profileId)
  Future<UserProfileModel?> getLastCachedProfile() async {
    try {
      final box = await Hive.openBox<Map>(_profileBoxName);

      if (box.isEmpty) {
        print('📭 No cached profiles found');
        return null;
      }

      // Obtener el último perfil guardado
      final keys = box.keys.toList();
      final lastKey = keys.last;
      final cached = box.get(lastKey);

      if (cached == null) return null;

      print('💾 Loading last cached profile');

      return UserProfileModel(
        id: cached['id'] as int,
        names: cached['names'] as String,
        lastName: cached['lastName'] as String,
        email: cached['email'] as String,
        phoneNumber: cached['phoneNumber'] as String?,
        address: cached['address'] as String?,
        dob: cached['dob'] != null
            ? DateTime.parse(cached['dob'] as String)
            : null,
        profilePicture: cached['profilePicture'] as String?,
        isActive: cached['isActive'] as bool,
      );
    } catch (e) {
      print('❌ Error loading last cached profile: $e');
      return null;
    }
  }

  /// Limpiar cache de perfiles
  Future<void> clearProfileCache() async {
    try {
      final box = await Hive.openBox<Map>(_profileBoxName);
      await box.clear();
      print('🗑️ Profile cache cleared');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  /// Agregar operación pendiente de sincronización
  Future<void> addPendingSync(Map<String, dynamic> operation) async {
    try {
      final box = await Hive.openBox<Map>(_pendingSyncBoxName);
      final key = 'sync_${DateTime.now().millisecondsSinceEpoch}';
      await box.put(key, operation);
      print('📤 Pending sync added: $key');
      print(
        '📦 Operation details: ${operation['type']} - ${operation['data']}',
      );
    } catch (e) {
      print('❌ Error adding pending sync: $e');
    }
  }

  /// Obtener operaciones pendientes de sincronización
  Future<List<Map<String, dynamic>>> getPendingSync() async {
    try {
      final box = await Hive.openBox<Map>(_pendingSyncBoxName);
      final operations = box.values
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      print('📬 Found ${operations.length} pending operations');
      for (var i = 0; i < operations.length; i++) {
        print(
          '  [$i] ${operations[i]['type']}: ${operations[i]['data']?['spaceName'] ?? operations[i]['data']?['id']}',
        );
      }
      return operations;
    } catch (e) {
      print('❌ Error getting pending sync: $e');
      return [];
    }
  }

  /// Limpiar operaciones sincronizadas
  Future<void> clearPendingSync() async {
    try {
      final box = await Hive.openBox<Map>(_pendingSyncBoxName);
      await box.clear();
      print('✅ Pending sync cleared');
    } catch (e) {
      print('❌ Error clearing pending sync: $e');
    }
  }

  // ============ ACADEMIC SPACES CACHE ============

  /// Guardar lista de espacios académicos en cache
  Future<void> cacheAcademicSpaces(List<AcademicSpaceModel> spaces) async {
    try {
      final box = await Hive.openBox<Map>(_academicSpacesBoxName);

      // Limpiar cache anterior para reflejar el estado actual del backend
      await box.clear();
      print('🗑️ Cleared old academic spaces cache');

      // Guardar cada espacio
      for (var space in spaces) {
        await box.put('space_${space.id}', {
          'id': space.id,
          'spaceName': space.spaceName,
          'capacity': space.capacity,
          'idFloor': space.idFloor,
          'idState': space.idState,
          'idTypeAcademicSpace': space.idTypeAcademicSpace,
          'location': space.location,
          'observation': space.observation,
          // Guardar objetos anidados si existen
          'state': space.state != null
              ? {
                  'id': space.state!.id,
                  'name': space.state!.name,
                  'isActive': space.state!.isActive,
                }
              : null,
          'floor': space.floor != null
              ? {
                  'id': space.floor!.id,
                  'floorNumber': space.floor!.floorNumber,
                  'isActive': space.floor!.isActive,
                  'idBuilding': space.floor!.idBuilding,
                }
              : null,
          'typeAcademicSpace': space.typeAcademicSpace != null
              ? {
                  'id': space.typeAcademicSpace!.id,
                  'name': space.typeAcademicSpace!.name,
                  'isActive': space.typeAcademicSpace!.isActive,
                }
              : null,
          'cachedAt': DateTime.now().toIso8601String(),
        });
      }

      // Guardar timestamp de última actualización
      await box.put('_last_sync', {
        'timestamp': DateTime.now().toIso8601String(),
        'count': spaces.length,
      });

      print('💾 Cached ${spaces.length} academic spaces');
    } catch (e) {
      print('❌ Error caching academic spaces: $e');
    }
  }

  /// Obtener espacios académicos desde cache
  Future<List<AcademicSpaceModel>> getCachedAcademicSpaces() async {
    try {
      final box = await Hive.openBox<Map>(_academicSpacesBoxName);

      final spaces = <AcademicSpaceModel>[];
      for (var key in box.keys) {
        if (key.toString().startsWith('space_')) {
          final cached = box.get(key);
          if (cached != null) {
            // Reconstruir objetos anidados
            StateModel? state;
            if (cached['state'] != null) {
              final stateMap = cached['state'] as Map;
              state = StateModel(
                id: stateMap['id'] as int,
                name: stateMap['name'] as String?,
                isActive: stateMap['isActive'] as String? ?? 'A',
              );
            }

            FloorModel? floor;
            if (cached['floor'] != null) {
              final floorMap = cached['floor'] as Map;
              floor = FloorModel(
                id: floorMap['id'] as int,
                floorNumber: floorMap['floorNumber'] as int? ?? 0,
                isActive: floorMap['isActive'] as String? ?? 'A',
                idBuilding: floorMap['idBuilding'] as int? ?? 0,
              );
            }

            TypeAcademicSpaceModel? typeAcademicSpace;
            if (cached['typeAcademicSpace'] != null) {
              final typeMap = cached['typeAcademicSpace'] as Map;
              typeAcademicSpace = TypeAcademicSpaceModel(
                id: typeMap['id'] as int,
                name: typeMap['name'] as String?,
                isActive: typeMap['isActive'] as String? ?? 'A',
              );
            }

            spaces.add(
              AcademicSpaceModel(
                id: cached['id'] as int,
                spaceName: cached['spaceName'] as String,
                capacity: cached['capacity'] as int,
                idFloor: cached['idFloor'] as int,
                idState: cached['idState'] as int,
                idTypeAcademicSpace: cached['idTypeAcademicSpace'] as int,
                location: cached['location'] as String?,
                observation: cached['observation'] as String?,
                state: state,
                floor: floor,
                typeAcademicSpace: typeAcademicSpace,
              ),
            );
          }
        }
      }

      print('💾 Loaded ${spaces.length} academic spaces from cache');
      return spaces;
    } catch (e) {
      print('❌ Error loading cached academic spaces: $e');
      return [];
    }
  }

  /// Obtener un espacio académico específico desde cache
  Future<AcademicSpaceModel?> getCachedAcademicSpace(int id) async {
    try {
      final box = await Hive.openBox<Map>(_academicSpacesBoxName);
      final cached = box.get('space_$id');

      if (cached == null) {
        print('📭 No cached space found for: $id');
        return null;
      }

      // Reconstruir objetos anidados
      StateModel? state;
      if (cached['state'] != null) {
        final stateMap = cached['state'] as Map;
        state = StateModel(
          id: stateMap['id'] as int,
          name: stateMap['name'] as String?,
          isActive: stateMap['isActive'] as String? ?? 'A',
        );
      }

      FloorModel? floor;
      if (cached['floor'] != null) {
        final floorMap = cached['floor'] as Map;
        floor = FloorModel(
          id: floorMap['id'] as int,
          floorNumber: floorMap['floorNumber'] as int? ?? 0,
          isActive: floorMap['isActive'] as String? ?? 'A',
          idBuilding: floorMap['idBuilding'] as int? ?? 0,
        );
      }

      TypeAcademicSpaceModel? typeAcademicSpace;
      if (cached['typeAcademicSpace'] != null) {
        final typeMap = cached['typeAcademicSpace'] as Map;
        typeAcademicSpace = TypeAcademicSpaceModel(
          id: typeMap['id'] as int,
          name: typeMap['name'] as String?,
          isActive: typeMap['isActive'] as String? ?? 'A',
        );
      }

      return AcademicSpaceModel(
        id: cached['id'] as int,
        spaceName: cached['spaceName'] as String,
        capacity: cached['capacity'] as int,
        idFloor: cached['idFloor'] as int,
        idState: cached['idState'] as int,
        idTypeAcademicSpace: cached['idTypeAcademicSpace'] as int,
        location: cached['location'] as String?,
        observation: cached['observation'] as String?,
        state: state,
        floor: floor,
        typeAcademicSpace: typeAcademicSpace,
      );
    } catch (e) {
      print('❌ Error loading cached space: $e');
      return null;
    }
  }

  /// Obtener información de última sincronización
  Future<Map<String, dynamic>?> getLastSyncInfo() async {
    try {
      final box = await Hive.openBox<Map>(_academicSpacesBoxName);
      return box.get('_last_sync') as Map<String, dynamic>?;
    } catch (e) {
      print('❌ Error getting sync info: $e');
      return null;
    }
  }

  /// Eliminar un espacio académico específico del cache
  Future<void> removeCachedAcademicSpace(int id) async {
    try {
      final box = await Hive.openBox<Map>(_academicSpacesBoxName);
      await box.delete('space_$id');
      print('🗑️ Removed space_$id from cache');
    } catch (e) {
      print('❌ Error removing cached space: $e');
    }
  }

  /// Limpiar cache de espacios académicos
  Future<void> clearAcademicSpacesCache() async {
    try {
      final box = await Hive.openBox<Map>(_academicSpacesBoxName);
      await box.clear();
      print('🗑️ Academic spaces cache cleared');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  // ============ RESOURCES CACHE ============

  /// Guardar lista de recursos en cache
  Future<void> cacheResources(List<ResourceModel> resources) async {
    try {
      final box = await Hive.openBox<Map>(_resourcesBoxName);

      // Limpiar cache anterior
      await box.clear();
      print('🗑️ Cleared old resources cache');

      // Guardar cada recurso
      for (var resource in resources) {
        await box.put('resource_${resource.id}', {
          'id': resource.id,
          'stock': resource.stock,
          'idResourceType': resource.idResourceType,
          'idState': resource.idState,
          'code': resource.code,
          'resourcePhotoUrl': resource.resourcePhotoUrl,
          'observation': resource.observation,
          // Guardar objetos anidados si existen
          'resourceType': resource.resourceType != null
              ? {
                  'id': resource.resourceType!.id,
                  'name': resource.resourceType!.name,
                  'isActive': resource.resourceType!.isActive,
                  'idCategoryResource':
                      resource.resourceType!.idCategoryResource,
                }
              : null,
          'state': resource.state != null
              ? {
                  'id': resource.state!.id,
                  'name': resource.state!.name,
                  'isActive': resource.state!.isActive,
                }
              : null,
        });
      }

      print('💾 Cached ${resources.length} resources');
    } catch (e) {
      print('❌ Error caching resources: $e');
    }
  }

  /// Obtener todos los recursos desde cache
  Future<List<ResourceModel>> getCachedResources() async {
    try {
      final box = await Hive.openBox<Map>(_resourcesBoxName);
      final List<ResourceModel> resources = [];

      for (var key in box.keys) {
        if (key.toString().startsWith('resource_')) {
          final cached = box.get(key);

          if (cached != null) {
            // Reconstruir objetos anidados
            ResourceTypeModel? resourceType;
            if (cached['resourceType'] != null) {
              final typeMap = cached['resourceType'] as Map;
              resourceType = ResourceTypeModel(
                id: typeMap['id'] as int,
                name: typeMap['name'] as String?,
                isActive: typeMap['isActive'] as String? ?? 'A',
                idCategoryResource: typeMap['idCategoryResource'] as int,
              );
            }

            StateModel? state;
            if (cached['state'] != null) {
              final stateMap = cached['state'] as Map;
              state = StateModel(
                id: stateMap['id'] as int,
                name: stateMap['name'] as String?,
                isActive: stateMap['isActive'] as String? ?? 'A',
              );
            }

            resources.add(
              ResourceModel(
                id: cached['id'] as int,
                stock: cached['stock'] as int,
                idResourceType: cached['idResourceType'] as int,
                idState: cached['idState'] as int,
                code: cached['code'] as String,
                resourcePhotoUrl: cached['resourcePhotoUrl'] as String?,
                observation: cached['observation'] as String?,
                resourceType: resourceType,
                state: state,
              ),
            );
          }
        }
      }

      print('💾 Loaded ${resources.length} resources from cache');
      return resources;
    } catch (e) {
      print('❌ Error loading cached resources: $e');
      return [];
    }
  }

  /// Eliminar un recurso específico del cache
  Future<void> removeCachedResource(int id) async {
    try {
      final box = await Hive.openBox<Map>(_resourcesBoxName);
      await box.delete('resource_$id');
      print('🗑️ Removed resource_$id from cache');
    } catch (e) {
      print('❌ Error removing cached resource: $e');
    }
  }

  /// Limpiar cache de recursos
  Future<void> clearResourcesCache() async {
    try {
      final box = await Hive.openBox<Map>(_resourcesBoxName);
      await box.clear();
      print('🗑️ Resources cache cleared');
    } catch (e) {
      print('❌ Error clearing resources cache: $e');
    }
  }

  // ============ RESOURCE ASSIGNMENTS CACHE ============

  /// Guardar lista de asignaciones de recursos en cache
  Future<void> cacheResourceAssignments(
    List<Map<String, dynamic>> assignments,
  ) async {
    try {
      final box = await Hive.openBox<Map>(_resourceAssignmentsBoxName);

      // Guardar cada asignación
      for (var assignment in assignments) {
        await box.put('assignment_${assignment['id']}', assignment);
      }

      print('💾 Cached ${assignments.length} resource assignments');
    } catch (e) {
      print('❌ Error caching resource assignments: $e');
    }
  }

  /// Obtener todas las asignaciones desde cache
  Future<List<Map<String, dynamic>>> getCachedResourceAssignments() async {
    try {
      final box = await Hive.openBox<Map>(_resourceAssignmentsBoxName);
      final List<Map<String, dynamic>> assignments = [];

      for (var key in box.keys) {
        if (key.toString().startsWith('assignment_')) {
          final cached = box.get(key);
          if (cached != null) {
            assignments.add(Map<String, dynamic>.from(cached));
          }
        }
      }

      print('💾 Loaded ${assignments.length} resource assignments from cache');
      return assignments;
    } catch (e) {
      print('❌ Error loading cached resource assignments: $e');
      return [];
    }
  }

  /// Obtener asignaciones por ambiente académico desde cache
  Future<List<Map<String, dynamic>>> getCachedAssignmentsByAcademicSpace(
    int academicSpaceId,
  ) async {
    try {
      final box = await Hive.openBox<Map>(_resourceAssignmentsBoxName);
      final List<Map<String, dynamic>> assignments = [];

      for (var key in box.keys) {
        if (key.toString().startsWith('assignment_')) {
          final cached = box.get(key);
          if (cached != null) {
            final assignment = Map<String, dynamic>.from(cached);
            if (assignment['idAcademicSpace'] == academicSpaceId) {
              assignments.add(assignment);
            }
          }
        }
      }

      print(
        '💾 Loaded ${assignments.length} assignments for space $academicSpaceId from cache',
      );
      return assignments;
    } catch (e) {
      print('❌ Error loading cached assignments by space: $e');
      return [];
    }
  }

  /// Agregar una nueva asignación al cache
  Future<void> addCachedResourceAssignment(
    Map<String, dynamic> assignment,
  ) async {
    try {
      final box = await Hive.openBox<Map>(_resourceAssignmentsBoxName);
      await box.put('assignment_${assignment['id']}', assignment);
      print('💾 Added assignment_${assignment['id']} to cache');
    } catch (e) {
      print('❌ Error adding cached assignment: $e');
    }
  }

  /// Eliminar una asignación específica del cache
  Future<void> removeCachedResourceAssignment(int id) async {
    try {
      final box = await Hive.openBox<Map>(_resourceAssignmentsBoxName);
      await box.delete('assignment_$id');
      print('🗑️ Removed assignment_$id from cache');
    } catch (e) {
      print('❌ Error removing cached assignment: $e');
    }
  }

  /// Limpiar cache de asignaciones
  Future<void> clearResourceAssignmentsCache() async {
    try {
      final box = await Hive.openBox<Map>(_resourceAssignmentsBoxName);
      await box.clear();
      print('🗑️ Resource assignments cache cleared');
    } catch (e) {
      print('❌ Error clearing assignments cache: $e');
    }
  }
}
