import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/services/providers.dart';
import '../../../core/utils/queue_math.dart';
import '../../../core/widgets/common.dart';

class PlaceDetailScreen extends ConsumerStatefulWidget {
  const PlaceDetailScreen({super.key, required this.placeId});
  final String placeId;
  @override
  ConsumerState<PlaceDetailScreen> createState() => _State();
}

class _State extends ConsumerState<PlaceDetailScreen> {
  final _name = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _book() async {
    final uid = ref.read(userProvider).value?.uid;
    if (uid == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(queueRepoProvider).join(widget.placeId, uid, _name.text);
      if (mounted) context.go('/ticket/${widget.placeId}');
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = ref.watch(placeProvider(widget.placeId));
    final waiting =
        ref.watch(waitingProvider(widget.placeId)).value ?? const [];
    final mine = ref.watch(myTicketProvider(widget.placeId)).value;

    return Scaffold(
      appBar: AppBar(),
      body: place.when(
        loading: () => const Loading(),
        error: (e, _) => EmptyState('$e'),
        data: (p) {
          if (p == null) return const EmptyState('Place not found.');
          final wait = estimatedMinutes(waiting.length, p.avgServiceMinutes);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: PlaceImage(p.imageUrl, height: 200),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  StatusChip(open: p.isOpen),
                ],
              ),
              const SizedBox(height: 4),
              Text(p.address, style: const TextStyle(color: AppColors.muted)),
              if (p.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(p.description),
              ],
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      StatTile('${waiting.length}', 'People in\nfront of you'),
                      StatTile(formatWait(wait), 'Estimated\nwait'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (mine != null && mine.isActive)
                FilledButton(
                  onPressed: () => context.go('/ticket/${widget.placeId}'),
                  child: const Text('View my ticket'),
                )
              else ...[
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Your name (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: (!p.isOpen || _busy) ? null : _book,
                  child: Text(p.isOpen ? 'Book Queue' : 'Queue is closed'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
