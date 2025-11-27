import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/connectivity_service.dart';
import '../../../data/models/academic_space_model.dart';
import '../../../data/datasources/academic_space_remote_datasource.dart';
import '../../../data/datasources/auth_local_datasource.dart';

class EnvironmentsListPage extends StatefulWidget {
  const EnvironmentsListPage({super.key});

  @override
  State<EnvironmentsListPage> createState() => _EnvironmentsListPageState();
}

class _EnvironmentsListPageState extends State<EnvironmentsListPage> {
  final AcademicSpaceRemoteDataSource _dataSource =
      AcademicSpaceRemoteDataSource();
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();

  List<AcademicSpaceModel> _spaces = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSpaces();
  }

  Future<void> _loadSpaces() async {
    final connectivityService = context.read<ConnectivityService>();

    if (!connectivityService.isOnline) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sin conexión'),
            backgroundColor: Colors.orange,
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

      final spaces = await _dataSource.getAll(accessToken);
      setState(() {
        _spaces = spaces;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading spaces: $e');
      setState(() => _isLoading = false);
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
        leading: const SizedBox.shrink(),
        title: const Text('Ambientes'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar  ambientes',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (text) => setState(() => query = text),
                    ),
                    const SizedBox(height: 12),
                    _buildFilterChips(),
                    const SizedBox(height: 12),
                    _buildSortOptions(),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final env = items[index];
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.fieldFill,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.apartment),
                            ),
                            title: Text(env.name),
                            subtitle: Text(env.location),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EnvironmentDetailPage(
                                    env: env,
                                    service: service,
                                  ),
                                ),
                              );
                              setState(() {});
                            },
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                service.delete(env.id);
                                setState(() {});
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final created = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EnvironmentFormPage(service: service),
            ),
          );
          if (created == true) setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Environment> _getFilteredAndSortedItems() {
    var items = service.list(search: query);

    // Filter by type
    if (selectedTypes.isNotEmpty) {
      items = items.where((e) => selectedTypes.contains(e.type)).toList();
    }

    // Sort
    items.sort((a, b) {
      int comparison = 0;
      switch (sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'type':
          comparison = a.type.compareTo(b.type);
          break;
        case 'location':
          comparison = a.location.compareTo(b.location);
          break;
      }
      return ascending ? comparison : -comparison;
    });

    return items;
  }

  Widget _buildFilterChips() {
    final types = service.list().map((e) => e.type).toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtros',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.hint),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [_buildFilterChip('Tipo', selectedTypes, types)],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    Set<String> selected,
    List<String> options,
  ) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hint.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected.isEmpty ? null : selected.first,
          hint: Text('$label (${selected.length})'),
          isDense: true,
          isExpanded: true,
          items: [
            DropdownMenuItem(value: '', child: Text('Todos los $label')),
            ...options.map(
              (option) => DropdownMenuItem(
                value: option,
                child: Row(
                  children: [
                    Checkbox(
                      value: selected.contains(option),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            selected.add(option);
                          } else {
                            selected.remove(option);
                          }
                        });
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Expanded(child: Text(option)),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (value) {
            if (value == '') {
              setState(() => selected.clear());
            }
          },
        ),
      ),
    );
  }

  Widget _buildSortOptions() {
    return Row(
      children: [
        Text(
          'Ordenar por:',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.hint),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<String>(
            value: sortBy,
            isDense: true,
            items: const [
              DropdownMenuItem(value: 'name', child: Text('Nombre')),
              DropdownMenuItem(value: 'type', child: Text('Tipo')),
              DropdownMenuItem(value: 'location', child: Text('Ubicación')),
            ],
            onChanged: (value) => setState(() => sortBy = value!),
          ),
        ),
        IconButton(
          icon: Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward),
          onPressed: () => setState(() => ascending = !ascending),
        ),
      ],
    );
  }
}
