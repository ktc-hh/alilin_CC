import 'package:flutter/material.dart';

import '../models/pin.dart';
import '../services/saved_store.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/pin_image.dart';
import '../widgets/state_views.dart';
import 'pin_detail_screen.dart';

/// Saved pins list. Supports DELETE via swipe or the trash button,
/// both with a confirmation dialog and an Undo option.
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  void _delete(BuildContext context, Pin pin) {
    final index = savedStore.indexOf(pin.id);
    savedStore.remove(pin.id);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: const Text('Pin deleted'),
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () => savedStore.add(pin, index: index),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Pins')),
      body: ListenableBuilder(
        listenable: savedStore,
        builder: (context, _) {
          final pins = savedStore.pins;

          if (pins.isEmpty) {
            return const EmptyView(
              icon: Icons.favorite_border,
              title: 'No saved pins yet',
              subtitle: 'Tap the heart on any pin to save it here.',
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: pins.length,
                itemBuilder: (context, i) {
                  final pin = pins[i];
                  return Dismissible(
                    key: ValueKey(pin.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) => confirmDelete(context, pin.title),
                    onDismissed: (_) => _delete(context, pin),
                    background: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.only(right: 24),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 0,
                      color: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: SizedBox(
                          width: 64,
                          height: 64,
                          child: PinImage(
                            url: pin.imageUrl,
                            borderRadius: 12,
                            semanticLabel: pin.title,
                          ),
                        ),
                        title: Text(
                          pin.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(pin.author),
                        trailing: IconButton(
                          tooltip: 'Delete pin',
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                          onPressed: () async {
                            final ok = await confirmDelete(context, pin.title);
                            if (ok && context.mounted) _delete(context, pin);
                          },
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PinDetailScreen(
                              pin: pin,
                              heroTag: 'saved_${pin.id}',
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
