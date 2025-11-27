import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/auth_service.dart';
import '../../../utils/connectivity_service.dart';
import '../../../utils/cache_service.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/datasources/user_profile_remote_datasource.dart';
import '../../../data/datasources/auth_user_remote_datasource.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../login_page.dart';
import 'create_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfileModel? userProfile;
  bool isLoading = true;
  final ImagePicker _imagePicker = ImagePicker();
  final CacheService _cacheService = CacheService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final connectivityService = context.read<ConnectivityService>();
      final user = authService.currentUser;

      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      // Obtener el access token
      final localDataSource = AuthLocalDataSource();
      final accessToken = await localDataSource.getAccessToken();

      if (accessToken == null) {
        setState(() => isLoading = false);
        return;
      }

      // Intentar usar userProfileId del JWT primero
      int? profileId = user.userProfileId;

      // Si no está en el JWT, intentar obtenerlo del auth_user (solo si hay conexión)
      if (profileId == null && connectivityService.isOnline) {
        try {
          final authUserDataSource = AuthUserRemoteDataSource();
          final authUser = await authUserDataSource.getAuthUserById(
            int.parse(user.id),
            accessToken,
          );
          profileId = authUser.idUserProfile;
          print('✅ Got idUserProfile from auth_user: $profileId');
        } catch (e) {
          print('⚠️  Could not fetch auth_user: $e');
        }
      } else if (profileId != null) {
        print('✅ Using userProfileId from JWT: $profileId');
      }

      // Si no tiene profileId y está offline, intentar usar el último perfil cacheado
      if (profileId == null && !connectivityService.isOnline) {
        print('📱 Offline sin profileId - buscando último perfil en cache...');
        final lastCachedProfile = await _cacheService.getLastCachedProfile();
        if (lastCachedProfile != null) {
          print('✅ Usando último perfil cacheado');
          setState(() {
            userProfile = lastCachedProfile;
            isLoading = false;
          });
          return;
        }
      }

      // Si no tiene perfil (online) o no hay cache (offline), mostrar formulario
      if (profileId == null) {
        setState(() {
          isLoading = false;
          userProfile = null;
        });
        return;
      }

      // Intentar cargar desde cache primero
      final cachedProfile = await _cacheService.getCachedUserProfile(profileId);

      if (cachedProfile != null && !connectivityService.isOnline) {
        // Modo offline: usar cache
        print('📱 Usando perfil en caché (modo offline)');
        setState(() {
          userProfile = cachedProfile;
          isLoading = false;
        });
        return;
      }

      // Modo online o cache no disponible: cargar desde servidor
      if (connectivityService.isOnline) {
        try {
          final profileDataSource = UserProfileRemoteDataSource();
          final profile = await profileDataSource.getUserProfileById(
            profileId,
            accessToken,
          );

          // Guardar en cache
          await _cacheService.cacheUserProfile(profile);

          setState(() {
            userProfile = profile;
            isLoading = false;
          });
        } catch (e) {
          print('❌ Error cargando perfil del servidor: $e');
          // Si falla y hay cache, usar cache
          if (cachedProfile != null) {
            print('📱 Usando perfil en caché (fallback)');
            setState(() {
              userProfile = cachedProfile;
              isLoading = false;
            });
          } else {
            throw e;
          }
        }
      } else {
        // Sin conexión y sin cache
        setState(() {
          isLoading = false;
          userProfile = cachedProfile;
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        isLoading = false;
        userProfile = null;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      // Mostrar loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      // Obtener access token
      final localDataSource = AuthLocalDataSource();
      final accessToken = await localDataSource.getAccessToken();

      if (accessToken == null) {
        if (mounted) Navigator.pop(context);
        throw Exception('No se encontró token de acceso');
      }

      // Subir imagen
      final profileDataSource = UserProfileRemoteDataSource();
      final updatedProfile = await profileDataSource.updateProfilePicture(
        userProfile!.id,
        File(image.path),
        accessToken,
      );

      if (mounted) {
        Navigator.pop(context); // Cerrar loading
        setState(() {
          userProfile = updatedProfile;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada')),
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      if (mounted) {
        Navigator.pop(context); // Cerrar loading si está abierto
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al subir imagen: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(child: Text('No hay usuario autenticado'))
          : userProfile == null
          ? CreateProfilePage(
              authUserId: int.parse(user.id),
              onProfileCreated: (profile) {
                // Actualizar directamente sin hacer GET al endpoint restringido
                setState(() {
                  userProfile = profile;
                  isLoading = false;
                });
              },
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar con capacidad de editar
                  Stack(
                    children: [
                      userProfile?.profilePicture != null
                          ? CircleAvatar(
                              radius: 50,
                              backgroundImage: CachedNetworkImageProvider(
                                userProfile!.profilePicture!,
                              ),
                              backgroundColor: Colors.grey[200],
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                userProfile != null
                                    ? userProfile!.initials
                                    : user.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickAndUploadImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Nombre
                  Text(
                    userProfile != null
                        ? userProfile!.fullName
                        : '${user.name} ${user.lastName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  // Email del perfil
                  if (userProfile?.email != null)
                    Text(
                      userProfile!.email,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 8),
                  // Username
                  Text(
                    '@${user.username}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  // Roles
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.badge_outlined),
                              const SizedBox(width: 8),
                              Text(
                                'Roles',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: user.roles
                                .map(
                                  (role) => Chip(
                                    label: Text(role),
                                    backgroundColor: role == 'ADMIN'
                                        ? AppColors.primary.withOpacity(0.2)
                                        : Colors.grey[200],
                                    labelStyle: TextStyle(
                                      color: role == 'ADMIN'
                                          ? AppColors.primary
                                          : Colors.grey[800],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Información adicional
                  Card(
                    child: Column(
                      children: [
                        if (userProfile?.email != null)
                          ListTile(
                            leading: const Icon(Icons.email_outlined),
                            title: const Text('Correo Electrónico'),
                            subtitle: Text(userProfile!.email),
                          ),
                        if (userProfile?.email != null)
                          const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: const Text('Nombre de Usuario'),
                          subtitle: Text(user.username),
                        ),
                        if (userProfile?.phoneNumber != null)
                          const Divider(height: 1),
                        if (userProfile?.phoneNumber != null)
                          ListTile(
                            leading: const Icon(Icons.phone_outlined),
                            title: const Text('Teléfono'),
                            subtitle: Text(userProfile!.phoneNumber!),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botón de cerrar sesión
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar Sesión'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final authService = context.read<AuthService>();
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
