import 'package:flutter/material.dart';
import '../../../data/repository_impl/environment_service.dart';
import '../../../utils/app_theme.dart';
import '../environment_form_page.dart';
import '../environment_detail_page.dart';

class EnvironmentsListPage extends StatefulWidget {
  const EnvironmentsListPage({super.key});

  @override
  State<EnvironmentsListPage> createState() => _EnvironmentsListPageState();
}

class _EnvironmentsListPageState extends State<EnvironmentsListPage> {
  final EnvironmentService service = EnvironmentService();
  String query = '';
  Set<String> selectedTypes = {};
  String sortBy = 'name'; // name, type, location
  bool ascending = true;

  @override
  Widget build(BuildContext context) {
    final items = _getFilteredAndSortedItems();
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        title: const Text('Ambientes'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => EnvironmentDetailPage(env: env, service: service),
                        ));
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
          final created = await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => EnvironmentFormPage(service: service),
          ));
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
        Text('Filtros', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.hint)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Tipo', selectedTypes, types),
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
