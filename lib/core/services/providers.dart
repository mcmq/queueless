import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/place.dart';
import '../models/ticket.dart';
import 'auth_service.dart';
import 'place_repository.dart';
import 'queue_repository.dart';

final authServiceProvider = Provider((_) => AuthService(FirebaseAuth.instance));
final placeRepoProvider = Provider(
  (_) => PlaceRepository(FirebaseFirestore.instance),
);
final queueRepoProvider = Provider(
  (_) => QueueRepository(FirebaseFirestore.instance),
);

final userProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).changes,
);

final placesProvider = StreamProvider<List<Place>>(
  (ref) => ref.watch(placeRepoProvider).watchAll(),
);

final placeProvider = StreamProvider.family<Place?, String>(
  (ref, id) => ref.watch(placeRepoProvider).watch(id),
);

final waitingProvider = StreamProvider.family<List<Ticket>, String>(
  (ref, id) => ref.watch(queueRepoProvider).watchWaiting(id),
);

final calledProvider = StreamProvider.family<Ticket?, String>(
  (ref, id) => ref.watch(queueRepoProvider).watchCalled(id),
);

/// My ticket at a place (customer's uid is the doc id).
final myTicketProvider = StreamProvider.family<Ticket?, String>((ref, placeId) {
  final uid = ref.watch(userProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(queueRepoProvider).watchMyTicket(placeId, uid);
});
