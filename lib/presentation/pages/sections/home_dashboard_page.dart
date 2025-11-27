import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/auth_service.dart';
import '../../../data/datasources/academic_space_remote_datasource.dart';
import '../../../data/datasources/resource_remote_datasource.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../utils/cache_service.dart';
import '../../../utils/connectivity_service.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  final _academicSpaceDataSource = AcademicSpaceRemoteDataSource();
  final _resourceDataSource = ResourceRemoteDataSource();
  final _authLocalDataSource = AuthLocalDataSource();
  final _cacheService = CacheService();

  int _totalEnvironments = 0;
  int _totalResources = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final connectivityService = context.read<ConnectivityService>();

      if (connectivityService.isOnline) {
        // Modo online: cargar desde backend
        final accessToken = await _authLocalDataSource.getAccessToken();
        if (accessToken != null) {
          final environments = await _academicSpaceDataSource.getAll(
            accessToken,
          );
          final resources = await _resourceDataSource.getAll(accessToken);

          setState(() {
            _totalEnvironments = environments.length;
            _totalResources = resources.length;
            _isLoading = false;
          });
        }
      } else {
        // Modo offline: cargar desde cache
        final cachedEnvironments = await _cacheService
            .getCachedAcademicSpaces();
        final cachedResources = await _cacheService.getCachedResources();

        setState(() {
          _totalEnvironments = cachedEnvironments.length;
          _totalResources = cachedResources.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final roles = user?.roles ?? [];

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      Icons.dashboard,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, ${user?.name ?? "Usuario"}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          _getRoleLabel(roles),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                _buildDashboardContent(roles),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(List<String> roles) {
    // ADMIN y COOROOMS ven ambientes y recursos
    if (roles.contains('ADMIN') || roles.contains('COOROOMS')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ambientes Académicos',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _StatCard(
            icon: Icons.apartment,
            title: 'Total de Ambientes',
            value: '$_totalEnvironments',
            subtitle: 'Espacios registrados',
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          Text(
            'Recursos',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _StatCard(
            icon: Icons.inventory_2,
            title: 'Total de Recursos',
            value: '$_totalResources',
            subtitle: 'Diferentes recursos',
            color: Colors.green,
          ),
        ],
      );
    }

    // ASACAD solo ve cursos (simulado)
    if (roles.contains('ASACAD')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cursos',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _StatCard(
            icon: Icons.school,
            title: 'Cursos Activos',
            value: '24',
            subtitle: 'En este semestre (simulado)',
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _StatCard(
            icon: Icons.groups,
            title: 'Estudiantes',
            value: '850',
            subtitle: 'Total registrados (simulado)',
            color: Colors.purple,
          ),
        ],
      );
    }

    // Por defecto, vista básica
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.dashboard_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Dashboard',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleLabel(List<String> roles) {
    if (roles.contains('ADMIN')) return 'Administrador';
    if (roles.contains('COOROOMS')) return 'Coordinador de Ambientes';
    if (roles.contains('ASACAD')) return 'Coordinador Académico';
    return 'Usuario';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
