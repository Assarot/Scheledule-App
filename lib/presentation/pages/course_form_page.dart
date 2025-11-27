import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_theme.dart';
import '../../domain/entity/course.dart';
import '../../data/repository_impl/course_service.dart';
import '../widgets/app_text_field.dart';

class CourseFormPage extends StatefulWidget {
  final CourseService service;
  final Course? existingCourse;

  const CourseFormPage({
    super.key,
    required this.service,
    this.existingCourse,
  });

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _theoreticalHoursController = TextEditingController();
  final _practicalHoursController = TextEditingController();

  List<CourseType> _courseTypes = [];
  List<Plan> _plans = [];
  List<Group> _groups = [];

  CourseType? _selectedCourseType;
  Plan? _selectedPlan;
  Group? _selectedGroup;

  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initializeFormData();
  }

  void _initializeFormData() {
    if (widget.existingCourse != null) {
      final course = widget.existingCourse!;
      _nameController.text = course.name;
      _codeController.text = course.code;
      _descriptionController.text = course.description;
      _durationController.text = course.duration.inMinutes.toString();
      _theoreticalHoursController.text = course.theoreticalHours.inMinutes.toString();
      _practicalHoursController.text = course.practicalHours.inMinutes.toString();
    }
  }

  Future<void> _loadData() async {
    try {
      final types = await widget.service.getCourseTypes();
      final plans = await widget.service.getPlans();
      final groups = await widget.service.getGroups();

      setState(() {
        _courseTypes = types;
        _plans = plans;
        _groups = groups;
        
        // Preseleccionar datos si es edición
        if (widget.existingCourse != null) {
          final course = widget.existingCourse!;
          _selectedCourseType = types.firstWhere(
            (t) => t.idCourseType == course.courseType.idCourseType,
            orElse: () => types.first,
          );
          _selectedPlan = plans.firstWhere(
            (p) => p.idPlan == course.plan.idPlan,
            orElse: () => plans.first,
          );
          _selectedGroup = groups.firstWhere(
            (g) => g.idGroup == course.group.idGroup,
            orElse: () => groups.first,
          );
        }
        
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      _showError('Error al cargar datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCourse != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Curso' : 'Nuevo Curso'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: _isLoadingData ? _buildLoading() : _buildForm(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildForm() {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildTimeSection(),
            const SizedBox(height: 24),
            _buildRelationsSection(),
            const SizedBox(height: 100), // Espacio para el botón flotante
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información Básica',
                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
                   fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Nombre del Curso',
              hint: 'Ej: Programación Orientada a Objetos',
              controller: _nameController,
              leadingIcon: Icons.school,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Código del Curso',
              hint: 'Ej: 202310615',
              controller: _codeController,
              leadingIcon: Icons.qr_code,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Descripción',
              hint: 'Describe brevemente el curso',
              controller: _descriptionController,
              leadingIcon: Icons.description,
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distribución de Tiempo',
                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
                   fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Duración Total',
                    hint: 'Minutos',
                    controller: _durationController,
                    leadingIcon: Icons.schedule,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.info_outline, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Horas Teóricas',
                    hint: 'Minutos',
                    controller: _theoreticalHoursController,
                    leadingIcon: Icons.menu_book,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Horas Prácticas',
                    hint: 'Minutos',
                    controller: _practicalHoursController,
                    leadingIcon: Icons.build,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Nota: Ingrese todos los tiempos en minutos',
                 style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clasificación y Asignación',
                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
                   fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDropdown<CourseType>(
              label: 'Tipo de Curso',
              value: _selectedCourseType,
              items: _courseTypes,
              itemText: (type) => type.name,
              onChanged: (type) => setState(() => _selectedCourseType = type),
              icon: Icons.category,
            ),
            const SizedBox(height: 16),
            _buildDropdown<Plan>(
              label: 'Plan de Estudios',
              value: _selectedPlan,
              items: _plans,
              itemText: (plan) => plan.name,
              onChanged: (plan) => setState(() => _selectedPlan = plan),
              icon: Icons.assignment,
            ),
            const SizedBox(height: 16),
            _buildDropdown<Group>(
              label: 'Grupo',
              value: _selectedGroup,
              items: _groups,
              itemText: (group) => 'Grupo ${group.groupNumber} (${group.capacity} estudiantes)',
              onChanged: (group) => setState(() => _selectedGroup = group),
              icon: Icons.group,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemText,
    required void Function(T?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
               color: AppColors.hint)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.fieldFill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.hint),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<T>(
                  value: value,
                  hint: Text('Seleccionar $label'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: items.map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(itemText(item)),
                  )).toList(),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveCourse,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.existingCourse != null ? 'Actualizar Curso' : 'Crear Curso'),
          ),
        ),
      ),
    );
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateSelections()) return;

    setState(() => _isLoading = true);

    try {
      final theoreticalMinutes = int.parse(_theoreticalHoursController.text);
      final practicalMinutes = int.parse(_practicalHoursController.text);
      final totalMinutes = theoreticalMinutes + practicalMinutes;
      
      final course = Course(
        idCourse: widget.existingCourse?.idCourse ?? 0,
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        description: _descriptionController.text.trim(),
        duration: Duration(minutes: int.parse(_durationController.text)),
        theoreticalHours: Duration(minutes: theoreticalMinutes),
        practicalHours: Duration(minutes: practicalMinutes),
        totalHours: Duration(minutes: totalMinutes),
        courseType: _selectedCourseType!,
        plan: _selectedPlan!,
        group: _selectedGroup!,
      );

      if (widget.existingCourse != null) {
        await widget.service.updateCourse(widget.existingCourse!.idCourse, course);
        _showSuccess('Curso actualizado correctamente');
      } else {
        await widget.service.createCourse(course);
        _showSuccess('Curso creado correctamente');
      }

      Navigator.pop(context, true);
    } catch (e) {
      _showError('Error al guardar curso: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateSelections() {
    if (_selectedCourseType == null) {
      _showError('Selecciona un tipo de curso');
      return false;
    }
    if (_selectedPlan == null) {
      _showError('Selecciona un plan de estudios');
      return false;
    }
    if (_selectedGroup == null) {
      _showError('Selecciona un grupo');
      return false;
    }
    return true;
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar este curso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCourse();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCourse() async {
    if (widget.existingCourse == null) return;

    setState(() => _isLoading = true);
    try {
      await widget.service.deleteCourse(widget.existingCourse!.idCourse);
      _showSuccess('Curso eliminado correctamente');
      Navigator.pop(context, true);
    } catch (e) {
      _showError('Error al eliminar curso: $e');
    } finally {
      setState(() => _isLoading = false);
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

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _theoreticalHoursController.dispose();
    _practicalHoursController.dispose();
    super.dispose();
  }
}