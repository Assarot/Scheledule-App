class Resource {
  final String id;
  final String type;
  final int quantity;
  final String status;
  final String? description;
  final String? photoUrl;
  final String environmentId;

  Resource({
    required this.id,
    required this.type,
    required this.quantity,
    required this.status,
    this.description,
    this.photoUrl,
    required this.environmentId,
  });

  Resource copyWith({
    String? type,
    int? quantity,
    String? status,
    String? description,
    String? photoUrl,
  }) {
    return Resource(
      id: id,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      environmentId: environmentId,
    );
  }
}

class ResourceService {
  final List<Resource> _items = [
    Resource(id: '1', type: 'Microscopios', quantity: 10, status: 'Operativo', environmentId: '2'),
    Resource(id: '2', type: 'Tubos de ensayo', quantity: 5, status: 'Operativo', environmentId: '2'),
    Resource(id: '3', type: 'Centrífugas', quantity: 2, status: 'En mantenimiento', environmentId: '2'),
    Resource(id: '4', type: 'Espectrofotómetro', quantity: 1, status: 'Dañado', environmentId: '2'),
    Resource(id: '5', type: 'Sillas', quantity: 30, status: 'Operativo', environmentId: '1'),
    Resource(id: '6', type: 'Proyectores', quantity: 2, status: 'Operativo', environmentId: '1'),
  ];

  static const List<String> resourceTypes = [
    'Silla',
    'Proyector',
    'Microscopio',
    'Tubos de ensayo',
    'Centrífuga',
    'Espectrofotómetro',
    'Pizarra',
    'Computadora',
    'Mesa',
    'Sistema de audio',
  ];

  static const List<String> statusOptions = [
    'Operativo',
    'En mantenimiento',
    'Dañado',
    'Fuera de servicio',
  ];

  List<Resource> list({String? environmentId, String search = ''}) {
    var items = _items;
    if (environmentId != null) {
      items = items.where((r) => r.environmentId == environmentId).toList();
    }
    if (search.isNotEmpty) {
      final query = search.toLowerCase();
      items = items.where((r) => 
        r.type.toLowerCase().contains(query) || 
        r.status.toLowerCase().contains(query)
      ).toList();
    }
    return items;
  }

  Resource? getById(String id) {
    try {
      return _items.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Resource create(Resource resource) {
    _items.add(resource);
    return resource;
  }

  void delete(String id) {
    _items.removeWhere((r) => r.id == id);
  }

  Resource update(Resource resource) {
    final index = _items.indexWhere((r) => r.id == resource.id);
    if (index != -1) {
      _items[index] = resource;
    }
    return resource;
  }

  Map<String, int> getResourceSummary() {
    final summary = <String, int>{};
    for (final resource in _items) {
      summary[resource.type] = (summary[resource.type] ?? 0) + resource.quantity;
    }
    return summary;
  }
}
