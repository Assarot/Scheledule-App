import 'state_model.dart';
import 'floor_model.dart';
import 'type_academic_space_model.dart';

/// Modelo de Espacio Académico (Ambiente)
class AcademicSpaceModel {
  final int id;
  final String spaceName;
  final int capacity;
  final int idFloor;
  final int idState;
  final int idTypeAcademicSpace;
  final String? location;
  final String? observation;

  // Objetos anidados completos del backend
  final StateModel? state;
  final FloorModel? floor;
  final TypeAcademicSpaceModel? typeAcademicSpace;

  AcademicSpaceModel({
    required this.id,
    required this.spaceName,
    required this.capacity,
    required this.idFloor,
    required this.idState,
    required this.idTypeAcademicSpace,
    this.location,
    this.observation,
    this.state,
    this.floor,
    this.typeAcademicSpace,
  });

  factory AcademicSpaceModel.fromJson(Map<String, dynamic> json) {
    try {
      // El backend devuelve snake_case y objetos anidados
      final floorJson = json['floor'] as Map<String, dynamic>?;
      final stateJson = json['state'] as Map<String, dynamic>?;
      final typeJson = json['type_academic_space'] as Map<String, dynamic>?;

      return AcademicSpaceModel(
        id: json['id_academic_space'] as int,
        spaceName: json['space_name'] as String? ?? '',
        capacity: json['capacity'] as int? ?? 0,
        // Extraer IDs de los objetos anidados
        idFloor: floorJson?['id_floor'] as int? ?? 0,
        idState: stateJson?['id_state'] as int? ?? 0,
        idTypeAcademicSpace: typeJson?['id_type_academic_space'] as int? ?? 0,
        location: json['location'] as String?,
        observation: json['observation'] as String?,
        // Guardar objetos completos
        floor: floorJson != null ? FloorModel.fromJson(floorJson) : null,
        state: stateJson != null ? StateModel.fromJson(stateJson) : null,
        typeAcademicSpace: typeJson != null
            ? TypeAcademicSpaceModel.fromJson(typeJson)
            : null,
      );
    } catch (e) {
      print('❌ Error parsing AcademicSpaceModel: $e');
      print('❌ JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'idAcademicSpace': id,
      'spaceName': spaceName,
      'capacity': capacity,
      'idFloor': idFloor,
      'idState': idState,
      'idTypeAcademicSpace': idTypeAcademicSpace,
      'location': location,
      'observation': observation,
    };
  }
}

/// Request para crear/actualizar espacio académico
class AcademicSpaceCreateRequest {
  final String spaceName;
  final int capacity;
  final int idFloor;
  final int idState;
  final int idTypeAcademicSpace;
  final String? location;
  final String? observation;

  AcademicSpaceCreateRequest({
    required this.spaceName,
    required this.capacity,
    required this.idFloor,
    required this.idState,
    required this.idTypeAcademicSpace,
    this.location,
    this.observation,
  });

  Map<String, dynamic> toJson() {
    // El backend espera snake_case
    return {
      'space_name': spaceName,
      'capacity': capacity,
      'id_floor': idFloor,
      'id_state': idState,
      'id_type_academic_space': idTypeAcademicSpace,
      'location': location,
      'observation': observation,
    };
  }
}
