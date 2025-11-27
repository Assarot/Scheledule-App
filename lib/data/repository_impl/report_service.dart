import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import '../../../domain/entity/course.dart';
import '../../../domain/entity/teacher.dart';
import 'statistics_service.dart';

class ReportService {
  final StatisticsService _statisticsService = StatisticsService();

  // Generar reporte general de cursos
  Future<Uint8List> generateCoursesReport(List<Course> courses) async {
    final pdf = pw.Document();
    final font = await _loadFont();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: _buildTheme(font),
        header: (context) => _buildHeader('Reporte de Cursos'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildCoursesReportContent(courses),
        ],
      ),
    );
    
    return pdf.save();
  }

  // Generar reporte de estadísticas
  Future<Uint8List> generateStatisticsReport(
    List<Course> courses, 
    List<Teacher> teachers
  ) async {
    final pdf = pw.Document();
    final font = await _loadFont();
    final stats = _statisticsService.generateCourseStatistics(courses);
    final teacherStats = _statisticsService.generateTeacherStatistics(teachers, courses);
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: _buildTheme(font),
        header: (context) => _buildHeader('Reporte de Estadísticas Académicas'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildStatisticsContent(stats, teacherStats, courses.length, teachers.length),
        ],
      ),
    );
    
    return pdf.save();
  }

  // Generar reporte de profesores y asignaciones
  Future<Uint8List> generateTeachersReport(
    List<Teacher> teachers, 
    List<Course> courses
  ) async {
    final pdf = pw.Document();
    final font = await _loadFont();
    final teacherStats = _statisticsService.generateTeacherStatistics(teachers, courses);
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: _buildTheme(font),
        header: (context) => _buildHeader('Reporte de Profesores y Asignaciones'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildTeachersReportContent(teachers, teacherStats),
        ],
      ),
    );
    
    return pdf.save();
  }

  // Cargar fuente
  Future<pw.Font> _loadFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      // Si no se encuentra la fuente personalizada, usar fuente por defecto
      return pw.Font.helvetica();
    }
  }

  // Configurar tema del PDF
  pw.ThemeData _buildTheme(pw.Font font) {
    return pw.ThemeData.withFont(
      base: font,
      bold: font,
    );
  }

  // Header del documento
  pw.Widget _buildHeader(String title) {
    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SISTEMA ACADÉMICO',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generado: ${DateTime.now().toString().substring(0, 19)}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.Divider(thickness: 2),
        ],
      ),
    );
  }

  // Footer del documento
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Página ${context.pageNumber}/${context.pagesCount}',
        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
      ),
    );
  }

  // Contenido del reporte de cursos
  pw.Widget _buildCoursesReportContent(List<Course> courses) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'RESUMEN EJECUTIVO',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text('Total de cursos registrados: ${courses.length}'),
        pw.SizedBox(height: 20),
        
        pw.Text(
          'DETALLE DE CURSOS',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        
        _buildCoursesTable(courses),
      ],
    );
  }

  // Tabla de cursos
  pw.Widget _buildCoursesTable(List<Course> courses) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Código', isHeader: true),
            _buildTableCell('Nombre', isHeader: true),
            _buildTableCell('Créditos', isHeader: true),
            _buildTableCell('Horas', isHeader: true),
            _buildTableCell('Tipo', isHeader: true),
          ],
        ),
        // Data rows
        ...courses.map((course) => pw.TableRow(
          children: [
            _buildTableCell(course.code),
            _buildTableCell(course.name),
            _buildTableCell(course.credits.toString()),
            _buildTableCell('${course.duration.inHours}h'),
            _buildTableCell(course.courseType.name),
          ],
        )),
      ],
    );
  }

  // Contenido del reporte de estadísticas
  pw.Widget _buildStatisticsContent(
    CourseStatistics stats,
    TeacherStatistics teacherStats,
    int totalCourses,
    int totalTeachers,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'RESUMEN GENERAL',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        
        // Estadísticas generales
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(
            children: [
              _buildStatRow('Total de Cursos:', totalCourses.toString()),
              _buildStatRow('Total de Profesores:', totalTeachers.toString()),
              _buildStatRow('Total de Créditos:', stats.totalCredits.toString()),
              _buildStatRow('Promedio de Créditos por Curso:', 
                           (stats.totalCredits / totalCourses).toStringAsFixed(2)),
            ],
          ),
        ),
        
        pw.SizedBox(height: 20),
        
        pw.Text(
          'DISTRIBUCIÓN POR TIPO DE CURSO',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        
        _buildCourseTypeDistribution(stats),
        
        pw.SizedBox(height: 20),
        
        pw.Text(
          'CARGA DE TRABAJO DE PROFESORES',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        
        _buildTeacherWorkload(teacherStats),
      ],
    );
  }

  // Fila de estadística
  pw.Widget _buildStatRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  // Distribución por tipo de curso
  pw.Widget _buildCourseTypeDistribution(CourseStatistics stats) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Tipo de Curso', isHeader: true),
            _buildTableCell('Cantidad', isHeader: true),
            _buildTableCell('Porcentaje', isHeader: true),
          ],
        ),
        ...stats.coursesByType.entries.map((entry) {
          final percentage = (entry.value / stats.totalCourses * 100).toStringAsFixed(1);
          return pw.TableRow(
            children: [
              _buildTableCell(entry.key),
              _buildTableCell(entry.value.toString()),
              _buildTableCell('$percentage%'),
            ],
          );
        }),
      ],
    );
  }

  // Carga de trabajo de profesores
  pw.Widget _buildTeacherWorkload(TeacherStatistics stats) {
    return pw.Column(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(
            children: [
              _buildStatRow('Profesores con carga completa (≥5 cursos):', 
                           stats.workloadDistribution['high'].toString()),
              _buildStatRow('Profesores con carga media (3-4 cursos):', 
                           stats.workloadDistribution['medium'].toString()),
              _buildStatRow('Profesores con carga baja (1-2 cursos):', 
                           stats.workloadDistribution['low'].toString()),
              _buildStatRow('Profesores sin asignaciones:', 
                           stats.workloadDistribution['none'].toString()),
            ],
          ),
        ),
      ],
    );
  }

  // Contenido del reporte de profesores
  pw.Widget _buildTeachersReportContent(
    List<Teacher> teachers, 
    TeacherStatistics stats
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'RESUMEN DE PROFESORES',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text('Total de profesores: ${teachers.length}'),
        pw.SizedBox(height: 20),
        
        pw.Text(
          'DETALLE DE PROFESORES',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        
        _buildTeachersTable(teachers, stats),
      ],
    );
  }

  // Tabla de profesores
  pw.Widget _buildTeachersTable(List<Teacher> teachers, TeacherStatistics stats) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Nombre Completo', isHeader: true),
            _buildTableCell('Email', isHeader: true),
            _buildTableCell('Especialidad', isHeader: true),
            _buildTableCell('Cursos Asignados', isHeader: true),
          ],
        ),
        // Data rows
        ...teachers.map((teacher) {
          final assignedCount = stats.teacherAssignments[teacher.idTeacher]?.length ?? 0;
          return pw.TableRow(
            children: [
              _buildTableCell(teacher.fullName),
              _buildTableCell(teacher.email),
              _buildTableCell(teacher.specialty ?? 'N/A'),
              _buildTableCell(assignedCount.toString()),
            ],
          );
        }),
      ],
    );
  }

  // Helper para celdas de tabla
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}