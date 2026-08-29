import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final currentPath = GoRouterState.of(context).uri.toString();

    return Container(
      width: 250,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: textColor, width: 2),
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Area
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bebas(
                  AppStrings.appName,
                  fontSize: 28,
                  letterSpacing: 2.0,
                  color: textColor,
                ),
                AppText.spaceMono(
                  AppStrings.adminPanelVer,
                  fontSize: 10,
                  color: textColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Navigation Links
          _buildNavItem(
            context: context,
            title: AppStrings.adminNavDashboard,
            icon: Icons.dashboard_outlined,
            route: '/admin/dashboard',
            isActive: currentPath == '/admin/dashboard' || currentPath == '/admin',
            textColor: textColor,
          ),
          _buildNavItem(
            context: context,
            title: AppStrings.adminNavOrders,
            icon: Icons.shopping_cart_outlined,
            route: '/admin/orders',
            isActive: currentPath.startsWith('/admin/orders'),
            textColor: textColor,
          ),
          _buildNavItem(
            context: context,
            title: 'PRODUCTS',
            icon: Icons.inventory_2_outlined,
            route: '/admin/products',
            isActive: currentPath.startsWith('/admin/products'),
            textColor: textColor,
          ),
          _buildNavItem(
            context: context,
            title: AppStrings.adminNavCustomers,
            icon: Icons.people_outline,
            route: '/admin/customers',
            isActive: currentPath.startsWith('/admin/customers'),
            textColor: textColor,
          ),
          _buildNavItem(
            context: context,
            title: 'BANNERS',
            icon: Icons.view_carousel_outlined,
            route: '/admin/banners',
            isActive: currentPath.startsWith('/admin/banners'),
            textColor: textColor,
          ),
          _buildNavItem(
            context: context,
            title: 'MARQUEE',
            icon: Icons.text_format_outlined,
            route: '/admin/marquee',
            isActive: currentPath.startsWith('/admin/marquee'),
            textColor: textColor,
          ),
          _buildNavItem(
            context: context,
            title: 'COLLECTIONS',
            icon: Icons.collections_outlined,
            route: '/admin/collections',
            isActive: currentPath.startsWith('/admin/collections'),
            textColor: textColor,
          ),
          _buildNavItem(
            context: context,
            title: AppStrings.adminNavSettings,
            icon: Icons.settings_outlined,
            route: '/admin/settings',
            isActive: currentPath.startsWith('/admin/settings'),
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String route,
    required bool isActive,
    required Color textColor,
  }) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: BrutalistHoverWidget(
        child: InkWell(
          onTap: () {
            if (!isActive) {
              context.go(route);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? textColor : surfaceColor,
              border: Border.all(color: textColor, width: 2),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? surfaceColor : textColor,
                ),
                const SizedBox(width: 16),
                AppText.spaceMono(
                  title,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isActive ? surfaceColor : textColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
