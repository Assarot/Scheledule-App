import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/auth_service.dart';
import 'courses_dashboard_page.dart';
import '../reports_page.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userRoles = authService.currentUser?.roles ?? [];
    final isAdmin = userRoles.contains('ADMIN');
    final isAsacad = userRoles.contains('ASACAD');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.home, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Text('Inicio', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 24),
            
            // Resumen rápido
            Text('Resumen del Sistema', 
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
            ),
            const SizedBox(height: 12),
            const _StatRow(items: [
              _StatCard(title: 'Salones', value: '12/20', icon: Icons.meeting_room),
              _StatCard(title: 'Laboratorios', value: '5/8', icon: Icons.science),
            ]),
            const SizedBox(height: 12),
            const _StatRow(items: [
              _StatCard(title: 'Recursos', value: '150+', icon: Icons.inventory_2),
              _StatCard(title: 'Cursos', value: '25', icon: Icons.school),
            ]),
            
            const SizedBox(height: 32),
            
            // Accesos rápidos
            Text('Accesos Rápidos', 
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
            ),
            const SizedBox(height: 16),
            
            // Dashboard de Estadísticas (solo ADMIN)
            if (isAdmin) ...[
              _QuickAccessCard(
                title: 'Dashboard de Estadísticas',
                subtitle: 'Ver gráficos y análisis del sistema',
                icon: Icons.dashboard,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CoursesDashboardPage()),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
            
            // Reportes (ADMIN y ASACAD)
            if (isAdmin || isAsacad) ...[
              _QuickAccessCard(
                title: 'Reportes',
                subtitle: 'Generar reportes en PDF del sistema',
                icon: Icons.assessment,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportsPage()),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final List<_StatCard> items;
  const _StatRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: items[0]),
        const SizedBox(width: 12),
        Expanded(child: items[1]),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  const _StatCard({required this.title, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
              ],
              Text(title),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22)),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


