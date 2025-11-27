/// Modelo de Tipo de Espacio Académico
class TypeAcademicSpaceModel {
  final int id;
  final String? name;
  final String isActive;

  TypeAcademicSpaceModel({required this.id, this.name, required this.isActive});

  // Helper getter para verificar si está activo
  bool get active => isActive == 'A';

  factory TypeAcademicSpaceModel.fromJson(Map<String, dynamic> json) {
    try {
      // El backend a veces no envía el campo name en objetos anidados
      final isActiveRaw = json['is_active'];
      String isActiveValue = 'A';
      if (isActiveRaw != null &&
          isActiveRaw.toString().isNotEmpty &&
          isActiveRaw != '\u0000') {
        isActiveValue = isActiveRaw.toString();
      }

      return TypeAcademicSpaceModel(
        id: json['id_type_academic_space'] as int,
        name: json['name'] as String?,
        isActive: isActiveValue,
      );
    } catch (e) {
      print('❌ Error parsing TypeAcademicSpaceModel: $e');
      print('❌ JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'idTypeAcademicSpace': id, 'name': name, 'isActive': isActive};
  }
}
