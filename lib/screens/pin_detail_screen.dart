import 'package:flutter/material.dart';

import '../models/pin.dart';
import '../services/saved_store.dart';
import '../widgets/pin_image.dart';

/// Full view of a single pin with a Save / Unsave button.
class PinDetailScreen extends StatelessWidget {
  final Pin pin;
  final String heroTag;

  const PinDetailScreen({super.key, required this.pin, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pin'),
        titleTextStyle: theme.appBarTheme.titleTextStyle
            ?.copyWith(color: Colors.black87, fontSize: 18),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: heroTag,
                  child: PinImage(
                    url: pin.imageUrl,
                    aspectRatio: pin.aspectRatio,
                    borderRadius: 24,
                    semanticLabel: pin.title,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  pin.title,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      child: Icon(Icons.person, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(pin.author, style: theme.textTheme.bodyMedium),
                  ],
                ),
                if (pin.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(pin.description, style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: 24),
                ListenableBuilder(
                  listenable: savedStore,
                  builder: (context, _) {
                    final saved = savedStore.isSaved(pin.id);
                    return FilledButton.icon(
                      style: saved
                          ? FilledButton.styleFrom(
                              backgroundColor: Colors.grey.shade800,
                            )
                          : null,
                      onPressed: () => toggleSaved(context, pin),
                      icon: Icon(
                        saved ? Icons.favorite : Icons.favorite_border,
                      ),
                      label: Text(saved ? 'Saved' : 'Save'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
