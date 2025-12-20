import 'package:flutter/material.dart';
import '../../../core/models/ai_model.dart';
import '../../../core/utils.dart';

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
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: _getModelIcon(),
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
                        _buildTag(context, _getModelTypeLabel(), Colors.purple),
                        ..._buildIOTags(context),
                        if (model.parameters != null)
                          _buildTextTag(
                            context,
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

  Widget _getModelIcon() {
    return buildBrandLogo(model.name);
  }

  Widget _getModelTypeLabel() {
    switch (model.type) {
      case ModelType.textGeneration:
        return Row(children: [Icon(Icons.text_snippet), Text('Text')]);
      case ModelType.imageGeneration:
        return Row(children: [Icon(Icons.image_search), Text('Image')]);
      case ModelType.audioGeneration:
        return Row(children: [Icon(Icons.music_video), Text('Audio')]);
      case ModelType.videoGeneration:
        return Row(children: [Icon(Icons.local_movies), Text('Video')]);
      case ModelType.embedding:
        return Row(children: [Icon(Icons.compress_rounded), Text('Embedding')]);
      case ModelType.rerank:
        return Row(children: [Icon(Icons.leaderboard), Text('Rerank')]);
    }
  }

  List<Widget> _buildIOTags(BuildContext context) {
    final List<Widget> tags = [];

    // Input tags
    if (model.input.isNotEmpty) {
      final inputList = model.input.map((e) => _getIOIcon(e)).toList();
      tags.add(
        _buildTag(
          context,
          Row(mainAxisSize: MainAxisSize.min, children: inputList),
          Colors.orange,
        ),
      );
    }

    // Output tags
    if (model.output.isNotEmpty) {
      final outputList = model.output.map((e) => _getIOIcon(e)).toList();
      tags.add(
        _buildTag(
          context,
          Row(mainAxisSize: MainAxisSize.min, children: outputList),
          Colors.green,
        ),
      );
    }

    return tags;
  }

  Icon _getIOIcon(ModelIOType type) {
    switch (type) {
      case ModelIOType.text:
        return Icon(Icons.text_fields);
      case ModelIOType.image:
        return Icon(Icons.image_outlined);
      case ModelIOType.audio:
        return Icon(Icons.music_note);
      case ModelIOType.video:
        return Icon(Icons.movie);
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

  Widget _buildTag(BuildContext context, Widget label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boxColor = isDark
        ? Color.lerp(color, Colors.white, 0.7)!
        : Color.lerp(color, Colors.black, 0.5)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: boxColor.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.4 : 0.3)),
      ),
      color: color,
      child: label,
    );
  }

  Widget _buildTextTag(BuildContext context, String label, Color color) {
    return _buildTag(context, Text(label), color);
  }
}
