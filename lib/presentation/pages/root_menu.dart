import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/auth_service.dart';
import '../../utils/connectivity_service.dart';
import '../../utils/role_based_navigation.dart';
import '../widgets/connectivity_banner.dart';
import 'sections/home_dashboard_page.dart';
import 'sections/environments_list_page_new.dart';
import 'sections/resources_list_page.dart';
import 'sections/courses_list_page.dart';
import 'sections/profile_page.dart';

class RootMenu extends StatefulWidget {
  const RootMenu({super.key});

  @override
  State<RootMenu> createState() => _RootMenuState();
}

class _RootMenuState extends State<RootMenu> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userRoles = authService.currentUser?.roles ?? [];

    // Obtener items de navegación filtrados por roles
    final navItems = RoleBasedNavigation.getItemsForRoles(userRoles);

    // Resetear currentIndex si está fuera del rango válido
    if (currentIndex >= navItems.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => currentIndex = 0);
      });
    }

    // Mapeo de páginas completo
    final allPages = {
      0: const HomeDashboardPage(),
      1: const EnvironmentsListPageNew(),
      2: const ResourcesListPage(),
      3: const CoursesListPage(),
      4: const ProfilePage(),
    };

    // Construir lista de páginas basada en items permitidos
    final pages = navItems.map((item) => allPages[item.index]!).toList();

    // Usar índice seguro para evitar RangeError
    final safeIndex = currentIndex < pages.length ? currentIndex : 0;

    final connectivityService = Provider.of<ConnectivityService>(context);

    return Scaffold(
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(child: pages[safeIndex]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        indicatorColor: AppColors.primary.withOpacity(0.15),
        selectedIndex: safeIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) => setState(() => currentIndex = i),
        destinations: navItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
            )
            .toList(),
      ),
      // Botón flotante de DEBUG para probar modo offline
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'debug_offline_fab',
        onPressed: () {
          connectivityService.toggleDebugOfflineMode();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                connectivityService.isOnline
                    ? '🟢 Modo ONLINE (debug)'
                    : '🔴 Modo OFFLINE (debug)',
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: connectivityService.isOnline
                  ? Colors.green
                  : Colors.orange,
            ),
          );
        },
        backgroundColor: Colors.purple[700],
        child: Icon(
          connectivityService.isOnline ? Icons.wifi : Icons.wifi_off,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
