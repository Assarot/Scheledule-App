import 'package:flutter/material.dart';
import '../../data/repository_impl/resource_service.dart';
import '../../utils/app_theme.dart';
import '../widgets/quantity_selector.dart';

class AddResourcePage extends StatefulWidget {
  final ResourceService service;
  final String environmentId;
  final Resource? existing;

  const AddResourcePage({
    super.key,
    required this.service,
    required this.environmentId,
    this.existing,
  });

  @override
  State<AddResourcePage> createState() => _AddResourcePageState();
}

class _AddResourcePageState extends State<AddResourcePage> {
  String? selectedType;
  int quantity = 1;
  String? selectedStatus;
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      selectedType = widget.existing!.type;
      quantity = widget.existing!.quantity;
      selectedStatus = widget.existing!.status;
      descriptionController.text = widget.existing!.description ?? '';
    } else {
      selectedType = ResourceService.resourceTypes.first;
      selectedStatus = ResourceService.statusOptions.first;
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  bool get isValid => selectedType != null && selectedStatus != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Añadir Recurso' : 'Editar Recurso'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView(
            children: [
              Text('Elige el Recurso', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.hint)),
              const SizedBox(height: 8),
              _buildDropdown(
                value: selectedType,
                items: ResourceService.resourceTypes,
                onChanged: (value) => setState(() => selectedType = value),
                hint: 'Selecciona tipo de recurso',
              ),
              const SizedBox(height: 20),
              Text('Cantidad', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.hint)),
              const SizedBox(height: 8),
              QuantitySelector(
                value: quantity,
                onChanged: (value) => setState(() => quantity = value),
              ),
              const SizedBox(height: 20),
              Text('Estado', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.hint)),
              const SizedBox(height: 8),
              _buildDropdown(
                value: selectedStatus,
                items: ResourceService.statusOptions,
                onChanged: (value) => setState(() => selectedStatus = value),
                hint: 'Selecciona estado',
              ),
              const SizedBox(height: 20),
              Text('Descripción (Opcional)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.hint)),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Añada una breve descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text('Añadir Foto (Opcional)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.hint)),
              const SizedBox(height: 8),
              _buildPhotoUpload(),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: isValid ? _save : null,
                  child: const Text('Guardar Recurso'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.hint, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Implement photo picker
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funcionalidad de foto próximamente')),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 40, color: AppColors.hint),
            const SizedBox(height: 8),
            Text(
              'Sube un archivo o arrastra y suelta',
              style: TextStyle(color: AppColors.primary),
            ),
            Text(
              'PNG, JPG, GIF hasta 10MB',
              style: TextStyle(color: AppColors.hint, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (widget.existing == null) {
      final newResource = Resource(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: selectedType!,
        quantity: quantity,
        status: selectedStatus!,
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
        environmentId: widget.environmentId,
      );
      widget.service.create(newResource);
    } else {
      widget.service.update(widget.existing!.copyWith(
        type: selectedType!,
        quantity: quantity,
        status: selectedStatus!,
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
      ));
    }
    Navigator.of(context).pop(true);
  }
}