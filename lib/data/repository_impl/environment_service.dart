class Environment {
  final String id;
  final String name;
  final String location;
  final String type; // Salón, Laboratorio, etc.
  final String description;

  Environment({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.description,
  });

  Environment copyWith({String? name, String? location, String? type, String? description}) {
    return Environment(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      type: type ?? this.type,
      description: description ?? this.description,
    );
  }
}

class EnvironmentService {
  final List<Environment> _items = [
    Environment(id: '1', name: 'Salón 101', location: 'Salón', type: 'Salón', description: 'Salón estándar'),
    Environment(id: '2', name: 'Lab. Química A', location: 'Laboratorio de Química', type: 'Laboratorio', description: 'Química'),
    Environment(id: '3', name: 'Lab. Informática 2', location: 'Laboratorio de Informática', type: 'Laboratorio', description: 'PCs y redes'),
  ];

  List<Environment> list({String search = ''}) {
    final query = search.toLowerCase();
    return _items.where((e) => query.isEmpty || e.name.toLowerCase().contains(query) || e.location.toLowerCase().contains(query)).toList();
  }

  Environment? getById(String id) {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Environment create(Environment env) {
    _items.add(env);
    return env;
  }

  void delete(String id) {
    _items.removeWhere((e) => e.id == id);
  }

  Environment update(Environment env) {
    final index = _items.indexWhere((e) => e.id == env.id);
    if (index != -1) {
      _items[index] = env;
    }
    return env;
  }
}


