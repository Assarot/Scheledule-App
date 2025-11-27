import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/connectivity_service.dart';
import '../../../utils/cache_service.dart';
import '../../../data/models/academic_space_model.dart';
import '../../../data/datasources/academic_space_remote_datasource.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import 'environment_form_page.dart';
import 'environment_detail_page.dart';

class EnvironmentsListPage extends StatefulWidget {
  const EnvironmentsListPage({super.key});

  @override
  State<EnvironmentsListPage> createState() => _EnvironmentsListPageState();
}

class _EnvironmentsListPageState extends State<EnvironmentsListPage> {
  final AcademicSpaceRemoteDataSource _dataSource =
      AcademicSpaceRemoteDataSource();
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();
  final CacheService _cacheService = CacheService();

  List<AcademicSpaceModel> _spaces = [];
  bool _isLoading = true;
  String _searchQuery = '';
  ConnectivityService? _connectivityService;

  @override
  void initState() {
    super.initState();
    _loadSpaces();
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
    _loadSpaces();
  }

  Future<void> _loadSpaces() async {
    if (!mounted) return;

    final connectivityService =
        _connectivityService ??
        (mounted ? context.read<ConnectivityService>() : null);

    if (connectivityService == null) return;

    setState(() => _isLoading = true);

    if (!connectivityService.isOnline) {
      final cachedSpaces = await _cacheService.getCachedAcademicSpaces();
      setState(() {
        _spaces = cachedSpaces;
        _isLoading = false;
      });
      return;
    }

    try {
      final accessToken = await _authLocalDataSource.getAccessToken();
      if (accessToken == null) {
        setState(() => _isLoading = false);
        return;
      }

      final spaces = await _dataSource.getAll(accessToken);
      await _cacheService.cacheAcademicSpaces(spaces);

      setState(() {
        _spaces = spaces;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading spaces: $e');
      final cachedSpaces = await _cacheService.getCachedAcademicSpaces();
      setState(() {
        _spaces = cachedSpaces;
        _isLoading = false;
      });
    }
  }

  List<AcademicSpaceModel> get _filteredSpaces {
    if (_searchQuery.isEmpty) return _spaces;
    return _spaces.where((space) {
      final query = _searchQuery.toLowerCase();
      return space.spaceName.toLowerCase().contains(query) ||
          (space.location?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambientes'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar ambientes...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                Expanded(
                  child: _filteredSpaces.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.apartment,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'No hay ambientes disponibles'
                                    : 'No se encontraron resultados',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadSpaces,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredSpaces.length,
                            itemBuilder: (context, index) {
                              final space = _filteredSpaces[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.primary
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.apartment,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  title: Text(
                                    space.spaceName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (space.location != null)
                                        Text('📍 ${space.location}'),
                                      Text('👥 Capacidad: ${space.capacity}'),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EnvironmentDetailPage(
                                              environment: space,
                                            ),
                                      ),
                                    );
                                    if (result == true) {
                                      _loadSpaces();
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'create_environment_fab',
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EnvironmentFormPage(),
            ),
          );
          if (result == true) {
            _loadSpaces();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
