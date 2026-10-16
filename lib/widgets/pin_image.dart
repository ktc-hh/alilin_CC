import 'package:flutter/material.dart';

/// Reusable network image with loading + error placeholders and rounded corners.
class PinImage extends StatelessWidget {
  final String url;
  final double? aspectRatio;
  final double borderRadius;
  final String? semanticLabel;

  const PinImage({
    super.key,
    required this.url,
    this.aspectRatio,
    this.borderRadius = 16,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      url,
      fit: BoxFit.cover,
      semanticLabel: semanticLabel,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stack) => Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: aspectRatio == null
          ? image
          : AspectRatio(aspectRatio: aspectRatio!, child: image),
    );
  }
}
