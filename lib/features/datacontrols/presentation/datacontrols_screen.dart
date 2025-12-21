import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';


/// Màn hình điều khiển dữ liệu cho phép quản lý và kiểm soát dữ liệu ứng dụng
class DataControlsScreen extends StatefulWidget {
  const DataControlsScreen({super.key});

  @override
  State<DataControlsScreen> createState() => _DataControlsScreenState();
}

class _DataControlsScreenState extends State<DataControlsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'datacontrols.title'.tr(),
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'datacontrols.subtitle'.tr(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.5,
      ),
      body: _buildBody(),
    );
  }

  /// Xây dựng nội dung chính của màn hình
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataOverviewCard(),
          const SizedBox(height: 24),
          _buildDataManagementSection(),
          const SizedBox(height: 24),
          _buildPrivacyControlsSection(),
          const SizedBox(height: 24),
          _buildStorageControlsSection(),
        ],
      ),
    );
  }

  /// Xây dựng card tổng quan dữ liệu
  Widget _buildDataOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'datacontrols.overview.title'.tr(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'datacontrols.overview.subtitle'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDataStats(),
          ],
        ),
      ),
    );
  }

  /// Xây dựng thống kê dữ liệu
  Widget _buildDataStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          icon: Icons.chat_bubble,
          label: 'datacontrols.stats.conversations'.tr(),
          value: '0',
        ),
        _buildStatItem(
          icon: Icons.person,
          label: 'datacontrols.stats.profiles'.tr(),
          value: '0',
        ),
        _buildStatItem(
          icon: Icons.cloud,
          label: 'datacontrols.stats.providers'.tr(),
          value: '0',
        ),
      ],
    );
  }

  /// Xây dựng item thống kê
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Xây dựng phần quản lý dữ liệu
  Widget _buildDataManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'datacontrols.management.title'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildControlTile(
                icon: Icons.backup,
                title: 'datacontrols.management.backup'.tr(),
                subtitle: 'datacontrols.management.backup_desc'.tr(),
                onTap: () => _handleBackup(),
              ),
              const Divider(height: 1),
              _buildControlTile(
                icon: Icons.restore,
                title: 'datacontrols.management.restore'.tr(),
                subtitle: 'datacontrols.management.restore_desc'.tr(),
                onTap: () => _handleRestore(),
              ),
              const Divider(height: 1),
              _buildControlTile(
                icon: Icons.import_export,
                title: 'datacontrols.management.export'.tr(),
                subtitle: 'datacontrols.management.export_desc'.tr(),
                onTap: () => _handleExport(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Xây dựng phần điều khiển quyền riêng tư
  Widget _buildPrivacyControlsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'datacontrols.privacy.title'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildControlTile(
                icon: Icons.visibility_off,
                title: 'datacontrols.privacy.anonymize'.tr(),
                subtitle: 'datacontrols.privacy.anonymize_desc'.tr(),
                onTap: () => _handleAnonymize(),
              ),
              const Divider(height: 1),
              _buildControlTile(
                icon: Icons.delete_forever,
                title: 'datacontrols.privacy.delete_all'.tr(),
                subtitle: 'datacontrols.privacy.delete_all_desc'.tr(),
                onTap: () => _handleDeleteAll(),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Xây dựng phần điều khiển lưu trữ
  Widget _buildStorageControlsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'datacontrols.storage.title'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildControlTile(
                icon: Icons.cleaning_services,
                title: 'datacontrols.storage.clean_cache'.tr(),
                subtitle: 'datacontrols.storage.clean_cache_desc'.tr(),
                onTap: () => _handleCleanCache(),
              ),
              const Divider(height: 1),
              _buildControlTile(
                icon: Icons.folder_open,
                title: 'datacontrols.storage.manage_files'.tr(),
                subtitle: 'datacontrols.storage.manage_files_desc'.tr(),
                onTap: () => _handleManageFiles(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Xây dựng tile điều khiển
  Widget _buildControlTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive 
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive 
              ? Theme.of(context).colorScheme.error
              : null,
        ),
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  /// Handlers cho các hành động
  void _handleBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('datacontrols.actions.backup_started'.tr())),
    );
  }

  void _handleRestore() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('datacontrols.actions.restore_started'.tr())),
    );
  }

  void _handleExport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('datacontrols.actions.export_started'.tr())),
    );
  }

  void _handleAnonymize() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('datacontrols.actions.anonymize_started'.tr())),
    );
  }

  void _handleDeleteAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('datacontrols.delete_all_confirm.title'.tr()),
        content: Text('datacontrols.delete_all_confirm.message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('datacontrols.actions.delete_all_completed'.tr())),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );
  }

  void _handleCleanCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('datacontrols.actions.cache_cleaned'.tr())),
    );
  }

  void _handleManageFiles() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('datacontrols.actions.manage_files_opened'.tr())),
    );
  }
}