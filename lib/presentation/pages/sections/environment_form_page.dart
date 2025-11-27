import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/datasources/academic_space_remote_datasource.dart';
import '../../../data/datasources/building_remote_datasource.dart';
import '../../../data/datasources/environment_metadata_datasource.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/models/academic_space_model.dart';
import '../../../data/models/building_model.dart';
import '../../../data/models/floor_model.dart';
import '../../../data/models/state_model.dart';
import '../../../data/models/type_academic_space_model.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/connectivity_service.dart';
import '../../../utils/cache_service.dart';

class EnvironmentFormPage extends StatefulWidget {
  final AcademicSpaceModel? environment;

  const EnvironmentFormPage({super.key, this.environment});

  @override
  State<EnvironmentFormPage> createState() => _EnvironmentFormPageState();
}

class _EnvironmentFormPageState extends State<EnvironmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _spaceNameController = TextEditingController();
  final _observationController = TextEditingController();
  final _capacityController = TextEditingController();

  final _academicSpaceDataSource = AcademicSpaceRemoteDataSource();
  final _buildingDataSource = BuildingRemoteDataSource();
  final _metadataDataSource = EnvironmentMetadataDataSource();
  final _authLocalDataSource = AuthLocalDataSource();
  final _cacheService = CacheService();

  List<BuildingModel> _buildings = [];
  List<FloorModel> _floors = [];
  List<StateModel> _states = [];
  List<TypeAcademicSpaceModel> _types = [];

  BuildingModel? _selectedBuilding;
  FloorModel? _selectedFloor;
  StateModel? _selectedState;
  TypeAcademicSpaceModel? _selectedType;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.environment != null;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      final accessToken = await _authLocalDataSource.getAccessToken();
      if (accessToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró token de acceso')),
          );
        }
        return;
      }

      // Cargar datos de catálogos en paralelo
      final results = await Future.wait([
        _buildingDataSource.getAll(accessToken),
        _metadataDataSource.getAllStates(accessToken),
        _metadataDataSource.getAllTypes(accessToken),
      ]);

      setState(() {
        _buildings = results[0] as List<BuildingModel>;
        _states = results[1] as List<StateModel>;
        _types = results[2] as List<TypeAcademicSpaceModel>;
      });

      // Si es modo edición, cargar datos del ambiente
      if (_isEditMode && widget.environment != null) {
        _loadEnvironmentData();
      }
    } catch (e) {
      print('Error loading initial data: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadEnvironmentData() {
    final env = widget.environment!;
    _spaceNameController.text = env.spaceName;
    _observationController.text = env.observation ?? '';
    _capacityController.text = env.capacity.toString();

    // Buscar y seleccionar el tipo
    _selectedType = _types.firstWhere(
      (t) => t.id == env.idTypeAcademicSpace,
      orElse: () => _types.first,
    );

    // Buscar y seleccionar el estado
    _selectedState = _states.firstWhere(
      (s) => s.id == env.idState,
      orElse: () => _states.first,
    );

    // Cargar building y floor del ambiente
    _loadFloorAndBuilding(env.idFloor);
  }

  Future<void> _loadFloorAndBuilding(int floorId) async {
    try {
      final accessToken = await _authLocalDataSource.getAccessToken();
      if (accessToken == null) return;

      // Buscar el piso en todos los edificios
      for (var building in _buildings) {
        final floors = await _buildingDataSource.getFloorsByBuilding(
          building.id,
          accessToken,
        );
        final floor = floors.firstWhere(
          (f) => f.id == floorId,
          orElse: () => floors.first,
        );

        if (floor.id == floorId) {
          setState(() {
            _selectedBuilding = building;
            _floors = floors;
            _selectedFloor = floor;
          });
          break;
        }
      }
    } catch (e) {
      print('Error loading floor and building: $e');
    }
  }

  Future<void> _onBuildingChanged(BuildingModel? building) async {
    if (building == null) return;

    setState(() {
      _selectedBuilding = building;
      _selectedFloor = null;
      _floors = [];
    });

    try {
      final accessToken = await _authLocalDataSource.getAccessToken();
      if (accessToken == null) return;

      final floors = await _buildingDataSource.getFloorsByBuilding(
        building.id,
        accessToken,
      );

      setState(() => _floors = floors);
    } catch (e) {
      print('Error loading floors: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar pisos: $e')));
      }
    }
  }

  String _generateLocation() {
    if (_selectedBuilding == null ||
        _selectedFloor == null ||
        _selectedType == null) {
      return '';
    }

    return 'Pabellón ${_selectedBuilding!.name}, piso ${_selectedFloor!.floorNumber}, ${_selectedType!.name ?? "Sin tipo"}';
  }

  Future<void> _saveEnvironment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBuilding == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona un pabellón')));
      return;
    }

    if (_selectedFloor == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona un piso')));
      return;
    }

    if (_selectedState == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona un estado')));
      return;
    }

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un tipo de ambiente')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final connectivityService = context.read<ConnectivityService>();
      final isOnline = connectivityService.isOnline;

      final request = AcademicSpaceCreateRequest(
        spaceName: _spaceNameController.text.trim(),
        capacity: int.parse(_capacityController.text),
        idFloor: _selectedFloor!.id,
        idState: _selectedState!.id,
        idTypeAcademicSpace: _selectedType!.id,
        location: _generateLocation(),
        observation: _observationController.text.trim().isEmpty
            ? null
            : _observationController.text.trim(),
      );

      if (!isOnline) {
        // MODO OFFLINE: Guardar en cola de sincronización
        final operation = {
          'type': _isEditMode ? 'update' : 'create',
          'data': {
            'spaceName': request.spaceName,
            'capacity': request.capacity,
            'idFloor': request.idFloor,
            'idState': request.idState,
            'idTypeAcademicSpace': request.idTypeAcademicSpace,
            'location': request.location,
            if (request.observation != null) 'observation': request.observation,
            if (_isEditMode && widget.environment != null)
              'id': widget.environment!.id,
          },
        };

        await _cacheService.addPendingSync(operation);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '💾 Guardado localmente. Se sincronizará cuando haya conexión',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // MODO ONLINE: Guardar directo al backend
        final accessToken = await _authLocalDataSource.getAccessToken();
        if (accessToken == null) {
          throw Exception('No se encontró token de acceso');
        }

        if (_isEditMode && widget.environment != null) {
          await _academicSpaceDataSource.update(
            widget.environment!.id,
            request,
            accessToken,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Ambiente actualizado exitosamente'),
              ),
            );
          }
        } else {
          await _academicSpaceDataSource.create(request, accessToken);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Ambiente creado exitosamente')),
            );
          }
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print('Error saving environment: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error al guardar: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _spaceNameController.dispose();
    _observationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Ambiente' : 'Crear Ambiente'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveEnvironment,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nombre del ambiente
                    TextFormField(
                      controller: _spaceNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Ambiente *',
                        hintText: 'Ej: Laboratorio de Software 1',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.apartment),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tipo de Ambiente
                    DropdownButtonFormField<TypeAcademicSpaceModel>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Ambiente *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _types
                          .where((type) => type.active)
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.name ?? 'Sin nombre'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedType = value),
                      validator: (value) {
                        if (value == null) return 'Selecciona un tipo';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pabellón/Edificio
                    DropdownButtonFormField<BuildingModel>(
                      value: _selectedBuilding,
                      decoration: const InputDecoration(
                        labelText: 'Pabellón *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      items: _buildings
                          .where((building) => building.active)
                          .map(
                            (building) => DropdownMenuItem(
                              value: building,
                              child: Text(building.name),
                            ),
                          )
                          .toList(),
                      onChanged: _onBuildingChanged,
                      validator: (value) {
                        if (value == null) return 'Selecciona un pabellón';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Piso
                    DropdownButtonFormField<FloorModel>(
                      value: _selectedFloor,
                      decoration: const InputDecoration(
                        labelText: 'Piso *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.layers),
                      ),
                      items: _floors
                          .where((floor) => floor.active)
                          .map(
                            (floor) => DropdownMenuItem(
                              value: floor,
                              child: Text('Piso ${floor.floorNumber}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedFloor = value),
                      validator: (value) {
                        if (value == null) return 'Selecciona un piso';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Estado
                    DropdownButtonFormField<StateModel>(
                      value: _selectedState,
                      decoration: const InputDecoration(
                        labelText: 'Estado *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info),
                      ),
                      items: _states
                          .where((state) => state.active)
                          .map(
                            (state) => DropdownMenuItem(
                              value: state,
                              child: Text(state.name ?? 'Sin nombre'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedState = value),
                      validator: (value) {
                        if (value == null) return 'Selecciona un estado';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Capacidad
                    TextFormField(
                      controller: _capacityController,
                      decoration: const InputDecoration(
                        labelText: 'Capacidad *',
                        hintText: 'Ej: 30',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La capacidad es requerida';
                        }
                        final capacity = int.tryParse(value);
                        if (capacity == null || capacity <= 0) {
                          return 'Ingresa una capacidad válida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Observación
                    TextFormField(
                      controller: _observationController,
                      decoration: const InputDecoration(
                        labelText: 'Observación',
                        hintText:
                            'Ej: Todo ok, tiene algún defecto pero operativo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Vista previa de ubicación generada
                    if (_selectedBuilding != null &&
                        _selectedFloor != null &&
                        _selectedType != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Ubicación generada:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _generateLocation(),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Botón Guardar
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveEnvironment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isEditMode ? 'Actualizar' : 'Crear Ambiente',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
