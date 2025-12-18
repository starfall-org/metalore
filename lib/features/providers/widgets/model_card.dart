import 'package:flutter/material.dart';
import '../../../core/models/ai_model.dart';

class ModelCard extends StatelessWidget {
  final AIModel model;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ModelCard({super.key, required this.model, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Icon(_getModelIcon(), color: Colors.blue[600], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _buildTag(_getModelTypeLabel(), Colors.purple),
                        ..._buildIOTags(),
                        if (model.parameters != null)
                          _buildTag(
                            _formatParameters(model.parameters!),
                            Colors.orange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }

  IconData _getModelIcon() {
    switch (model.type) {
      case ModelType.textGeneration:
        return Icons.smart_toy;
      case ModelType.imageGeneration:
        return Icons.image;
      case ModelType.audioGeneration:
        return Icons.audiotrack;
      case ModelType.videoGeneration:
        return Icons.video_library;
      case ModelType.embedding:
        return Icons.hub;
      case ModelType.rerank:
        return Icons.sort;
    }
  }

  String _getModelTypeLabel() {
    switch (model.type) {
      case ModelType.textGeneration:
        return 'Text';
      case ModelType.imageGeneration:
        return 'Image';
      case ModelType.audioGeneration:
        return 'Audio';
      case ModelType.videoGeneration:
        return 'Video';
      case ModelType.embedding:
        return 'Embed';
      case ModelType.rerank:
        return 'Rerank';
    }
  }

  List<Widget> _buildIOTags() {
    final List<Widget> tags = [];

    // Input tags
    if (model.input.isNotEmpty) {
      final inputStr = model.input.map((e) => _getIOIcon(e)).join('');
      tags.add(_buildTag('In: $inputStr', Colors.blue));
    }

    // Output tags
    if (model.output.isNotEmpty) {
      final outputStr = model.output.map((e) => _getIOIcon(e)).join('');
      tags.add(_buildTag('Out: $outputStr', Colors.green));
    }

    return tags;
  }

  String _getIOIcon(ModelIOType type) {
    switch (type) {
      case ModelIOType.text:
        return '📝';
      case ModelIOType.image:
        return '🖼️';
      case ModelIOType.audio:
        return '🔊';
      case ModelIOType.video:
        return '🎬';
      case ModelIOType.document:
        return '📄';
    }
  }

  String _formatParameters(int params) {
    if (params >= 1000000000) {
      return '${(params / 1000000000).toStringAsFixed(0)}B';
    } else if (params >= 1000000) {
      return '${(params / 1000000).toStringAsFixed(0)}M';
    } else if (params >= 1000) {
      return '${(params / 1000).toStringAsFixed(0)}K';
    }
    return params.toString();
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Color.lerp(color, Colors.black, 0.3)!,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
