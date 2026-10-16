import 'package:flutter/material.dart';

import '../models/pin.dart';
import '../services/saved_store.dart';
import 'pin_image.dart';

/// Reusable card shown in the masonry feed.
class PinCard extends StatelessWidget {
  final Pin pin;
  final String heroTag;
  final VoidCallback onTap;

  const PinCard({
    super.key,
    required this.pin,
    required this.heroTag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Stack(
            children: [
              Hero(
                tag: heroTag,
                child: PinImage(
                  url: pin.imageUrl,
                  aspectRatio: pin.aspectRatio,
                  semanticLabel: pin.title,
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: ListenableBuilder(
                  listenable: savedStore,
                  builder: (context, _) {
                    final saved = savedStore.isSaved(pin.id);
                    return IconButton(
                      tooltip: saved ? 'Remove from saved' : 'Save pin',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      icon: Icon(
                        saved ? Icons.favorite : Icons.favorite_border,
                        color: saved ? Colors.red : Colors.black87,
                      ),
                      onPressed: () => toggleSaved(context, pin),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
          child: Text(
            pin.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
