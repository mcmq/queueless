import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/place.dart';
import '../../../core/services/providers.dart';
import '../../../core/widgets/common.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(userProvider).value?.uid;
    if (uid == null) return const Scaffold(body: Loading());
    final place = ref.watch(placeProvider(uid));
    return Scaffold(
      appBar: AppBar(title: const Text('Place profile')),
      body: place.when(
        loading: () => const Loading(),
        error: (e, _) => EmptyState('$e'),
        data: (p) => _ProfileForm(uid: uid, place: p),
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.uid, required this.place});
  final String uid;
  final Place? place;
  @override
  ConsumerState<_ProfileForm> createState() => _FormState();
}

class _FormState extends ConsumerState<_ProfileForm> {
  final _key = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.place?.name);
  late final _address = TextEditingController(text: widget.place?.address);
  late final _desc = TextEditingController(text: widget.place?.description);
  late final _image = TextEditingController(text: widget.place?.imageUrl);
  late final _minutes = TextEditingController(
    text: '${widget.place?.avgServiceMinutes ?? 10}',
  );
  late String _category = widget.place?.category ?? Place.categories.first;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_name, _address, _desc, _image, _minutes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(placeRepoProvider)
          .save(
            uid: widget.uid,
            name: _name.text.trim(),
            category: _category,
            address: _address.text.trim(),
            description: _desc.text.trim(),
            imageUrl: _image.text.trim().isEmpty ? null : _image.text.trim(),
            avgServiceMinutes: int.parse(_minutes.text.trim()),
          );
      if (mounted) context.go('/staff/dashboard');
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: _required,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              for (final c in Place.categories)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _address,
            decoration: const InputDecoration(labelText: 'Address'),
            validator: _required,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _desc,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _image,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Image URL (optional)',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _minutes,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Average minutes per customer',
            ),
            validator: (v) {
              final n = int.tryParse(v ?? '');
              return (n == null || n < 1 || n > 240) ? 'Enter 1-240' : null;
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
