import 'package:flutter/material.dart';

class NavigationItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int index;
  final List<String> allowedRoles;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.index,
    required this.allowedRoles,
  });
}

class RoleBasedNavigation {
  // Definición de todas las secciones disponibles
  static const home = NavigationItem(
    label: 'Inicio',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    index: 0,
    allowedRoles: ['ADMIN', 'COOROOMS', 'ASACAD'], // Todos pueden ver inicio
  );

  static const environments = NavigationItem(
    label: 'Ambientes',
    icon: Icons.apartment_outlined,
    selectedIcon: Icons.apartment,
    index: 1,
    allowedRoles: ['ADMIN', 'COOROOMS'], // Solo ADMIN y COOROOMS
  );

  static const resources = NavigationItem(
    label: 'Recursos',
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2,
    index: 2,
    allowedRoles: ['ADMIN', 'COOROOMS'], // Solo ADMIN y COOROOMS
  );

  static const courses = NavigationItem(
    label: 'Cursos',
    icon: Icons.school_outlined,
    selectedIcon: Icons.school,
    index: 3,
    allowedRoles: ['ADMIN', 'ASACAD'], // ADMIN y ASACAD pueden ver cursos
  );

  static const teachers = NavigationItem(
    label: 'Profesores',
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
    index: 4,
    allowedRoles: ['ADMIN', 'ASACAD'], // ADMIN y ASACAD pueden gestionar profesores
  );

  static const dashboard = NavigationItem(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    index: 5,
    allowedRoles: ['ADMIN'], // Solo ADMIN puede ver dashboard completo
  );

  static const reports = NavigationItem(
    label: 'Reportes',
    icon: Icons.assessment_outlined,
    selectedIcon: Icons.assessment,
    index: 6,
    allowedRoles: ['ADMIN', 'ASACAD'], // ADMIN y ASACAD pueden generar reportes
  );

  static const profile = NavigationItem(
    label: 'Perfil',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    index: 7,
    allowedRoles: ['ADMIN', 'COOROOMS', 'ASACAD'], // Todos pueden ver perfil
  );

  // Lista completa de navegación en orden - MENÚ SIMPLIFICADO
  static const List<NavigationItem> allItems = [
    home,      // Contendrá Dashboard y Reportes
    environments,
    resources,
    courses,   // Contendrá Profesores
    profile,
  ];

  /// Filtra los items de navegación según los roles del usuario
  static List<NavigationItem> getItemsForRoles(List<String> userRoles) {
    if (userRoles.isEmpty) return [home, profile]; // Mínimo: inicio y perfil

    return allItems.where((item) {
      // Si el usuario tiene algún rol permitido para este item
      return item.allowedRoles.any((role) => userRoles.contains(role));
    }).toList();
  }

  /// Verifica si el usuario tiene acceso a una sección específica
  static bool hasAccess(List<String> userRoles, NavigationItem item) {
    return item.allowedRoles.any((role) => userRoles.contains(role));
  }

  /// Obtiene el índice real de la página basado en el índice visual
  static int getRealPageIndex(
    List<NavigationItem> visibleItems,
    int visualIndex,
  ) {
    if (visualIndex < 0 || visualIndex >= visibleItems.length) return 0;
    return visibleItems[visualIndex].index;
  }
}
