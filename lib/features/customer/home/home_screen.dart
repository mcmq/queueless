import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/models/place.dart';
import '../../../core/services/providers.dart';
import '../../../core/utils/queue_math.dart';
import '../../../core/widgets/common.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomeScreen> {
  String _query = '';

  String get _greeting {
    final h = DateTime.now().hour;
    return h < 12
        ? 'Good Morning'
        : (h < 18 ? 'Good Afternoon' : 'Good Evening');
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(placesProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/staff/login'),
                  child: const Text('Staff login'),
                ),
              ),
              Text(
                '$_greeting,\nWhere are you going today?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search hospital, clinic, office...',
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (v) =>
                    setState(() => _query = v.trim().toLowerCase()),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: places.when(
                  loading: () => const Loading(),
                  error: (e, _) => EmptyState('Could not load places.\n$e'),
                  data: (all) {
                    final list = all
                        .where(
                          (p) =>
                              p.name.toLowerCase().contains(_query) ||
                              p.address.toLowerCase().contains(_query),
                        )
                        .toList();
                    if (list.isEmpty) {
                      return const EmptyState('No places found.');
                    }
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _PlaceCard(place: list[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceCard extends ConsumerWidget {
  const _PlaceCard({required this.place});
  final Place place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(waitingProvider(place.id)).value?.length ?? 0;
    return GestureDetector(
      onTap: () => context.push('/place/${place.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                PlaceImage(place.imageUrl),
                Positioned(
                  top: 10,
                  right: 10,
                  child: StatusChip(open: place.isOpen),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count in queue  ·  ${formatWait(estimatedMinutes(count, place.avgServiceMinutes))}',
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
    );
  }
}
