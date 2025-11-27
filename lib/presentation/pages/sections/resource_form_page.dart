import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/datasources/resource_remote_datasource.dart';
import '../../../data/datasources/resource_type_remote_datasource.dart';
import '../../../data/datasources/inventory_state_remote_datasource.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/models/resource_model.dart';
import '../../../data/models/resource_type_model.dart';
import '../../../data/models/state_model.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/connectivity_service.dart';
import '../../../utils/cache_service.dart';

class ResourceFormPage extends StatefulWidget {
  final ResourceModel? resource;

  const ResourceFormPage({super.key, this.resource});

  @override
  State<ResourceFormPage> createState() => _ResourceFormPageState();
}

class _ResourceFormPageState extends State<ResourceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _stockController = TextEditingController();
  final _observationController = TextEditingController();

  final _resourceDataSource = ResourceRemoteDataSource();
  final _resourceTypeDataSource = ResourceTypeRemoteDataSource();
  final _stateDataSource = InventoryStateRemoteDataSource();
  final _authLocalDataSource = AuthLocalDataSource();
  final _cacheService = CacheService();

  List<ResourceTypeModel> _types = [];
  List<StateModel> _states = [];

  ResourceTypeModel? _selectedType;
  StateModel? _selectedState;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.resource != null;

    if (_isEditMode) {
      _codeController.text = widget.resource!.code;
      _stockController.text = widget.resource!.stock.toString();
      _observationController.text = widget.resource!.observation ?? '';
    }

    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      print('📋 Loading metadata for resource form...');
      final accessToken = await _authLocalDataSource.getAccessToken();
      if (accessToken == null) {
        print('❌ No access token found');
        setState(() => _isLoading = false);
        return;
      }

      print('📋 Fetching resource types...');
      final types = await _resourceTypeDataSource.getAll(accessToken);
      print('✅ Loaded ${types.length} resource types');

      print('📋 Fetching states...');
      final states = await _stateDataSource.getAll(accessToken);
      print('✅ Loaded ${states.length} states');

      setState(() {
        _types = types;
        _states = states;

        if (_isEditMode) {
          _selectedType = types
              .where((t) => t.id == widget.resource!.idResourceType)
              .firstOrNull;
          _selectedState = states
              .where((s) => s.id == widget.resource!.idState)
              .firstOrNull;
        }

        _isLoading = false;
      });
    } catch (e) {
      print('Error loading metadata: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar metadatos: $e')),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveResource() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un tipo de recurso')),
      );
      return;
    }

    if (_selectedState == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona un estado')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final connectivityService = context.read<ConnectivityService>();
      final isOnline = connectivityService.isOnline;

      final request = ResourceCreateRequest(
        stock: int.parse(_stockController.text),
        idResourceType: _selectedType!.id,
        idState: _selectedState!.id,
        code: _codeController.text.trim(),
        observation: _observationController.text.trim().isEmpty
            ? null
            : _observationController.text.trim(),
      );

      if (!isOnline) {
        // MODO OFFLINE: Guardar en cola
        final operation = {
          'type': _isEditMode ? 'update' : 'create',
          'data': {
            'entity': 'resource',
            'stock': request.stock,
            'idResourceType': request.idResourceType,
            'idState': request.idState,
            'code': request.code,
            if (request.observation != null) 'observation': request.observation,
            if (_isEditMode && widget.resource != null)
              'id': widget.resource!.id,
          },
        };

        await _cacheService.addPendingSync(operation);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '💾 Guardado localmente. Se sincronizará cuando haya conexión',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // MODO ONLINE: Guardar directo al backend
        final accessToken = await _authLocalDataSource.getAccessToken();
        if (accessToken == null) {
          throw Exception('No se encontró token de acceso');
        }

        if (_isEditMode && widget.resource != null) {
          await _resourceDataSource.update(
            widget.resource!.id,
            request,
            accessToken,
            imagePath: _imageFile?.path,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Recurso actualizado exitosamente'),
              ),
            );
          }
        } else {
          await _resourceDataSource.create(
            request,
            accessToken,
            imagePath: _imageFile?.path,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Recurso creado exitosamente')),
            );
          }
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print('Error saving resource: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error al guardar: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _stockController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Recurso' : 'Nuevo Recurso'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'Código *',
                        hintText: 'Ej: REC-001',
                        prefixIcon: const Icon(Icons.qr_code),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El código es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stockController,
                      decoration: InputDecoration(
                        labelText: 'Stock *',
                        hintText: 'Cantidad disponible',
                        prefixIcon: const Icon(Icons.inventory),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El stock es requerido';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Debe ser un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ResourceTypeModel>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Recurso *',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _types.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.name ?? 'ID: ${type.id}'),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedType = value),
                      validator: (value) {
                        if (value == null) {
                          return 'Selecciona un tipo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<StateModel>(
                      value: _selectedState,
                      decoration: InputDecoration(
                        labelText: 'Estado *',
                        prefixIcon: const Icon(Icons.info_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _states.map((state) {
                        return DropdownMenuItem(
                          value: state,
                          child: Text(state.name ?? 'ID: ${state.id}'),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedState = value),
                      validator: (value) {
                        if (value == null) {
                          return 'Selecciona un estado';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _observationController,
                      decoration: InputDecoration(
                        labelText: 'Observación',
                        hintText: 'Detalles adicionales (opcional)',
                        prefixIcon: const Icon(Icons.note),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    // Selector de imagen
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.photo_camera,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Foto del Recurso',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              if (_imageFile != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() => _imageFile = null);
                                  },
                                  tooltip: 'Eliminar imagen',
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_imageFile != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _imageFile!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          else if (_isEditMode &&
                              widget.resource?.resourcePhotoUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.resource!.resourcePhotoUrl!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 50),
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Sin imagen',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _showImageSourceDialog,
                              icon: const Icon(Icons.add_photo_alternate),
                              label: Text(
                                _imageFile != null ||
                                        (_isEditMode &&
                                            widget.resource?.resourcePhotoUrl !=
                                                null)
                                    ? 'Cambiar imagen'
                                    : 'Agregar imagen',
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveResource,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _isEditMode ? 'Actualizar' : 'Guardar',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
