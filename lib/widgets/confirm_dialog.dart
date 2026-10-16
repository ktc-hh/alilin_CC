import 'package:flutter/material.dart';

/// Asks the user to confirm a delete (HCI: user control + error prevention).
/// Returns true if the user confirmed.
Future<bool> confirmDelete(BuildContext context, String pinTitle) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete this pin?'),
      content: Text('"$pinTitle" will be removed from your saved pins.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(100, 44),
            backgroundColor: Colors.red,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result ?? false;
}
