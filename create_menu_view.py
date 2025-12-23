
#!/usr/bin/env python3

content = """import 'package:flutter/material.dart';
import '../../../../shared/widgets/right_drawer.dart';
import '../../../../core/config/routes.dart';
import '../widgets/menu_item_tile.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return AppSidebarRight(
      width: screenWidth,
      backgroundColor: colorScheme.surface,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header section
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Menu',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Menu items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionTitle(context, 'Main'),
                    const SizedBox(height: 8),
                    const MenuItemTile(
                      icon: Icons.home_outlined,
                      title: 'Home',
                      route: AppRoutes.home,
                    ),
                    const MenuItemTile(
                      icon: Icons.chat_bubble_outline,
                      title: 'Chat',
                      route: AppRoutes.chat,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'AI Features'),
                    const SizedBox(height: 8),
                    const MenuItemTile(
                      icon: Icons.psychology_outlined,
                      title: 'AI Profiles',
                      subtitle: 'Manage AI profiles',
                      route: AppRoutes.aiProfiles,
                    ),
                    const MenuItemTile(
                      icon: Icons.cloud_outlined,
                      title: 'AI Providers',
                      subtitle: 'Configure AI services',
                      route: AppRoutes.aiProviders,
                    ),
                    const MenuItemTile(
                      icon: Icons.dns_Tôi thấy vấn đề vẫn xảy ra với văn bản tiếng Việt lẫn vào code. Hãy để tôi tạo một file Python script để ghi file một cách sạch sẽ:

<write_to_file>
<path>create_menu_view.py</path>
<content>
#!/usr/bin/env python3

content = """import 'package:flutter/material.dart';
import '../../../../shared/widgets/right_drawer.dart';
import '../../../../core/config/routes.dart';
import '../widgets/menu_item_tile.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return AppSidebarRight(
      width: screenWidth,
      backgroundColor: colorScheme.surface,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header section
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Menu',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Menu items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionTitle(context, 'Main'),
                    const SizedBox(height: 8),
                    const MenuItemTile(
                      icon: Icons.home_outlined,
                      title: 'Home',
                      route: AppRoutes.home,
                    ),
                    const MenuItemTile(
                      icon: Icons.chat_bubble_outline,
                      title: 'Chat',
                      route: AppRoutes.chat,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'AI Features'),
                    const SizedBox(height: 8),
                    const MenuItemTile(
                      icon: Icons.psychology_outlined,
                      title: 'AI Profiles',
                      subtitle: 'Manage AI profiles',
                      route: AppRoutes.aiProfiles,
                    ),
                    const MenuItemTile(
                      icon: Icons.cloud_outlined,
                      title: 'AI Providers',
                      subtitle: 'Configure AI services',
                      route: AppRoutes.aiProviders,
                    ),
                    const MenuItemTile(
                      icon: Icons.dns_