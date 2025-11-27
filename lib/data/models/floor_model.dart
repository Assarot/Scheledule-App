/// Modelo de Piso
class FloorModel {
  final int id;
  final int floorNumber;
  final String isActive;
  final int idBuilding;

  FloorModel({
    required this.id,
    required this.floorNumber,
    required this.isActive,
    required this.idBuilding,
  });

  bool get active => isActive == 'A';

  factory FloorModel.fromJson(Map<String, dynamic> json) {
    try {
      // El backend a veces envía is_active como null o \u0000
      final isActiveRaw = json['is_active'];
      String isActiveValue = 'A';
      if (isActiveRaw != null &&
          isActiveRaw.toString().isNotEmpty &&
          isActiveRaw != '\u0000') {
        isActiveValue = isActiveRaw.toString();
      }

      return FloorModel(
        id: json['id_floor'] as int,
        floorNumber: json['floor_number'] as int? ?? 0,
        isActive: isActiveValue,
        idBuilding: json['id_building'] as int? ?? 0,
      );
    } catch (e) {
      print('❌ Error parsing FloorModel: $e');
      print('❌ JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'idFloor': id,
      'floorNumber': floorNumber,
      'isActive': isActive,
      'idBuilding': idBuilding,
    };
  }
}
