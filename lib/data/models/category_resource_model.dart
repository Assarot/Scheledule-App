class CategoryResourceModel {
  final int id;
  final String? name;
  final String isActive;

  CategoryResourceModel({required this.id, this.name, required this.isActive});

  factory CategoryResourceModel.fromJson(Map<String, dynamic> json) {
    try {
      // Manejar is_active especial ('\u0000' del backend) - camelCase o snake_case
      var isActiveRaw = json['is_active'] ?? json['isActive'];
      String isActiveValue = 'A';
      if (isActiveRaw != null && isActiveRaw != '\u0000') {
        isActiveValue = isActiveRaw.toString();
      }

      return CategoryResourceModel(
        id: (json['id_category_resource'] ?? json['idCategoryResource']) as int,
        name: json['name'] as String?,
        isActive: isActiveValue,
      );
    } catch (e) {
      print('❌ Error parsing CategoryResourceModel: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_category_resource': id,
      if (name != null) 'name': name,
      'is_active': isActive,
    };
  }
}

class CategoryResourceCreateRequest {
  final String name;

  CategoryResourceCreateRequest({required this.name});

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
