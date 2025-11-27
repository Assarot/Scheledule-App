import 'resource_type_model.dart';
import 'state_model.dart';

class ResourceModel {
  final int id;
  final int stock;
  final int idResourceType;
  final int idState;
  final String code;
  final String? resourcePhotoUrl;
  final String? observation;

  // Objetos anidados (pueden venir incompletos del backend)
  final ResourceTypeModel? resourceType;
  final StateModel? state;

  ResourceModel({
    required this.id,
    required this.stock,
    required this.idResourceType,
    required this.idState,
    required this.code,
    this.resourcePhotoUrl,
    this.observation,
    this.resourceType,
    this.state,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing ResourceModel from JSON keys: ${json.keys.toList()}');

      // Parsear objetos anidados si existen (camelCase o snake_case)
      ResourceTypeModel? resourceType;
      final resourceTypeJson = json['resource_type'] ?? json['resourceType'];
      if (resourceTypeJson != null) {
        try {
          resourceType = ResourceTypeModel.fromJson(
            resourceTypeJson as Map<String, dynamic>,
          );
        } catch (e) {
          print('⚠️ Error parsing resource_type: $e');
        }
      }

      StateModel? state;
      final stateJson = json['state'];
      if (stateJson != null) {
        try {
          state = StateModel.fromJson(stateJson as Map<String, dynamic>);
        } catch (e) {
          print('! Error parsing state: $e');
        }
      }

      // Extraer IDs: pueden venir como campos directos o dentro de objetos anidados
      int? idResourceType;

      // Intentar diferentes formatos
      if (json['id_resource_type_fk'] != null) {
        idResourceType = json['id_resource_type_fk'] as int;
      } else if (json['idResourceType'] != null) {
        idResourceType = json['idResourceType'] as int;
      } else if (json['id_resource_type'] != null) {
        idResourceType = json['id_resource_type'] as int;
      } else if (resourceTypeJson?['idResourceType'] != null) {
        idResourceType = resourceTypeJson['idResourceType'] as int;
      } else if (resourceTypeJson?['id_resource_type'] != null) {
        idResourceType = resourceTypeJson['id_resource_type'] as int;
      }

      if (idResourceType == null) {
        print('⚠️ idResourceType not found, using fallback value 0');
        idResourceType =
            0; // Fallback temporal - se resolverá con el GET posterior
      }

      int? idState;

      // Intentar diferentes formatos
      if (json['id_state_fk'] != null) {
        idState = json['id_state_fk'] as int;
      } else if (json['idState'] != null) {
        idState = json['idState'] as int;
      } else if (json['id_state'] != null) {
        idState = json['id_state'] as int;
      } else if (stateJson?['idState'] != null) {
        idState = stateJson['idState'] as int;
      } else if (stateJson?['id_state'] != null) {
        idState = stateJson['id_state'] as int;
      }

      if (idState == null) {
        print('⚠️ idState not found, using fallback value 0');
        idState = 0; // Fallback temporal - se resolverá con el GET posterior
      }

      return ResourceModel(
        id: (json['id_resource'] ?? json['idResource']) as int,
        stock: json['stock'] as int,
        idResourceType: idResourceType,
        idState: idState,
        code: json['code'] as String,
        resourcePhotoUrl:
            (json['resource_photo_url'] ?? json['resourcePhotoUrl']) as String?,
        observation: json['observation'] as String?,
        resourceType: resourceType,
        state: state,
      );
    } catch (e) {
      print('❌ Error parsing ResourceModel: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_resource': id,
      'stock': stock,
      'id_resource_type_fk': idResourceType,
      'id_state_fk': idState,
      'code': code,
      if (resourcePhotoUrl != null) 'resource_photo_url': resourcePhotoUrl,
      if (observation != null) 'observation': observation,
    };
  }
}

class ResourceCreateRequest {
  final int stock;
  final int idResourceType;
  final int idState;
  final String code;
  final String? observation;

  ResourceCreateRequest({
    required this.stock,
    required this.idResourceType,
    required this.idState,
    required this.code,
    this.observation,
  });

  Map<String, dynamic> toJson() {
    // El backend Spring Boot espera camelCase (nombres de campos Java)
    return {
      'stock': stock,
      'idResourceType': idResourceType,
      'idState': idState,
      'code': code,
      if (observation != null) 'observation': observation,
    };
  }
}
