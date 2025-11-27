import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../domain/entity/teacher.dart';
import '../../domain/entity/course.dart';
import '../../data/repository_impl/course_service.dart';
import '../../data/repository_impl/statistics_service.dart';
import 'teacher_form_page.dart';

class TeacherManagementPage extends StatefulWidget {
  const TeacherManagementPage({super.key});

  @override
  State<TeacherManagementPage> createState() => _TeacherManagementPageState();
}

class _TeacherManagementPageState extends State<TeacherManagementPage> {
  final CourseService _service = CourseService();
  final StatisticsService _statisticsService = StatisticsService();
  
  List<Teacher> _teachers = [];
  List<Course> _courses = [];
  Map<int, List<Course>> _teacherAssignments = {};
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _ascending = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final teachers = await _service.getTeachers();
      final courses = await _service.getAllCourses();
      final teacherStats = _statisticsService.generateTeacherStatistics(teachers, courses);
      
      setState(() {
        _teachers = teachers;
        _courses = courses;
        _teacherAssignments = teacherStats.teacherAssignments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al cargar datos: $e');
    }
  }

  List<Teacher> get _filteredTeachers {
    var filtered = _teachers.where((teacher) {
      if (_searchQuery.isEmpty) return true;
      return teacher.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             teacher.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.fullName.compareTo(b.fullName);
          break;
        case 'email':
          comparison = a.email.compareTo(b.email);
          break;
        case 'courses':
          final aCount = _teacherAssignments[a.idTeacher]?.length ?? 0;
          final bCount = _teacherAssignments[b.idTeacher]?.length ?? 0;
          comparison = aCount.compareTo(bCount);
          break;
        default:
          comparison = a.fullName.compareTo(b.fullName);
      }
      return _ascending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Profesores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading ? _buildLoading() : _buildContent(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _createNewTeacher,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildSortOptions(),
            const SizedBox(height: 12),
            _buildStatsBar(),
            const SizedBox(height: 12),
            Expanded(child: _buildTeachersList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Buscar profesores por nombre o email',
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: (value) {
        setState(() => _searchQuery = value);
      },
    );
  }

  Widget _buildSortOptions() {
    return Row(
      children: [
        Text('Ordenar por:', 
             style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.hint)),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<String>(
            value: _sortBy,
            isDense: true,
            items: const [
              DropdownMenuItem(value: 'name', child: Text('Nombre')),
              DropdownMenuItem(value: 'email', child: Text('Email')),
              DropdownMenuItem(value: 'courses', child: Text('Cursos asignados')),
            ],
            onChanged: (value) {
              setState(() => _sortBy = value!);
            },
          ),
        ),
        IconButton(
          icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
          onPressed: () {
            setState(() => _ascending = !_ascending);
          },
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    final filteredCount = _filteredTeachers.length;
    final totalAssignments = _teacherAssignments.values.fold(0, (sum, courses) => sum + courses.length);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total: $filteredCount profesores'),
          Text('$totalAssignments asignaciones activas'),
        ],
      ),
    );
  }

  Widget _buildTeachersList() {
    final filtered = _filteredTeachers;
    
    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final teacher = filtered[index];
        return _buildTeacherCard(teacher);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, 
               size: 64, 
               color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No se encontraron profesores',
               style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(_searchQuery.isNotEmpty 
               ? 'Intenta con otros términos de búsqueda'
               : 'Agrega tu primer profesor',
               style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(Teacher teacher) {
    final assignedCourses = _teacherAssignments[teacher.idTeacher] ?? [];
    final courseCount = assignedCourses.length;
    
    return Card(
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getLoadColor(courseCount).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.person, color: _getLoadColor(courseCount)),
        ),
        title: Text(teacher.fullName, 
                    style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${teacher.email}'),
            Text('Cursos asignados: $courseCount',
                 style: TextStyle(
                   color: _getLoadColor(courseCount),
                   fontWeight: FontWeight.w600,
                 )),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleTeacherAction(value, teacher),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Editar')),
            const PopupMenuItem(value: 'assign', child: Text('Asignar cursos')),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: assignedCourses.isNotEmpty 
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cursos Asignados:',
                         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    ...assignedCourses.map((course) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('${course.name} (${course.code})'),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                )
              : Text('Sin cursos asignados',
                     style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  Color _getLoadColor(int courseCount) {
    if (courseCount == 0) return Colors.grey;
    if (courseCount <= 2) return Colors.green;
    if (courseCount <= 4) return Colors.orange;
    return Colors.red;
  }

  void _handleTeacherAction(String action, Teacher teacher) {
    switch (action) {
      case 'edit':
        _editTeacher(teacher);
        break;
      case 'assign':
        _assignCourses(teacher);
        break;
      case 'delete':
        _confirmDeleteTeacher(teacher);
        break;
    }
  }

  void _createNewTeacher() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TeacherFormPage(),
      ),
    ).then((_) => _loadData());
  }

  void _editTeacher(Teacher teacher) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherFormPage(existingTeacher: teacher),
      ),
    ).then((_) => _loadData());
  }

  void _assignCourses(Teacher teacher) {
    // TODO: Implementar página de asignación de cursos
    _showInfo('Funcionalidad de asignación próximamente');
  }

  void _confirmDeleteTeacher(Teacher teacher) {
    final assignedCourses = _teacherAssignments[teacher.idTeacher]?.length ?? 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de eliminar al profesor "${teacher.fullName}"?'),
            if (assignedCourses > 0) ...[
              const SizedBox(height: 8),
              Text('Advertencia: Este profesor tiene $assignedCourses curso(s) asignado(s).',
                   style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTeacher(teacher);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTeacher(Teacher teacher) async {
    try {
      // TODO: Implementar eliminación en el servicio
      _showSuccess('Profesor eliminado correctamente');
      _loadData();
    } catch (e) {
      _showError('Error al eliminar profesor: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue),
    );
  }
}