/// Modelo de Edificio
class BuildingModel {
  final int id;
  final String name;
  final String isActive;

  BuildingModel({required this.id, required this.name, required this.isActive});

  // Helper getter para verificar si está activo
  bool get active => isActive == 'A';

  factory BuildingModel.fromJson(Map<String, dynamic> json) {
    try {
      // El backend a veces envía is_active como null o \u0000
      final isActiveRaw = json['is_active'];
      String isActiveValue = 'A';
      if (isActiveRaw != null &&
          isActiveRaw.toString().isNotEmpty &&
          isActiveRaw != '\u0000') {
        isActiveValue = isActiveRaw.toString();
      }

      return BuildingModel(
        id: json['id_building'] as int,
        name: json['name'] as String? ?? 'Sin nombre',
        isActive: isActiveValue,
      );
    } catch (e) {
      print('❌ Error parsing BuildingModel: $e');
      print('❌ JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'idBuilding': id, 'name': name, 'isActive': isActive};
  }
}
