import 'package:flutter/material.dart';

import '../models/pin.dart';
import '../services/saved_store.dart';
import '../widgets/pin_image.dart';

/// Lets the user create their own pin from an image URL (with form validation).
class CreatePinScreen extends StatefulWidget {
  final VoidCallback onCreated;
  const CreatePinScreen({super.key, required this.onCreated});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String? _validateTitle(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter a title';
    if (v.trim().length < 3) return 'Title must be at least 3 characters';
    return null;
  }

  String? _validateUrl(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please paste an image link';
    final uri = Uri.tryParse(v.trim());
    final valid = uri != null &&
        uri.hasAuthority &&
        (uri.scheme == 'http' || uri.scheme == 'https');
    return valid ? null : 'Enter a valid link starting with http:// or https://';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final pin = Pin(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      author: 'You',
      imageUrl: _urlCtrl.text.trim(),
      aspectRatio: 0.8,
    );
    savedStore.add(pin);

    _formKey.currentState!.reset();
    _titleCtrl.clear();
    _urlCtrl.clear();
    _descCtrl.clear();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your pin was created and saved!')),
    );
    widget.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    final url = _urlCtrl.text.trim();
    final showPreview = _validateUrl(url) == null;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Pin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    textInputAction: TextInputAction.next,
                    validator: _validateTitle,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _urlCtrl,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    validator: _validateUrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Image link (URL)',
                      hintText: 'https://example.com/photo.jpg',
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (showPreview) ...[
                    Text('Preview',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    PinImage(url: url, aspectRatio: 0.8, borderRadius: 20),
                    const SizedBox(height: 16),
                  ],
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.push_pin),
                    label: const Text('Create pin'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
