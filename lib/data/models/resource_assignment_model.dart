class ResourceAssignmentModel {
  final int id;
  final int idResource;
  final int idAcademicSpace;
  final String? observations;

  // Objetos anidados opcionales
  final dynamic resource; // Puede ser ResourceModel si el backend lo incluye
  final dynamic
  academicSpace; // Puede ser AcademicSpaceModel si el backend lo incluye

  ResourceAssignmentModel({
    required this.id,
    required this.idResource,
    required this.idAcademicSpace,
    this.observations,
    this.resource,
    this.academicSpace,
  });

  factory ResourceAssignmentModel.fromJson(Map<String, dynamic> json) {
    try {
      print(
        '🔗 Parsing ResourceAssignmentModel from JSON keys: ${json.keys.toList()}',
      );

      // Extraer idResource del campo directo o del objeto resource anidado
      int extractedIdResource = 0;

      if (json['id_resource_fk'] != null) {
        extractedIdResource = json['id_resource_fk'] as int;
      } else if (json['idResource'] != null) {
        extractedIdResource = json['idResource'] as int;
      } else if (json['id_resource'] != null) {
        extractedIdResource = json['id_resource'] as int;
      } else if (json['resource'] != null && json['resource'] is Map) {
        // Si resource no es null y es un objeto, extraer su ID
        final resourceMap = json['resource'] as Map<String, dynamic>;
        extractedIdResource =
            (resourceMap['idResource'] ?? resourceMap['id_resource'] ?? 0)
                as int;
      }
      // Si no se encuentra, queda en 0 (se cargará después con un GET)

      return ResourceAssignmentModel(
        id:
            (json['id_resource_assignment'] ??
                    json['idResourceAssignment'] ??
                    json['id'])
                as int,
        idResource: extractedIdResource,
        idAcademicSpace:
            (json['id_academic_space_fk'] ??
                    json['idAcademicSpace'] ??
                    json['id_academic_space'])
                as int,
        observations: json['observations'] as String?,
        resource: json['resource'] ?? json['recurso'],
        academicSpace:
            json['academic_space'] ??
            json['academicSpace'] ??
            json['espacio_academico'],
      );
    } catch (e) {
      print('❌ Error parsing ResourceAssignmentModel: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idResourceAssignment': id,
      'idResource': idResource,
      'idAcademicSpace': idAcademicSpace,
      if (observations != null) 'observations': observations,
      if (resource != null) 'resource': resource,
      if (academicSpace != null) 'academicSpace': academicSpace,
    };
  }
}

class ResourceAssignmentCreateRequest {
  final int idResource;
  final int idAcademicSpace;
  final String? observations;

  ResourceAssignmentCreateRequest({
    required this.idResource,
    required this.idAcademicSpace,
    this.observations,
  });

  Map<String, dynamic> toJson() {
    return {
      'idResource': idResource,
      'idAcademicSpace': idAcademicSpace,
      if (observations != null) 'observations': observations,
    };
  }
}
