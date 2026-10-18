import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/ticket.dart';
import '../../../core/services/providers.dart';
import '../../../core/utils/queue_math.dart';
import '../../../core/widgets/common.dart';

class TicketScreen extends ConsumerWidget {
  const TicketScreen({super.key, required this.placeId});
  final String placeId;

  Future<void> _act(BuildContext context, Future<void> Function() fn) async {
    try {
      await fn();
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeAsync = ref.watch(placeProvider(placeId));
    final ticketAsync = ref.watch(myTicketProvider(placeId));
    final place = placeAsync.value;
    final ticket = ticketAsync.value;
    final failure = placeAsync.error ?? ticketAsync.error;
    final missing =
        (placeAsync.hasValue && place == null) ||
        (ticketAsync.hasValue && ticket == null);
    final waiting = ref.watch(waitingProvider(placeId)).value ?? const [];
    final uid = ref.watch(userProvider).value?.uid;
    final repo = ref.read(queueRepoProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Your Booking Ticket'),
        leading: BackButton(onPressed: () => context.go('/')),
      ),
      body: failure != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Could not load your ticket.\n$failure',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          : missing
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No ticket found.',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                      onPressed: () => context.go('/'),
                      child: const Text('Back to places'),
                    ),
                  ],
                ),
              ),
            )
          : (place == null || ticket == null || uid == null)
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlaceImage(place.imageUrl, height: 120),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              place.address,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _TicketBody(
                  ticket: ticket,
                  ahead: peopleInFront(
                    waiting.map((t) => t.number),
                    ticket.number,
                  ),
                  avg: place.avgServiceMinutes,
                ),
                const SizedBox(height: 20),
                if (ticket.isActive)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: () =>
                        _act(context, () => repo.cancel(placeId, uid)),
                    child: const Text('Cancel queue'),
                  )
                else if (ticket.status != TicketStatus.served)
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () => _act(
                      context,
                      () => repo.join(placeId, uid, ticket.customerName),
                    ),
                    child: const Text('Rejoin queue'),
                  )
                else
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () => context.go('/'),
                    child: const Text('Back to places'),
                  ),
              ],
            ),
    );
  }
}

class _TicketBody extends StatelessWidget {
  const _TicketBody({
    required this.ticket,
    required this.ahead,
    required this.avg,
  });
  final Ticket ticket;
  final int ahead;
  final int avg;

  @override
  Widget build(BuildContext context) {
    final called = ticket.status == TicketStatus.called;
    final String? message = switch (ticket.status) {
      TicketStatus.called => "It's your turn! Please go to the counter.",
      TicketStatus.served => 'You have been served. Thank you!',
      TicketStatus.cancelled => 'You left the queue.',
      TicketStatus.noShow => 'You were marked as a no-show.',
      TicketStatus.waiting => null,
    };
    return Card(
      color: called ? AppColors.success : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (ticket.status == TicketStatus.waiting)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StatTile('$ahead', 'People\nin front'),
                  StatTile('${estimatedMinutes(ahead, avg)}', 'Minutes\nto go'),
                ],
              ),
            if (message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: called ? Colors.white : AppColors.text,
                  ),
                ),
              ),
            const Divider(height: 32),
            Text(
              'Your Queue Number',
              style: TextStyle(color: called ? Colors.white : AppColors.muted),
            ),
            Text(
              ticket.code,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                color: called ? Colors.white : AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
