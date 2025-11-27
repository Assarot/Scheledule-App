import 'package:flutter/material.dart';
import '../../../data/repository_impl/resource_assignment_repository.dart';
import '../../../data/datasources/resource_remote_datasource.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/models/resource_assignment_model.dart';
import '../../../data/models/resource_model.dart';
import '../../../data/models/academic_space_model.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/connectivity_service.dart';
import 'package:provider/provider.dart';

class AcademicSpaceResourcesPage extends StatefulWidget {
  final AcademicSpaceModel academicSpace;

  const AcademicSpaceResourcesPage({super.key, required this.academicSpace});

  @override
  State<AcademicSpaceResourcesPage> createState() =>
      _AcademicSpaceResourcesPageState();
}

class _AcademicSpaceResourcesPageState
    extends State<AcademicSpaceResourcesPage> {
  late final ResourceAssignmentRepository _assignmentRepository;
  final _resourceDataSource = ResourceRemoteDataSource();
  final _authLocalDataSource = AuthLocalDataSource();

  List<ResourceAssignmentModel> _assignments = [];
  List<ResourceModel> _availableResources = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final connectivityService = Provider.of<ConnectivityService>(
      context,
      listen: false,
    );
    _assignmentRepository = ResourceAssignmentRepository(
      connectivityService: connectivityService,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Cargar asignaciones usando repository (con soporte offline)
      final assignments = await _assignmentRepository.getByAcademicSpace(
        widget.academicSpace.id,
      );

      // Cargar recursos
      final accessToken = await _authLocalDataSource.getAccessToken();
      if (accessToken == null) {
        throw Exception('No se encontró token de acceso');
      }

      // Cargar todos los recursos disponibles
      final resources = await _resourceDataSource.getAll(accessToken);

      setState(() {
        _assignments = assignments;
        _availableResources = resources;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
      }
    }
  }

  Future<void> _showAddResourceDialog() async {
    // Filtrar recursos que ya están asignados
    final assignedResourceIds = _assignments.map((a) => a.idResource).toSet();
    final unassignedResources = _availableResources
        .where((r) => !assignedResourceIds.contains(r.id))
        .toList();

    if (unassignedResources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay recursos disponibles para asignar'),
        ),
      );
      return;
    }

    ResourceModel? selectedResource;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Asignar Recurso'),
          content: SizedBox(
            width: double.maxFinite,
            child: DropdownButtonFormField<ResourceModel>(
              value: selectedResource,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Recurso',
                border: OutlineInputBorder(),
              ),
              items: unassignedResources.map((resource) {
                return DropdownMenuItem(
                  value: resource,
                  child: Text(
                    '${resource.code} - ${resource.resourceType?.name ?? "Sin tipo"}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setDialogState(() => selectedResource = value);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: selectedResource == null
                  ? null
                  : () => Navigator.pop(context, true),
              child: const Text('Asignar'),
            ),
          ],
        ),
      ),
    );

    if (result == true && selectedResource != null) {
      await _createAssignment(selectedResource!.id);
    }
  }

  Future<void> _createAssignment(int resourceId) async {
    try {
      final request = ResourceAssignmentCreateRequest(
        idResource: resourceId,
        idAcademicSpace: widget.academicSpace.id,
      );

      // Usar repository con soporte offline
      final connectivityService = Provider.of<ConnectivityService>(
        context,
        listen: false,
      );

      await _assignmentRepository.create(request);

      if (mounted) {
        final message = connectivityService.isOnline
            ? '✅ Recurso asignado exitosamente'
            : '💾 Recurso asignado. Se sincronizará cuando haya conexión';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: connectivityService.isOnline
                ? Colors.green
                : Colors.orange,
          ),
        );
        _loadData();
      }
    } catch (e) {
      print('Error creating assignment: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error al asignar: $e')));
      }
    }
  }

  Future<void> _deleteAssignment(ResourceAssignmentModel assignment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Deseas eliminar esta asignación?'),
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

    try {
      // Usar repository con soporte offline
      final connectivityService = Provider.of<ConnectivityService>(
        context,
        listen: false,
      );

      await _assignmentRepository.delete(assignment.id);

      if (mounted) {
        final message = connectivityService.isOnline
            ? '✅ Asignación eliminada'
            : '💾 Asignación eliminada. Se sincronizará cuando haya conexión';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: connectivityService.isOnline
                ? Colors.green
                : Colors.orange,
          ),
        );
        _loadData();
      }
    } catch (e) {
      print('Error deleting assignment: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error al eliminar: $e')));
      }
    }
  }

  String _getResourceName(int resourceId) {
    final resource = _availableResources
        .where((r) => r.id == resourceId)
        .firstOrNull;
    return resource?.code ?? 'Recurso #$resourceId';
  }

  String _getResourceType(int resourceId) {
    final resource = _availableResources
        .where((r) => r.id == resourceId)
        .firstOrNull;
    return resource?.resourceType?.name ?? 'Sin tipo';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recursos de ${widget.academicSpace.spaceName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _assignments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay recursos asignados',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toca el botón + para agregar',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _assignments.length,
                      itemBuilder: (context, index) {
                        final assignment = _assignments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Icon(
                                Icons.inventory_2,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              _getResourceName(assignment.idResource),
                            ),
                            subtitle: Text(
                              _getResourceType(assignment.idResource),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAssignment(assignment),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddResourceDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
