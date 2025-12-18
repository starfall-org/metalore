import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AttachmentOptionsDrawer extends StatelessWidget {
  final VoidCallback onPickAttachments;
  final VoidCallback? onMicTap;

  const AttachmentOptionsDrawer({
    super.key,
    required this.onPickAttachments,
    this.onMicTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Text(
                'attachment_options.title'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            // Attachment options
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text('attachment_options.gallery'.tr()),
              subtitle: Text('attachment_options.gallery_desc'.tr()),
              onTap: () {
                Navigator.pop(context);
                onPickAttachments();
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.green),
              ),
              title: Text('attachment_options.camera'.tr()),
              subtitle: Text('attachment_options.camera_desc'.tr()),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement camera pick
                onPickAttachments();
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.insert_drive_file,
                  color: Colors.orange,
                ),
              ),
              title: Text('attachment_options.document'.tr()),
              subtitle: Text('attachment_options.document_desc'.tr()),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement document pick
                onPickAttachments();
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.audiotrack, color: Colors.purple),
              ),
              title: Text('attachment_options.audio'.tr()),
              subtitle: Text('attachment_options.audio_desc'.tr()),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement audio pick
                onPickAttachments();
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.videocam, color: Colors.teal),
              ),
              title: Text('attachment_options.video'.tr()),
              subtitle: Text('attachment_options.video_desc'.tr()),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement video pick
                onPickAttachments();
              },
            ),
            if (onMicTap != null)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.mic,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                title: Text('attachment_options.voice_record'.tr()),
                subtitle: Text('attachment_options.voice_record_desc'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  onMicTap?.call();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Static method to show the drawer as a modal bottom sheet
  static void show(
    BuildContext context, {
    required VoidCallback onPickAttachments,
    VoidCallback? onMicTap,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => AttachmentOptionsDrawer(
        onPickAttachments: onPickAttachments,
        onMicTap: onMicTap,
      ),
    );
  }
}
