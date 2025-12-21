import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';


/// Màn hình cập nhật ứng dụng
class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isCheckingForUpdates = false;
  bool _hasUpdate = false;
  final String _currentVersion = '1.0.0';
  final String _latestVersion = '1.1.0';

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
              'update.title'.tr(),
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'update.subtitle'.tr(),
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
            ),
            onPressed: _checkForUpdates,
          ),
        ],
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
          _buildCurrentVersionCard(),
          const SizedBox(height: 24),
          _buildUpdateStatusCard(),
          const SizedBox(height: 24),
          if (_hasUpdate) _buildUpdateAvailableCard(),
          if (_hasUpdate) const SizedBox(height: 24),
          _buildUpdateHistorySection(),
        ],
      ),
    );
  }

  /// Xây dựng card phiên bản hiện tại
  Widget _buildCurrentVersionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.phone_android,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'update.current_version'.tr(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'update.current_version_desc'.tr(),
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
            _buildVersionInfo(
              'update.version_number'.tr(),
              _currentVersion,
            ),
            const SizedBox(height: 8),
            _buildVersionInfo(
              'update.build_date'.tr(),
              '2024-12-21',
            ),
            const SizedBox(height: 8),
            _buildVersionInfo(
              'update.update_channel'.tr(),
              'update.stable_channel'.tr(),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng thông tin phiên bản
  Widget _buildVersionInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  /// Xây dựng card trạng thái cập nhật
  Widget _buildUpdateStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.system_update,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'update.check_status'.tr(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _hasUpdate 
                            ? 'update.update_available'.tr()
                            : 'update.up_to_date'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _hasUpdate 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCheckingForUpdates ? null : _checkForUpdates,
                icon: _isCheckingForUpdates
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(
                  _isCheckingForUpdates 
                      ? 'update.checking'.tr()
                      : 'update.check_now'.tr(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng card có cập nhật
  Widget _buildUpdateAvailableCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.new_releases,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'update.new_version_available'.tr(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${'update.latest_version'.tr()}: $_latestVersion',
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
            _buildUpdateFeatures(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _skipUpdate(),
                    child: Text('update.skip_this_version'.tr()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _downloadUpdate(),
                    child: Text('update.download_update'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng danh sách tính năng cập nhật
  Widget _buildUpdateFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'update.whats_new'.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...[
          'update.feature_1'.tr(),
          'update.feature_2'.tr(),
          'update.feature_3'.tr(),
        ].map((feature) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(feature)),
            ],
          ),
        )),
      ],
    );
  }

  /// Xây dựng phần lịch sử cập nhật
  Widget _buildUpdateHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'update.update_history'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildHistoryItem(
                version: '1.0.0',
                date: '2024-12-21',
                features: [
                  'update.history_1_feature_1'.tr(),
                  'update.history_1_feature_2'.tr(),
                ],
              ),
              const Divider(height: 1),
              _buildHistoryItem(
                version: '0.9.0',
                date: '2024-12-01',
                features: [
                  'update.history_2_feature_1'.tr(),
                  'update.history_2_feature_2'.tr(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Xây dựng item lịch sử
  Widget _buildHistoryItem({
    required String version,
    required String date,
    required List<String> features,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'v$version',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 4,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(feature)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  /// Kiểm tra cập nhật
  Future<void> _checkForUpdates() async {
    setState(() {
      _isCheckingForUpdates = true;
    });

    // Simulate checking for updates
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isCheckingForUpdates = false;
      _hasUpdate = true; // Simulate finding an update
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('update.update_check_completed'.tr())),
      );
    }
  }

  /// Bỏ qua cập nhật
  void _skipUpdate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('update.update_skipped'.tr())),
    );
  }

  /// Tải xuống cập nhật
  void _downloadUpdate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('update.download_started'.tr())),
    );
  }
}