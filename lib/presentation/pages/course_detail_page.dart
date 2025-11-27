import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../domain/entity/course.dart';
import '../../data/repository_impl/course_service.dart';
import 'course_form_page.dart';

class CourseDetailPage extends StatelessWidget {
  final Course course;
  final CourseService service;

  const CourseDetailPage({
    super.key,
    required this.course,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editCourse(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildBasicInfoCard(context),
          const SizedBox(height: 16),
          _buildTimeDistributionCard(context),
          const SizedBox(height: 16),
          _buildClassificationCard(context),
          const SizedBox(height: 16),
          _buildGroupInfoCard(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      color: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Código: ${course.code}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
    return _buildInfoCard(
      title: 'Información General',
      icon: Icons.info_outline,
      children: [
        _buildInfoRow('Descripción', course.description),
        const Divider(),
        _buildInfoRow('Tipo de Curso', course.courseType.name),
        const Divider(),
        _buildInfoRow('Plan de Estudios', course.plan.name),
      ],
    );
  }

  Widget _buildTimeDistributionCard(BuildContext context) {
    return _buildInfoCard(
      title: 'Distribución de Tiempo',
      icon: Icons.schedule,
      children: [
        _buildInfoRow('Duración Total', _formatDuration(course.duration)),
        const Divider(),
        _buildInfoRow('Horas Teóricas', _formatDuration(course.theoreticalHours)),
        const Divider(),
        _buildInfoRow('Horas Prácticas', _formatDuration(course.practicalHours)),
        const Divider(),
        _buildInfoRow('Total de Horas', _formatDuration(course.totalHours)),
        const SizedBox(height: 12),
        _buildTimeChart(),
      ],
    );
  }

  Widget _buildTimeChart() {
    final theoretical = course.theoreticalHours.inMinutes.toDouble();
    final practical = course.practicalHours.inMinutes.toDouble();
    final total = theoretical + practical;

    if (total == 0) return const SizedBox();

    final theoreticalPercent = (theoretical / total * 100).round();
    final practicalPercent = (practical / total * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Distribución de Tiempo',
             style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: theoreticalPercent,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: practicalPercent,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegendItem('Teórico', Colors.blue, '$theoreticalPercent%'),
            _buildLegendItem('Práctico', Colors.orange, '$practicalPercent%'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String percentage) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text('$label ($percentage)', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildClassificationCard(BuildContext context) {
    return _buildInfoCard(
      title: 'Clasificación Académica',
      icon: Icons.category,
      children: [
        _buildInfoRow('Tipo', course.courseType.name),
        const Divider(),
        _buildInfoRow('Plan', course.plan.name),
        const Divider(),
        _buildInfoRow('Escuela Profesional', course.group.cycle.professionalSchool.name),
        const Divider(),
        _buildInfoRow('Ciclo', course.group.cycle.name),
      ],
    );
  }

  Widget _buildGroupInfoCard(BuildContext context) {
    return _buildInfoCard(
      title: 'Información del Grupo',
      icon: Icons.group,
      children: [
        _buildInfoRow('Número de Grupo', course.group.groupNumber),
        const Divider(),
        _buildInfoRow('Capacidad', '${course.group.capacity} estudiantes'),
        const Divider(),
        _buildInfoRow('Ciclo Académico', course.group.cycle.name),
        const Divider(),
        _buildInfoRow('Escuela', course.group.cycle.professionalSchool.name),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '${hours}h ${minutes}min';
      } else {
        return '${hours}h';
      }
    } else {
      return '${duration.inMinutes}min';
    }
  }

  void _editCourse(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseFormPage(
          service: service,
          existingCourse: course,
        ),
      ),
    );
  }
}