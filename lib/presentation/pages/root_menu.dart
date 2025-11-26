import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../data/repository_impl/resource_service.dart';
import 'sections/home_dashboard_page.dart';
import 'sections/environments_list_page.dart';
import 'sections/recursos_list_page.dart';
import 'sections/profile_page.dart';

class RootMenu extends StatefulWidget {
  const RootMenu({super.key});

  @override
  State<RootMenu> createState() => _RootMenuState();
}

class _RootMenuState extends State<RootMenu> {
  int currentIndex = 0;
  final ResourceService resourceService = ResourceService();

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeDashboardPage(),
      const EnvironmentsListPage(),
      RecursosListPage(service: resourceService),
      const ProfilePage(),
    ];
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        indicatorColor: AppColors.primary.withOpacity(0.15),
        selectedIndex: currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) => setState(() => currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment),
            label: 'Ambientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Recursos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
