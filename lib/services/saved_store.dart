import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pin.dart';

/// Holds the user's saved pins and persists them on the device.
/// Extends ChangeNotifier so any screen can rebuild when it changes.
class SavedStore extends ChangeNotifier {
  static const _key = 'saved_pins';
  final List<Pin> _pins = [];

  List<Pin> get pins => List.unmodifiable(_pins);
  bool isSaved(String id) => _pins.any((p) => p.id == id);
  int indexOf(String id) => _pins.indexWhere((p) => p.id == id);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _pins
        ..clear()
        ..addAll(list.map((e) => Pin.fromJson(e as Map<String, dynamic>)));
    } catch (_) {
      _pins.clear();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_pins.map((p) => p.toJson()).toList()),
    );
  }

  void add(Pin pin, {int? index}) {
    if (isSaved(pin.id)) return;
    if (index != null && index >= 0 && index <= _pins.length) {
      _pins.insert(index, pin);
    } else {
      _pins.insert(0, pin);
    }
    notifyListeners();
    _persist();
  }

  /// DELETE functionality.
  void remove(String id) {
    _pins.removeWhere((p) => p.id == id);
    notifyListeners();
    _persist();
  }
}

/// One shared instance for the whole app.
final SavedStore savedStore = SavedStore();

/// Saves/unsaves a pin and shows feedback (SnackBar with Undo).
void toggleSaved(BuildContext context, Pin pin) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();

  if (savedStore.isSaved(pin.id)) {
    final index = savedStore.indexOf(pin.id);
    savedStore.remove(pin.id);
    messenger.showSnackBar(SnackBar(
      content: const Text('Removed from Saved'),
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () => savedStore.add(pin, index: index),
      ),
    ));
  } else {
    savedStore.add(pin);
    messenger.showSnackBar(SnackBar(
      content: const Text('Saved to your Pinly collection'),
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () => savedStore.remove(pin.id),
      ),
    ));
  }
}
