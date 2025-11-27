import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/academic_space_model.dart';
import '../../../data/models/building_model.dart';
import '../../../data/models/floor_model.dart';
import '../../../data/models/state_model.dart';
import '../../../data/models/type_academic_space_model.dart';
import '../../../data/datasources/academic_space_remote_datasource.dart';
import '../../../data/datasources/building_remote_datasource.dart';
import '../../../data/datasources/environment_metadata_datasource.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/connectivity_service.dart';
import '../../../utils/cache_service.dart';
import 'environment_form_page.dart';
import 'academic_space_resources_page.dart';

class EnvironmentDetailPage extends StatefulWidget {
  final AcademicSpaceModel environment;

  const EnvironmentDetailPage({super.key, required this.environment});

  @override
  State<EnvironmentDetailPage> createState() => _EnvironmentDetailPageState();
}

class _EnvironmentDetailPageState extends State<EnvironmentDetailPage> {
  final _academicSpaceDataSource = AcademicSpaceRemoteDataSource();
  final _buildingDataSource = BuildingRemoteDataSource();
  final _metadataDataSource = EnvironmentMetadataDataSource();
  final _authLocalDataSource = AuthLocalDataSource();
  final _cacheService = CacheService();

  bool _isDeleting = false;
  bool _isLoadingMetadata = true;

  // Datos completos cargados
  BuildingModel? _building;
  FloorModel? _floor;
  StateModel? _state;
  TypeAcademicSpaceModel? _type;

  @override
  void initState() {
    super.initState();
    _loadCompleteData();
  }

  Future<void> _loadCompleteData() async {
    try {
      final accessToken = await _authLocalDataSource.getAccessToken();
      if (accessToken == null) {
        setState(() => _isLoadingMetadata = false);
        return;
      }

      // Cargar estados
      final states = await _metadataDataSource.getAllStates(accessToken);
      _state = states.firstWhere(
        (s) => s.id == widget.environment.idState,
        orElse: () => StateModel(
          id: widget.environment.idState,
          name: 'Desconocido',
          isActive: 'A',
        ),
      );

      // Cargar tipos
      final types = await _metadataDataSource.getAllTypes(accessToken);
      _type = types.firstWhere(
        (t) => t.id == widget.environment.idTypeAcademicSpace,
        orElse: () => TypeAcademicSpaceModel(
          id: widget.environment.idTypeAcademicSpace,
          name: 'Desconocido',
          isActive: 'A',
        ),
      );

      // Cargar pabellones para obtener pisos
      final buildings = await _buildingDataSource.getAll(accessToken);

      // Buscar el piso en todos los pabellones
      for (var building in buildings) {
        final floors = await _buildingDataSource.getFloorsByBuilding(
          building.id,
          accessToken,
        );
        final foundFloor = floors
            .where((f) => f.id == widget.environment.idFloor)
            .firstOrNull;
        if (foundFloor != null) {
          _floor = foundFloor;
          _building = building;
          break;
        }
      }

      setState(() => _isLoadingMetadata = false);
    } catch (e) {
      print('Error loading metadata: $e');
      setState(() => _isLoadingMetadata = false);
    }
  }

  Future<void> _deleteEnvironment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${widget.environment.spaceName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      final connectivityService = context.read<ConnectivityService>();
      final isOnline = connectivityService.isOnline;

      if (!isOnline) {
        // MODO OFFLINE: Agregar a cola de sincronización
        final operation = {
          'type': 'delete',
          'data': {'id': widget.environment.id},
        };

        await _cacheService.addPendingSync(operation);

        // Eliminar del cache local para que no aparezca en modo offline
        await _cacheService.removeCachedAcademicSpace(widget.environment.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '💾 Eliminación pendiente. Se sincronizará cuando haya conexión',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // MODO ONLINE: Eliminar directo del backend
        final accessToken = await _authLocalDataSource.getAccessToken();
        if (accessToken == null) {
          throw Exception('No se encontró token de acceso');
        }

        await _academicSpaceDataSource.delete(
          widget.environment.id,
          accessToken,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Ambiente eliminado exitosamente')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print('Error deleting environment: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error al eliminar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _manageResources() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AcademicSpaceResourcesPage(academicSpace: widget.environment),
      ),
    );
  }

  Future<void> _editEnvironment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EnvironmentFormPage(environment: widget.environment),
      ),
    );

    if (result == true && mounted) {
      // Si se actualizó, regresar para recargar la lista
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Ambiente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2),
            onPressed: _isDeleting ? null : _manageResources,
            tooltip: 'Gestionar recursos',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _isDeleting ? null : _editEnvironment,
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isDeleting ? null : _deleteEnvironment,
            tooltip: 'Eliminar',
          ),
        ],
      ),
      body: _isDeleting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Eliminando ambiente...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado con icono
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.apartment,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nombre del ambiente
                  Center(
                    child: Text(
                      widget.environment.spaceName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Información del ambiente
                  _buildInfoCard(
                    icon: Icons.location_on,
                    title: 'Ubicación',
                    content: widget.environment.location ?? 'No especificada',
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    icon: Icons.people,
                    title: 'Capacidad',
                    content: '${widget.environment.capacity} personas',
                  ),
                  const SizedBox(height: 16),

                  if (widget.environment.observation != null &&
                      widget.environment.observation!.isNotEmpty)
                    _buildInfoCard(
                      icon: Icons.note,
                      title: 'Observación',
                      content: widget.environment.observation!,
                    ),

                  const SizedBox(height: 16),

                  // Información adicional del ambiente
                  if (_type != null && _type!.name != null)
                    _buildInfoCard(
                      icon: Icons.category,
                      title: 'Tipo de Ambiente',
                      content: _type!.name!,
                    ),

                  if (_type != null && _type!.name != null)
                    const SizedBox(height: 16),

                  if (_building != null)
                    _buildInfoCard(
                      icon: Icons.business,
                      title: 'Pabellón',
                      content: _building!.name,
                    ),

                  if (_building != null) const SizedBox(height: 16),

                  if (_floor != null && _floor!.floorNumber > 0)
                    _buildInfoCard(
                      icon: Icons.layers,
                      title: 'Piso',
                      content: 'Piso ${_floor!.floorNumber}',
                    ),

                  if (_floor != null && _floor!.floorNumber > 0)
                    const SizedBox(height: 16),

                  if (_state != null && _state!.name != null)
                    _buildInfoCard(
                      icon: Icons.info_outline,
                      title: 'Estado',
                      content: _state!.name!,
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
