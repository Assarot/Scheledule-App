import 'package:flutter/material.dart';
import '../../data/repository_impl/environment_service.dart';
import '../../utils/app_theme.dart';
import '../widgets/app_text_field.dart' as wtf show AppTextField; // avoid name clash

class EnvironmentFormPage extends StatefulWidget {
  final EnvironmentService service;
  final Environment? existing;
  const EnvironmentFormPage({super.key, required this.service, this.existing});

  @override
  State<EnvironmentFormPage> createState() => _EnvironmentFormPageState();
}

class _EnvironmentFormPageState extends State<EnvironmentFormPage> {
  late final TextEditingController nameController;
  late final TextEditingController locationController;
  late final TextEditingController typeController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.existing?.name ?? '');
    locationController = TextEditingController(text: widget.existing?.location ?? '');
    typeController = TextEditingController(text: widget.existing?.type ?? '');
    descriptionController = TextEditingController(text: widget.existing?.description ?? '');
  }

  bool get valid => nameController.text.isNotEmpty && locationController.text.isNotEmpty && typeController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Nuevo Ambiente' : 'Editar Ambiente'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView(
            children: [
              wtf.AppTextField(label: 'Nombre del Ambiente', hint: 'Nombre del Ambiente', controller: nameController),
              const SizedBox(height: 12),
              wtf.AppTextField(label: 'Ubicacion', hint: 'Ubicacion', controller: locationController),
              const SizedBox(height: 12),
              wtf.AppTextField(label: 'Tipo de  Ambiente', hint: 'Tipo de  Ambiente', controller: typeController, trailing: const Icon(Icons.expand_more, color: AppColors.hint)),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(hintText: 'Descripcion'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: valid ? _save : null,
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (widget.existing == null) {
      final newEnv = Environment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        location: locationController.text.trim(),
        type: typeController.text.trim(),
        description: descriptionController.text.trim(),
      );
      widget.service.create(newEnv);
    } else {
      widget.service.update(widget.existing!.copyWith(
        name: nameController.text.trim(),
        location: locationController.text.trim(),
        type: typeController.text.trim(),
        description: descriptionController.text.trim(),
      ));
    }
    Navigator.of(context).pop(true);
  }
}


