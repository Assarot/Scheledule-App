import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/connectivity_service.dart';
import '../../../utils/cache_service.dart';
import '../../../data/models/resource_model.dart';
import '../../../data/datasources/resource_remote_datasource.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import 'resource_form_page.dart';
import 'resource_detail_page.dart';

class ResourcesListPage extends StatefulWidget {
  const ResourcesListPage({super.key});

  @override
  State<ResourcesListPage> createState() => _ResourcesListPageState();
}

class _ResourcesListPageState extends State<ResourcesListPage> {
  final ResourceRemoteDataSource _dataSource = ResourceRemoteDataSource();
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();
  final CacheService _cacheService = CacheService();

  List<ResourceModel> _resources = [];
  bool _isLoading = true;
  String _searchQuery = '';
  ConnectivityService? _connectivityService;

  @override
  void initState() {
    super.initState();
    _loadResources();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _connectivityService = context.read<ConnectivityService>();
        _connectivityService!.addListener(_onConnectivityChanged);
      }
    });
  }

  @override
  void dispose() {
    _connectivityService?.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (!mounted) return;
    _loadResources();
  }

  Future<void> _loadResources() async {
    if (!mounted) return;

    final connectivityService =
        _connectivityService ??
        (mounted ? context.read<ConnectivityService>() : null);

    if (connectivityService == null) return;

    setState(() => _isLoading = true);

    if (!connectivityService.isOnline) {
      final cachedResources = await _cacheService.getCachedResources();
      setState(() {
        _resources = cachedResources;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              cachedResources.isEmpty
                  ? 'Sin conexión. No hay datos en cache.'
                  : 'Modo offline. Mostrando ${cachedResources.length} recurso(s) guardado(s).',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      final accessToken = await _authLocalDataSource.getAccessToken();
      if (accessToken == null) {
        setState(() => _isLoading = false);
        return;
      }

      final resources = await _dataSource.getAll(accessToken);
      await _cacheService.cacheResources(resources);

      setState(() {
        _resources = resources;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading resources: $e');

      final cachedResources = await _cacheService.getCachedResources();

      setState(() {
        _resources = cachedResources;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              cachedResources.isEmpty
                  ? 'Error al cargar recursos: $e'
                  : 'Error de conexión. Mostrando datos guardados.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  List<ResourceModel> get _filteredResources {
    if (_searchQuery.isEmpty) return _resources;

    final query = _searchQuery.toLowerCase();
    return _resources.where((resource) {
      return resource.code.toLowerCase().contains(query) ||
          (resource.observation?.toLowerCase().contains(query) ?? false) ||
          (resource.resourceType?.name?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Future<void> _navigateToForm({ResourceModel? resource}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResourceFormPage(resource: resource),
      ),
    );

    if (result == true) {
      _loadResources();
    }
  }

  Future<void> _navigateToDetail(ResourceModel resource) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResourceDetailPage(resource: resource),
      ),
    );

    if (result == true) {
      _loadResources();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredResources = _filteredResources;

    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        title: const Text('Recursos'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar recursos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredResources.isEmpty
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
                          _searchQuery.isEmpty
                              ? 'No hay recursos disponibles'
                              : 'No se encontraron recursos',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadResources,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredResources.length,
                      itemBuilder: (context, index) {
                        final resource = filteredResources[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.inventory_2,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            title: Text(
                              resource.code,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                if (resource.resourceType?.name != null)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.category,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        resource.resourceType!.name!,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.inventory,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Stock: ${resource.stock}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                                if (resource.state?.name != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        resource.state!.name!,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _navigateToDetail(resource),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'create_resource_fab',
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
