import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../utils/app_theme.dart';
import '../../domain/entity/course.dart';
import '../../domain/entity/teacher.dart';
import '../../data/repository_impl/course_service.dart';
import '../../data/repository_impl/report_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final CourseService _courseService = CourseService();
  final ReportService _reportService = ReportService();
  
  bool _isLoading = false;
  List<Course> _courses = [];
  List<Teacher> _teachers = [];

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
      
      setState(() {
        _courses = courses;
        _teachers = teachers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al cargar datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading ? _buildLoading() : _buildReportsList(),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildReportsList() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Reportes Disponibles'),
            const SizedBox(height: 16),
            _buildDataSummary(),
            const SizedBox(height: 24),
            Expanded(child: _buildReportsGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildDataSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Cursos', _courses.length, Icons.book),
          _buildSummaryItem('Profesores', _teachers.length, Icons.person),
          _buildSummaryItem(
            'Créditos Total', 
            _courses.fold<int>(0, (sum, course) => sum + course.credits),
            Icons.school,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 32),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildReportsGrid() {
    final reports = [
      ReportInfo(
        title: 'Reporte de Cursos',
        description: 'Listado completo de todos los cursos registrados con sus detalles',
        icon: Icons.list_alt,
        color: Colors.blue,
        onGenerate: _generateCoursesReport,
      ),
      ReportInfo(
        title: 'Estadísticas Académicas',
        description: 'Análisis estadístico de cursos, créditos y distribución por tipos',
        icon: Icons.analytics,
        color: Colors.green,
        onGenerate: _generateStatisticsReport,
      ),
      ReportInfo(
        title: 'Profesores y Asignaciones',
        description: 'Detalle de profesores y sus asignaciones de cursos',
        icon: Icons.people,
        color: Colors.orange,
        onGenerate: _generateTeachersReport,
      ),
      ReportInfo(
        title: 'Reporte Personalizado',
        description: 'Próximamente: Crear reportes personalizados con filtros específicos',
        icon: Icons.tune,
        color: Colors.purple,
        onGenerate: null, // Deshabilitado por ahora
      ),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(ReportInfo report) {
    final isEnabled = report.onGenerate != null;
    
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: isEnabled ? () => _handleReportGeneration(report) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isEnabled ? null : Colors.grey[100],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isEnabled ? report.color : Colors.grey).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  report.icon,
                  size: 28,
                  color: isEnabled ? report.color : Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                report.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? null : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  report.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isEnabled ? Colors.grey[600] : Colors.grey,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isEnabled ? () => _handleReportGeneration(report) : null,
                  icon: Icon(
                    isEnabled ? Icons.picture_as_pdf : Icons.lock,
                    size: 14,
                  ),
                  label: Text(
                    isEnabled ? 'Generar PDF' : 'Próximamente',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEnabled ? report.color : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleReportGeneration(ReportInfo report) {
    if (report.onGenerate == null) {
      _showInfo('Esta funcionalidad estará disponible próximamente');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generar ${report.title}'),
        content: Text('¿Deseas generar y previsualizar el ${report.title.toLowerCase()}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              report.onGenerate!();
            },
            style: ElevatedButton.styleFrom(backgroundColor: report.color),
            child: const Text('Generar'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateCoursesReport() async {
    if (_courses.isEmpty) {
      _showError('No hay cursos disponibles para generar el reporte');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pdfData = await _reportService.generateCoursesReport(_courses);
      _showPdfPreview(pdfData, 'reporte_cursos.pdf');
    } catch (e) {
      _showError('Error al generar reporte de cursos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateStatisticsReport() async {
    if (_courses.isEmpty && _teachers.isEmpty) {
      _showError('No hay datos disponibles para generar el reporte');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pdfData = await _reportService.generateStatisticsReport(_courses, _teachers);
      _showPdfPreview(pdfData, 'reporte_estadisticas.pdf');
    } catch (e) {
      _showError('Error al generar reporte de estadísticas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateTeachersReport() async {
    if (_teachers.isEmpty) {
      _showError('No hay profesores disponibles para generar el reporte');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pdfData = await _reportService.generateTeachersReport(_teachers, _courses);
      _showPdfPreview(pdfData, 'reporte_profesores.pdf');
    } catch (e) {
      _showError('Error al generar reporte de profesores: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPdfPreview(Uint8List pdfData, String filename) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text('Vista Previa - $filename'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => Printing.sharePdf(
                  bytes: pdfData,
                  filename: filename,
                ),
              ),
            ],
          ),
          body: PdfPreview(
            build: (format) => Future.value(pdfData),
            allowPrinting: true,
            allowSharing: true,
            canChangeOrientation: false,
          ),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue),
    );
  }
}

class ReportInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback? onGenerate;

  const ReportInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.onGenerate,
  });
}