import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../domain/entity/teacher.dart';
import '../../data/repository_impl/course_service.dart';

class TeacherFormPage extends StatefulWidget {
  final Teacher? existingTeacher;
  
  const TeacherFormPage({super.key, this.existingTeacher});

  @override
  State<TeacherFormPage> createState() => _TeacherFormPageState();
}

class _TeacherFormPageState extends State<TeacherFormPage> {
  final _formKey = GlobalKey<FormState>();
  final CourseService _service = CourseService();
  
  late TextEditingController _nameController;
  late TextEditingController _paternalSurnameController;
  late TextEditingController _maternalSurnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _specialtyController;
  
  bool _isLoading = false;
  bool get _isEditing => widget.existingTeacher != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final teacher = widget.existingTeacher;
    
    _nameController = TextEditingController(text: teacher?.name ?? '');
    _paternalSurnameController = TextEditingController(text: teacher?.paternalSurname ?? '');
    _maternalSurnameController = TextEditingController(text: teacher?.maternalSurname ?? '');
    _emailController = TextEditingController(text: teacher?.email ?? '');
    _phoneController = TextEditingController(text: teacher?.phone ?? '');
    _addressController = TextEditingController(text: teacher?.address ?? '');
    _specialtyController = TextEditingController(text: teacher?.specialty ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Profesor' : 'Nuevo Profesor'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: _isLoading ? _buildLoading() : _buildForm(),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Información Personal'),
            const SizedBox(height: 16),
            
            // Nombres
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _nameController,
                    label: 'Nombres',
                    validator: _requiredValidator,
                    icon: Icons.person,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Apellidos
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _paternalSurnameController,
                    label: 'Apellido Paterno',
                    validator: _requiredValidator,
                    icon: Icons.badge,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _maternalSurnameController,
                    label: 'Apellido Materno',
                    validator: _requiredValidator,
                    icon: Icons.badge_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Información de Contacto'),
            const SizedBox(height: 16),
            
            // Email
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              validator: _emailValidator,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            
            // Teléfono
            _buildTextField(
              controller: _phoneController,
              label: 'Teléfono (opcional)',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            
            // Dirección
            _buildTextField(
              controller: _addressController,
              label: 'Dirección (opcional)',
              icon: Icons.location_on,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Información Académica'),
            const SizedBox(height: 16),
            
            // Especialidad
            _buildTextField(
              controller: _specialtyController,
              label: 'Especialidad (opcional)',
              icon: Icons.school,
            ),
            const SizedBox(height: 32),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTeacher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_isEditing ? 'Actualizar' : 'Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es requerido';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un email válido';
    }
    
    return null;
  }

  Future<void> _saveTeacher() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final teacher = Teacher(
        idTeacher: widget.existingTeacher?.idTeacher ?? 0,
        name: _nameController.text.trim(),
        paternalSurname: _paternalSurnameController.text.trim(),
        maternalSurname: _maternalSurnameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        specialty: _specialtyController.text.trim().isEmpty ? null : _specialtyController.text.trim(),
      );

      if (_isEditing) {
        await _service.updateTeacher(teacher);
        _showSuccess('Profesor actualizado correctamente');
      } else {
        await _service.createTeacher(teacher);
        _showSuccess('Profesor creado correctamente');
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Error al guardar profesor: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de eliminar al profesor "${widget.existingTeacher?.fullName}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTeacher();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTeacher() async {
    if (widget.existingTeacher == null) return;

    setState(() => _isLoading = true);

    try {
      await _service.deleteTeacher(widget.existingTeacher!.idTeacher);
      _showSuccess('Profesor eliminado correctamente');
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Error al eliminar profesor: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  @override
  void dispose() {
    _nameController.dispose();
    _paternalSurnameController.dispose();
    _maternalSurnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }
}