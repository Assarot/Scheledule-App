/// Modelo de Estado de Ambiente
class StateModel {
  final int id;
  final String? name;
  final String isActive;

  StateModel({required this.id, this.name, required this.isActive});

  // Helper getter para verificar si está activo
  bool get active => isActive == 'A';

  factory StateModel.fromJson(Map<String, dynamic> json) {
    try {
      // El backend a veces no envía el campo name en objetos anidados
      final isActiveRaw = json['is_active'] ?? json['isActive'];
      String isActiveValue = 'A';
      if (isActiveRaw != null &&
          isActiveRaw.toString().isNotEmpty &&
          isActiveRaw != '\u0000') {
        isActiveValue = isActiveRaw.toString();
      }

      return StateModel(
        id: (json['id_state'] ?? json['idState']) as int,
        name: json['name'] as String?,
        isActive: isActiveValue,
      );
    } catch (e) {
      print('❌ Error parsing StateModel: $e');
      print('❌ JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'idState': id, 'name': name, 'isActive': isActive};
  }
}
