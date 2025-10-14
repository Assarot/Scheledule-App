import 'package:flutter/material.dart';
import '../../../data/repository_impl/resource_service.dart';
import '../../../utils/app_theme.dart';
import '../add_resource_page.dart';

class RecursosListPage extends StatefulWidget {
  final ResourceService service;
  const RecursosListPage({super.key, required this.service});

  @override
  State<RecursosListPage> createState() => _RecursosListPageState();
}

class _RecursosListPageState extends State<RecursosListPage> {
  String query = '';
  Set<String> selectedStatuses = {};
  Set<String> selectedTypes = {};
  String sortBy = 'name'; // name, quantity, status
  bool ascending = true;

  @override
  Widget build(BuildContext context) {
    final items = _getFilteredAndSortedItems();
    final summary = widget.service.getResourceSummary();

    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        title: const Text('Recursos'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar recursos',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (text) => setState(() => query = text),
              ),
              const SizedBox(height: 12),
              _buildFilterChips(),
              const SizedBox(height: 12),
              _buildSortOptions(),
              const SizedBox(height: 16),
              if (summary.isNotEmpty) ...[
                Text('Resumen de Recursos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _buildSummaryCards(summary),
                const SizedBox(height: 16),
              ],
              Text('Lista de Recursos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final resource = items[index];
                    return Card(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.fieldFill,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(_getResourceIcon(resource.type), color: AppColors.primary),
                        ),
                        title: Text(resource.type),
                        subtitle: Text('Cantidad: ${resource.quantity} | Estado: ${resource.status}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editResource(resource),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteResource(resource),
                            ),
                          ],
                        ),
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
        onPressed: () => _addResource(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, int> summary) {
    final entries = summary.entries.toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.fieldFill,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(entry.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('${entry.value} disponibles', style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  IconData _getResourceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'silla':
        return Icons.chair;
      case 'proyector':
        return Icons.video_library;
      case 'microscopio':
        return Icons.visibility;
      case 'tubos de ensayo':
        return Icons.science;
      case 'centrífuga':
        return Icons.rotate_right;
      case 'espectrofotómetro':
        return Icons.analytics;
      case 'pizarra':
        return Icons.rectangle;
      case 'computadora':
        return Icons.computer;
      case 'mesa':
        return Icons.table_bar;
      case 'sistema de audio':
        return Icons.volume_up;
      default:
        return Icons.inventory;
    }
  }

  void _addResource() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddResourcePage(service: widget.service, environmentId: 'general'),
      ),
    );
    if (result == true) setState(() {});
  }

  void _editResource(Resource resource) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddResourcePage(
          service: widget.service,
          environmentId: resource.environmentId,
          existing: resource,
        ),
      ),
    );
    if (result == true) setState(() {});
  }

  void _deleteResource(Resource resource) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Recurso'),
        content: Text('¿Estás seguro de eliminar ${resource.type}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              widget.service.delete(resource.id);
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  List<Resource> _getFilteredAndSortedItems() {
    var items = widget.service.list(search: query);
    
    // Filter by status
    if (selectedStatuses.isNotEmpty) {
      items = items.where((r) => selectedStatuses.contains(r.status)).toList();
    }
    
    // Filter by type
    if (selectedTypes.isNotEmpty) {
      items = items.where((r) => selectedTypes.contains(r.type)).toList();
    }
    
    // Sort
    items.sort((a, b) {
      int comparison = 0;
      switch (sortBy) {
        case 'name':
          comparison = a.type.compareTo(b.type);
          break;
        case 'quantity':
          comparison = a.quantity.compareTo(b.quantity);
          break;
        case 'status':
          comparison = a.status.compareTo(b.status);
          break;
      }
      return ascending ? comparison : -comparison;
    });
    
    return items;
  }

  Widget _buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filtros', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.hint)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Estado', selectedStatuses, ResourceService.statusOptions),
              const SizedBox(width: 8),
              _buildFilterChip('Tipo', selectedTypes, ResourceService.resourceTypes),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, Set<String> selected, List<String> options) {
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
            DropdownMenuItem(
              value: '',
              child: Text('Todos los $label'),
            ),
            ...options.map((option) => DropdownMenuItem(
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
            )),
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
        Text('Ordenar por:', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.hint)),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<String>(
            value: sortBy,
            isDense: true,
            items: const [
              DropdownMenuItem(value: 'name', child: Text('Nombre')),
              DropdownMenuItem(value: 'quantity', child: Text('Cantidad')),
              DropdownMenuItem(value: 'status', child: Text('Estado')),
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