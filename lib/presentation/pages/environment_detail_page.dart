import 'package:flutter/material.dart';
import '../../data/repository_impl/environment_service.dart';
import '../../data/repository_impl/resource_service.dart';
import '../../utils/app_theme.dart';
import 'environment_form_page.dart';
import 'add_resource_page.dart';

class EnvironmentDetailPage extends StatelessWidget {
  final Environment env;
  final EnvironmentService service;
  final ResourceService resourceService = ResourceService();
  
  EnvironmentDetailPage({super.key, required this.env, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(env.name),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView(
            children: [
              Text('Detalles del Ambiente', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _DetailItem(title: 'Tipo', value: env.type)),
                  const SizedBox(width: 12),
                  Expanded(child: _DetailItem(title: 'Ubicación', value: env.location)),
                ],
              ),
              const SizedBox(height: 20),
              Text('Recursos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _ResourceRow(name: 'Microscopios', status: 'Operativo', available: '10 disponibles'),
              _ResourceRow(name: 'Tubos de ensayo', status: 'Operativo', available: '5 disponibles'),
              _ResourceRow(name: 'Centrífugas', status: 'En mantenimiento', available: '2 disponibles'),
              _ResourceRow(name: 'Espectrofotómetro', status: 'Dañado', available: '1 disponible'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final updated = await Navigator.of(context).push<bool>(MaterialPageRoute(
                          builder: (_) => EnvironmentFormPage(service: service, existing: env),
                        ));
                        if (updated == true && context.mounted) Navigator.of(context).pop();
                      },
                      child: const Text('Editar Ambiente'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => AddResourcePage(
                              service: resourceService,
                              environmentId: env.id,
                            ),
                          ),
                        );
                        if (result == true && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Añadir Recurso'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String title;
  final String value;
  const _DetailItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.hint)),
        const SizedBox(height: 6),
        Text(value),
        const Divider(height: 24),
      ],
    );
  }
}

class _ResourceRow extends StatelessWidget {
  final String name;
  final String available;
  final String status;
  const _ResourceRow({required this.name, required this.available, required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(name)),
          Expanded(child: Text(available, style: const TextStyle(color: AppColors.primary))),
          Expanded(child: Text(status, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}


