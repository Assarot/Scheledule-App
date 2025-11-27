import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/datasources/resource_remote_datasource.dart';
import '../../../data/datasources/resource_type_remote_datasource.dart';
import '../../../data/datasources/inventory_state_remote_datasource.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/models/resource_model.dart';
import '../../../data/models/resource_type_model.dart';
import '../../../data/models/state_model.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/connectivity_service.dart';
import '../../../utils/cache_service.dart';
import 'resource_form_page.dart';

class ResourceDetailPage extends StatefulWidget {
  final ResourceModel resource;

  const ResourceDetailPage({super.key, required this.resource});

  @override
  State<ResourceDetailPage> createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {
  final _resourceDataSource = ResourceRemoteDataSource();
  final _resourceTypeDataSource = ResourceTypeRemoteDataSource();
  final _stateDataSource = InventoryStateRemoteDataSource();
  final _authLocalDataSource = AuthLocalDataSource();
  final _cacheService = CacheService();

  List<ResourceTypeModel> _types = [];
  List<StateModel> _states = [];

  bool _isLoadingMetadata = true;
  bool _isDeleting = false;

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

      final types = await _resourceTypeDataSource.getAll(accessToken);
      final states = await _stateDataSource.getAll(accessToken);

      setState(() {
        _types = types;
        _states = states;
        _isLoadingMetadata = false;
      });
    } catch (e) {
      print('Error loading complete data: $e');
      setState(() => _isLoadingMetadata = false);
    }
  }

  String _getTypeName() {
    if (_isLoadingMetadata) return 'Cargando...';
    if (_types.isEmpty) return 'ID: ${widget.resource.idResourceType}';

    final type = _types
        .where((t) => t.id == widget.resource.idResourceType)
        .firstOrNull;
    return type?.name ?? 'ID: ${widget.resource.idResourceType}';
  }

  String _getCategoryName() {
    if (_isLoadingMetadata) return 'Cargando...';
    if (_types.isEmpty) return 'Sin categoría';

    final type = _types
        .where((t) => t.id == widget.resource.idResourceType)
        .firstOrNull;
    return type?.categoryResource?.name ?? 'Sin categoría';
  }

  String _getStateName() {
    if (_isLoadingMetadata) return 'Cargando...';
    if (_states.isEmpty) return 'ID: ${widget.resource.idState}';

    final state = _states
        .where((s) => s.id == widget.resource.idState)
        .firstOrNull;
    return state?.name ?? 'ID: ${widget.resource.idState}';
  }

  Future<void> _deleteResource() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Estás seguro de eliminar este recurso? Esta acción no se puede deshacer.',
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
        // MODO OFFLINE: Guardar en cola y eliminar del caché
        final operation = {
          'type': 'delete',
          'data': {'entity': 'resource', 'id': widget.resource.id},
        };

        await _cacheService.addPendingSync(operation);
        await _cacheService.removeCachedResource(widget.resource.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '💾 Eliminación programada. Se sincronizará cuando haya conexión',
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

        await _resourceDataSource.delete(widget.resource.id, accessToken);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Recurso eliminado exitosamente')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print('Error deleting resource: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error al eliminar: $e')));
      }
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ResourceFormPage(resource: widget.resource),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Recurso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _isDeleting ? null : _navigateToEdit,
            tooltip: 'Editar',
          ),
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.delete, color: Colors.red),
            onPressed: _isDeleting ? null : _deleteResource,
            tooltip: 'Eliminar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              icon: Icons.qr_code,
              title: 'Código',
              content: widget.resource.code,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.inventory,
              title: 'Stock',
              content: widget.resource.stock.toString(),
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.category,
              title: 'Tipo de Recurso',
              content: _getTypeName(),
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.label,
              title: 'Categoría',
              content: _getCategoryName(),
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.info_outline,
              title: 'Estado',
              content: _getStateName(),
              color: Colors.orange,
            ),
            if (widget.resource.observation != null &&
                widget.resource.observation!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.note,
                title: 'Observación',
                content: widget.resource.observation!,
                color: Colors.grey,
              ),
            ],
            if (widget.resource.resourcePhotoUrl != null &&
                widget.resource.resourcePhotoUrl!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Foto del Recurso',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.resource.resourcePhotoUrl!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text('Error al cargar imagen'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
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
                      fontWeight: FontWeight.bold,
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
