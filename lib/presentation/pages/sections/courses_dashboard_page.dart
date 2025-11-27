import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../utils/app_theme.dart';
import '../../../domain/entity/course.dart';
import '../../../domain/entity/teacher.dart';
import '../../../data/repository_impl/course_service.dart';
import '../../../data/repository_impl/statistics_service.dart';

class CoursesDashboardPage extends StatefulWidget {
  const CoursesDashboardPage({super.key});

  @override
  State<CoursesDashboardPage> createState() => _CoursesDashboardPageState();
}

class _CoursesDashboardPageState extends State<CoursesDashboardPage> {
  final CourseService _courseService = CourseService();
  final StatisticsService _statisticsService = StatisticsService();
  
  List<Course> _courses = [];
  List<Teacher> _teachers = [];
  CourseStatistics? _courseStats;
  TeacherStatistics? _teacherStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final courses = await _courseService.getAllCourses();
      final teachers = await _courseService.getTeachers();
      
      final courseStats = _statisticsService.generateCourseStatistics(courses);
      final teacherStats = _statisticsService.generateTeacherStatistics(teachers, courses);
      
      setState(() {
        _courses = courses;
        _teachers = teachers;
        _courseStats = courseStats;
        _teacherStats = teacherStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al cargar estadísticas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Cursos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading ? _buildLoading() : _buildDashboard(),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildDashboard() {
    if (_courseStats == null || _teacherStats == null) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(),
          const SizedBox(height: 20),
          _buildCoursesByTypeChart(),
          const SizedBox(height: 20),
          _buildCoursesByPlanChart(),
          const SizedBox(height: 20),
          _buildTeacherLoadChart(),
          const SizedBox(height: 20),
          _buildHoursDistributionCard(),
          const SizedBox(height: 20),
          _buildTopSchoolsCard(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No hay datos disponibles',
               style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen General',
             style: Theme.of(context).textTheme.titleLarge?.copyWith(
               fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(
              'Total Cursos', 
              '${_courseStats!.totalCourses}',
              Icons.school,
              AppColors.primary,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
              'Total Profesores',
              '${_teacherStats!.totalTeachers}',
              Icons.person,
              Colors.blue,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(
              'Horas Teóricas',
              '${_courseStats!.totalTheoreticalHours}h',
              Icons.menu_book,
              Colors.orange,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
              'Horas Prácticas',
              '${_courseStats!.totalPracticalHours}h',
              Icons.build,
              Colors.green,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(value,
                   style: TextStyle(
                     fontSize: 24,
                     fontWeight: FontWeight.bold,
                     color: color,
                   )),
            ],
          ),
          const SizedBox(height: 8),
          Text(title,
               style: TextStyle(
                 color: Colors.grey[700],
                 fontWeight: FontWeight.w600,
               )),
        ],
      ),
    );
  }

  Widget _buildCoursesByTypeChart() {
    return _buildChartCard(
      title: 'Cursos por Tipo',
      icon: Icons.category,
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sections: _courseStats!.coursesByType.entries.map((entry) {
              final index = _courseStats!.coursesByType.keys.toList().indexOf(entry.key);
              return PieChartSectionData(
                color: _getChartColor(index),
                value: entry.value.toDouble(),
                title: '${entry.value}',
                radius: 80,
                titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
            centerSpaceRadius: 40,
            sectionsSpace: 2,
          ),
        ),
      ),
      legend: _courseStats!.coursesByType.entries.map((entry) {
        final index = _courseStats!.coursesByType.keys.toList().indexOf(entry.key);
        return _buildLegendItem(entry.key, _getChartColor(index));
      }).toList(),
    );
  }

  Widget _buildCoursesByPlanChart() {
    return _buildChartCard(
      title: 'Cursos por Plan de Estudios',
      icon: Icons.assignment,
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _courseStats!.coursesByPlan.values.isEmpty 
                ? 10 
                : _courseStats!.coursesByPlan.values.reduce((a, b) => a > b ? a : b).toDouble() + 2,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final plans = _courseStats!.coursesByPlan.keys.toList();
                    if (value.toInt() < plans.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          plans[value.toInt()],
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString());
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true, horizontalInterval: 1),
            borderData: FlBorderData(show: false),
            barGroups: _courseStats!.coursesByPlan.entries.map((entry) {
              final index = _courseStats!.coursesByPlan.keys.toList().indexOf(entry.key);
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.toDouble(),
                    color: AppColors.primary,
                    width: 20,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherLoadChart() {
    return _buildChartCard(
      title: 'Distribución de Carga Docente',
      icon: Icons.person_outline,
      child: SizedBox(
        height: 150,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _teacherStats!.courseLoadDistribution.values.isEmpty
                ? 5
                : _teacherStats!.courseLoadDistribution.values.reduce((a, b) => a > b ? a : b).toDouble() + 1,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final loads = _teacherStats!.courseLoadDistribution.keys.toList();
                    if (value.toInt() < loads.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          loads[value.toInt()],
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString());
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: false),
            barGroups: _teacherStats!.courseLoadDistribution.entries.map((entry) {
              final index = _teacherStats!.courseLoadDistribution.keys.toList().indexOf(entry.key);
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.toDouble(),
                    color: Colors.blue,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildHoursDistributionCard() {
    final theoreticalPercent = (_courseStats!.totalTheoreticalHours / 
        (_courseStats!.totalTheoreticalHours + _courseStats!.totalPracticalHours) * 100).round();
    final practicalPercent = 100 - theoreticalPercent;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Distribución de Horas',
                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
                       fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: _courseStats!.totalTheoreticalHours,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('$theoreticalPercent%',
                           style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: _courseStats!.totalPracticalHours,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('$practicalPercent%',
                           style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Teóricas (${_courseStats!.totalTheoreticalHours}h)', Colors.blue),
                _buildLegendItem('Prácticas (${_courseStats!.totalPracticalHours}h)', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSchoolsCard() {
    final schools = _courseStats!.coursesBySchool.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topSchools = schools.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Top Escuelas Profesionales',
                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
                       fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...topSchools.map((school) => _buildSchoolItem(school.key, school.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolItem(String schoolName, int courseCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(schoolName)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$courseCount',
                 style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required Widget child,
    List<Widget>? legend,
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
                Text(title,
                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
                       fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            child,
            if (legend != null) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: legend,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Color _getChartColor(int index) {
    const colors = [
      AppColors.primary,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}