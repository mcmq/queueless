import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/ticket.dart';
import '../../../core/services/providers.dart';
import '../../../core/widgets/common.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(userProvider).value?.uid;
    if (uid == null) return const Scaffold(body: Loading());
    final place = ref.watch(placeProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Place profile',
            icon: const Icon(Icons.storefront_outlined),
            onPressed: () => context.push('/staff/profile'),
          ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: place.when(
        loading: () => const Loading(),
        error: (e, _) => EmptyState('$e'),
        data: (p) {
          if (p == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Set up your place to start a queue.'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.push('/staff/profile'),
                      child: const Text('Create place profile'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _Body(placeId: uid, name: p.name, isOpen: p.isOpen);
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.placeId,
    required this.name,
    required this.isOpen,
  });
  final String placeId;
  final String name;
  final bool isOpen;

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.read(queueRepoProvider);
    final waiting = ref.watch(waitingProvider(placeId)).value ?? const [];
    final called = ref.watch(calledProvider(placeId)).value;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: SwitchListTile(
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(isOpen ? 'Queue is open' : 'Queue is closed'),
            value: isOpen,
            onChanged: (v) => _run(
              context,
              () => ref.read(placeRepoProvider).setOpen(placeId, v),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: called == null
                ? const Text(
                    'No customer is being served.',
                    style: TextStyle(color: AppColors.muted),
                  )
                : Column(
                    children: [
                      const Text(
                        'Now serving',
                        style: TextStyle(color: AppColors.muted),
                      ),
                      Text(
                        called.code,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(called.customerName),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _run(
                                context,
                                () => queue.finish(
                                  placeId,
                                  called.customerUid,
                                  TicketStatus.served,
                                ),
                              ),
                              child: const Text('Served'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                              ),
                              onPressed: () => _run(
                                context,
                                () => queue.finish(
                                  placeId,
                                  called.customerUid,
                                  TicketStatus.noShow,
                                ),
                              ),
                              child: const Text('No-show'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: (called != null || waiting.isEmpty)
              ? null
              : () => _run(context, () => queue.callNext(placeId)),
          child: const Text('Call next'),
        ),
        const SizedBox(height: 24),
        Text(
          'Waiting (${waiting.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (waiting.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Nobody is waiting.',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
        for (final t in waiting)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: ListTile(
                leading: Text(
                  t.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                title: Text(t.customerName),
              ),
            ),
          ),
      ],
    );
  }
}
