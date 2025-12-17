import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'attachment_options_drawer.dart';
import 'menu_drawer.dart';

class ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  // Bổ sung: danh sách file đính kèm (đường dẫn), và callback thao tác
  final List<String> attachments;
  final VoidCallback onPickAttachments;
  final void Function(int index) onRemoveAttachment;
  // Nút mở drawer chọn model
  final VoidCallback onOpenModelPicker;

  // Trạng thái sinh câu trả lời để disable input/nút gửi
  final bool isGenerating;

  // Tuỳ chọn: hành động cho nút mic (ví dụ TTS)
  final VoidCallback? onMicTap;
  // Nút mở drawer menu
  final VoidCallback? onOpenMenu;

  const ChatInputArea({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.attachments = const [],
    required this.onPickAttachments,
    required this.onRemoveAttachment,
    required this.onOpenModelPicker,
    this.isGenerating = false,
    this.onMicTap,
    this.onOpenMenu,
  });

  Widget _buildAttachmentChips(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: -8,
        children: List.generate(attachments.length, (i) {
          final name = attachments[i].split('/').last;
          return Chip(
            label: Text(name, overflow: TextOverflow.ellipsis),
            onDeleted: () => onRemoveAttachment(i),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSend =
        !isGenerating &&
        ((controller.text.trim().isNotEmpty) || attachments.isNotEmpty);

    return GestureDetector(
      onTap: () {
        // Unfocus the TextField when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAttachmentChips(context),
              // Input row
              TextField(
                enabled: !isGenerating,
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'input.ask'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) {
                  if (canSend) onSubmitted(controller.text);
                },
              ),
              const SizedBox(height: 8),
              // Buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side buttons
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {
                          AttachmentOptionsDrawer.show(
                            context,
                            onPickAttachments: onPickAttachments,
                            onMicTap: onMicTap,
                          );
                        },
                        tooltip: 'input.attach_files'.tr(),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {
                          MenuDrawer.show(context);
                        },
                        tooltip: 'input.menu'.tr(),
                      ),
                    ],
                  ),
                  // Right side buttons
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.smart_toy_outlined,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: onOpenModelPicker,
                        tooltip: 'model_picker.title'.tr(),
                      ),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: canSend
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                              : Theme.of(context).colorScheme.surface.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.send,
                            color: canSend
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).iconTheme.color?.withOpacity(0.5),
                            size: 20,
                          ),
                          onPressed: canSend
                              ? () => onSubmitted(controller.text)
                              : null,
                          tooltip: 'input.send'.tr(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
