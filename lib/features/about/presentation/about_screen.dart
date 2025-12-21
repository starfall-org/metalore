import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';


/// Màn hình thông tin về ứng dụng
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
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
              'about.title'.tr(),
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'about.subtitle'.tr(),
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
          _buildAppInfoCard(),
          const SizedBox(height: 24),
          _buildFeaturesSection(),
          const SizedBox(height: 24),
          _buildDevelopersSection(),
          const SizedBox(height: 24),
          _buildLegalSection(),
          const SizedBox(height: 24),
          _buildSupportSection(),
        ],
      ),
    );
  }

  /// Xây dựng card thông tin ứng dụng
  Widget _buildAppInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // App Icon và tên
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.smart_toy,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'app_title'.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'about.app_description'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'about.version'.tr(),
              '1.0.0 (1)',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'about.build_date'.tr(),
              _getBuildDate(),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng hàng thông tin
  Widget _buildInfoRow(String label, String value) {
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

  /// Xây dựng phần tính năng
  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'about.features.title'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildFeatureItem(
                icon: Icons.chat_bubble_outline,
                title: 'about.features.chat'.tr(),
                description: 'about.features.chat_desc'.tr(),
              ),
              const Divider(height: 1),
              _buildFeatureItem(
                icon: Icons.person_outline,
                title: 'about.features.ai_profiles'.tr(),
                description: 'about.features.ai_profiles_desc'.tr(),
              ),
              const Divider(height: 1),
              _buildFeatureItem(
                icon: Icons.cloud_outlined,
                title: 'about.features.providers'.tr(),
                description: 'about.features.providers_desc'.tr(),
              ),
              const Divider(height: 1),
              _buildFeatureItem(
                icon: Icons.extension_outlined,
                title: 'about.features.mcp'.tr(),
                description: 'about.features.mcp_desc'.tr(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Xây dựng item tính năng
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(description),
    );
  }

  /// Xây dựng phần nhà phát triển
  Widget _buildDevelopersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'about.developers.title'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDeveloperItem(
                  name: 'Starfall Team',
                  role: 'about.developers.team_role'.tr(),
                  description: 'about.developers.team_desc'.tr(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Xây dựng item nhà phát triển
  Widget _buildDeveloperItem({
    required String name,
    required String role,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                name[0],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    role,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  /// Xây dựng phần pháp lý
  Widget _buildLegalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'about.legal.title'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildControlTile(
                icon: Icons.description,
                title: 'about.legal.privacy_policy'.tr(),
                subtitle: 'about.legal.privacy_policy_desc'.tr(),
                onTap: () => _openPrivacyPolicy(),
              ),
              const Divider(height: 1),
              _buildControlTile(
                icon: Icons.rule,
                title: 'about.legal.terms_of_service'.tr(),
                subtitle: 'about.legal.terms_of_service_desc'.tr(),
                onTap: () => _openTermsOfService(),
              ),
              const Divider(height: 1),
              _buildControlTile(
                icon: Icons.info_outline,
                title: 'about.legal.open_source'.tr(),
                subtitle: 'about.legal.open_source_desc'.tr(),
                onTap: () => _openOpenSource(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Xây dựng phần hỗ trợ
  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'about.support.title'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildControlTile(
                icon: Icons.bug_report,
                title: 'about.support.report_bug'.tr(),
                subtitle: 'about.support.report_bug_desc'.tr(),
                onTap: () => _reportBug(),
              ),
              const Divider(height: 1),
              _buildControlTile(
                icon: Icons.lightbulb_outline,
                title: 'about.support.feature_request'.tr(),
                subtitle: 'about.support.feature_request_desc'.tr(),
                onTap: () => _requestFeature(),
              ),
              const Divider(height: 1),
              _buildControlTile(
                icon: Icons.help_outline,
                title: 'about.support.help_center'.tr(),
                subtitle: 'about.support.help_center_desc'.tr(),
                onTap: () => _openHelpCenter(),
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
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  /// Lấy ngày build (placeholder)
  String _getBuildDate() {
    return '2024-12-21';
  }

  /// Handlers cho các hành động
  void _openPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('about.actions.privacy_policy_opened'.tr())),
    );
  }

  void _openTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('about.actions.terms_opened'.tr())),
    );
  }

  void _openOpenSource() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('about.actions.open_source_opened'.tr())),
    );
  }

  void _reportBug() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('about.actions.bug_report_opened'.tr())),
    );
  }

  void _requestFeature() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('about.actions.feature_request_opened'.tr())),
    );
  }

  void _openHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('about.actions.help_center_opened'.tr())),
    );
  }
}