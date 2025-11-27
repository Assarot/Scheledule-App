import 'category_resource_model.dart';

class ResourceTypeModel {
  final int id;
  final String? name;
  final String isActive;
  final int idCategoryResource;

  // Objeto anidado (puede venir incompleto del backend)
  final CategoryResourceModel? categoryResource;

  ResourceTypeModel({
    required this.id,
    this.name,
    required this.isActive,
    required this.idCategoryResource,
    this.categoryResource,
  });

  factory ResourceTypeModel.fromJson(Map<String, dynamic> json) {
    try {
      // Manejar is_active especial ('\u0000' del backend) - camelCase o snake_case
      var isActiveRaw = json['is_active'] ?? json['isActive'];
      String isActiveValue = 'A';
      if (isActiveRaw != null && isActiveRaw != '\u0000') {
        isActiveValue = isActiveRaw.toString();
      }

      // Parsear categoría si existe (camelCase o snake_case)
      CategoryResourceModel? categoryResource;
      final categoryJson =
          json['category_resource'] ?? json['categoryResource'];
      if (categoryJson != null) {
        try {
          categoryResource = CategoryResourceModel.fromJson(
            categoryJson as Map<String, dynamic>,
          );
        } catch (e) {
          print('⚠️ Error parsing category_resource: $e');
        }
      }

      // Extraer idCategoryResource: puede venir como campo directo o dentro del objeto anidado
      int idCategoryResource;
      if (json['id_category_resource_fk'] != null) {
        idCategoryResource = json['id_category_resource_fk'] as int;
      } else if (json['idCategoryResource'] != null) {
        idCategoryResource = json['idCategoryResource'] as int;
      } else if (categoryJson?['idCategoryResource'] != null) {
        idCategoryResource = categoryJson['idCategoryResource'] as int;
      } else if (categoryJson?['id_category_resource'] != null) {
        idCategoryResource = categoryJson['id_category_resource'] as int;
      } else {
        throw Exception('No se encontró idCategoryResource');
      }

      return ResourceTypeModel(
        id: (json['id_resource_type'] ?? json['idResourceType']) as int,
        name: json['name'] as String?,
        isActive: isActiveValue,
        idCategoryResource: idCategoryResource,
        categoryResource: categoryResource,
      );
    } catch (e) {
      print('❌ Error parsing ResourceTypeModel: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_resource_type': id,
      if (name != null) 'name': name,
      'is_active': isActive,
      'id_category_resource_fk': idCategoryResource,
    };
  }
}

class ResourceTypeCreateRequest {
  final String name;
  final int idCategoryResource;

  ResourceTypeCreateRequest({
    required this.name,
    required this.idCategoryResource,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'id_category_resource_fk': idCategoryResource};
  }
}
