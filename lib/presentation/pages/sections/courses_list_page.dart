import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../data/repository_impl/course_service.dart';
import '../../../domain/entity/course.dart';
import '../course_form_page.dart';
import '../course_detail_page.dart';

class CoursesListPage extends StatefulWidget {
  const CoursesListPage({super.key});

  @override
  State<CoursesListPage> createState() => _CoursesListPageState();
}

class _CoursesListPageState extends State<CoursesListPage> {
  final CourseService _service = CourseService();
  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  List<CourseType> _courseTypes = [];
  List<Plan> _plans = [];
  
  String _searchQuery = '';
  int? _selectedTypeId;
  int? _selectedPlanId;
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
      final courses = await _service.getAllCourses();
      final types = await _service.getCourseTypes();
      final plans = await _service.getPlans();
      
      setState(() {
        _allCourses = courses;
        _courseTypes = types;
        _plans = plans;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al cargar datos: $e');
    }
  }

  void _applyFilters() {
    _filteredCourses = _service.filterCourses(
      _allCourses,
      search: _searchQuery,
      courseTypeId: _selectedTypeId,
      planId: _selectedPlanId,
      sortBy: _sortBy,
      ascending: _ascending,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        title: const Text('Cursos'),
        centerTitle: true,
      ),
      body: _isLoading ? _buildLoading() : _buildContent(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _createNewCourse,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildFilters(),
            const SizedBox(height: 12),
            _buildSortOptions(),
            const SizedBox(height: 12),
            _buildStatsBar(),
            const SizedBox(height: 12),
            Expanded(child: _buildCoursesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Buscar cursos por nombre, código o descripción',
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
          _applyFilters();
        });
      },
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(child: _buildTypeFilter()),
        const SizedBox(width: 12),
        Expanded(child: _buildPlanFilter()),
      ],
    );
  }

  Widget _buildTypeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<int?>(
        value: _selectedTypeId,
        hint: const Text('Tipo de curso'),
        isExpanded: true,
        underline: const SizedBox(),
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('Todos los tipos'),
          ),
          ..._courseTypes.map((type) => DropdownMenuItem<int?>(
            value: type.idCourseType,
            child: Text(type.name),
          )),
        ],
        onChanged: (value) {
          setState(() {
            _selectedTypeId = value;
            _applyFilters();
          });
        },
      ),
    );
  }

  Widget _buildPlanFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<int?>(
        value: _selectedPlanId,
        hint: const Text('Plan de estudios'),
        isExpanded: true,
        underline: const SizedBox(),
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('Todos los planes'),
          ),
          ..._plans.map((plan) => DropdownMenuItem<int?>(
            value: plan.idPlan,
            child: Text(plan.name),
          )),
        ],
        onChanged: (value) {
          setState(() {
            _selectedPlanId = value;
            _applyFilters();
          });
        },
      ),
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
              DropdownMenuItem(value: 'code', child: Text('Código')),
              DropdownMenuItem(value: 'courseType', child: Text('Tipo')),
              DropdownMenuItem(value: 'plan', child: Text('Plan')),
            ],
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
                _applyFilters();
              });
            },
          ),
        ),
        IconButton(
          icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
          onPressed: () {
            setState(() {
              _ascending = !_ascending;
              _applyFilters();
            });
          },
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total: ${_filteredCourses.length} cursos'),
          if (_allCourses.length != _filteredCourses.length)
            Text('(${_allCourses.length} total)',
                 style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildCoursesList() {
    if (_filteredCourses.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      itemCount: _filteredCourses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final course = _filteredCourses[index];
        return _buildCourseCard(course);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, 
               size: 64, 
               color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No se encontraron cursos',
               style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(_searchQuery.isNotEmpty 
               ? 'Intenta con otros términos de búsqueda'
               : 'Crea tu primer curso',
               style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.school, color: AppColors.primary),
        ),
        title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${course.code}'),
            Text('Tipo: ${course.courseType.name}'),
            Text('Plan: ${course.plan.name}'),
            Text('Duración: ${_formatDuration(course.duration)}'),
          ],
        ),
        isThreeLine: true,
        onTap: () => _viewCourseDetail(course),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleCourseAction(value, course),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Editar')),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else {
      return '${duration.inMinutes}min';
    }
  }

  void _handleCourseAction(String action, Course course) {
    switch (action) {
      case 'edit':
        _editCourse(course);
        break;
      case 'delete':
        _confirmDeleteCourse(course);
        break;
    }
  }

  void _createNewCourse() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseFormPage(service: _service),
      ),
    ).then((_) => _loadData());
  }

  void _editCourse(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseFormPage(service: _service, existingCourse: course),
      ),
    ).then((_) => _loadData());
  }

  void _viewCourseDetail(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailPage(course: course, service: _service),
      ),
    );
  }

  void _confirmDeleteCourse(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar el curso "${course.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCourse(course);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCourse(Course course) async {
    try {
      await _service.deleteCourse(course.idCourse);
      _showSuccess('Curso eliminado correctamente');
      _loadData();
    } catch (e) {
      _showError('Error al eliminar curso: $e');
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
}
