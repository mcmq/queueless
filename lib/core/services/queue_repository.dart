import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ticket.dart';
import '../utils/queue_math.dart';

class QueueException implements Exception {
  QueueException(this.message);
  final String message;
  @override
  String toString() => message;
}

class QueueRepository {
  QueueRepository(this._db);
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _place(String id) =>
      _db.collection('places').doc(id);
  CollectionReference<Map<String, dynamic>> _tickets(String placeId) =>
      _place(placeId).collection('tickets');

  Stream<Ticket?> watchMyTicket(String placeId, String uid) => _tickets(
    placeId,
  ).doc(uid).snapshots().map((d) => d.exists ? Ticket.fromDoc(d) : null);

  /// Waiting tickets only, ordered by number (sorted client-side: no index needed).
  Stream<List<Ticket>> watchWaiting(String placeId) => _tickets(placeId)
      .where('status', isEqualTo: TicketStatus.waiting.value)
      .snapshots()
      .map(
        (s) =>
            s.docs.map(Ticket.fromDoc).toList()
              ..sort((a, b) => a.number.compareTo(b.number)),
      );

  /// Ticket currently being served (status == called), if any.
  Stream<Ticket?> watchCalled(String placeId) => _tickets(placeId)
      .where('status', isEqualTo: TicketStatus.called.value)
      .snapshots()
      .map((s) => s.docs.isEmpty ? null : Ticket.fromDoc(s.docs.first));

  /// Join or rejoin: new ticket at the back of the line.
  Future<void> join(String placeId, String uid, String name) {
    return _db.runTransaction((tx) async {
      final placeRef = _place(placeId);
      final ticketRef = _tickets(placeId).doc(uid);
      final place = await tx.get(placeRef);
      if (!place.exists || place.data()!['isOpen'] != true) {
        throw QueueException('This queue is closed.');
      }
      final mine = await tx.get(ticketRef);
      if (mine.exists && Ticket.fromDoc(mine).isActive) {
        throw QueueException('You are already in this queue.');
      }
      final next =
          ((place.data()!['lastTicketNumber'] as num?)?.toInt() ?? 0) + 1;
      tx.update(placeRef, {'lastTicketNumber': next});
      tx.set(ticketRef, {
        'customerUid': uid,
        'customerName': name.trim().isEmpty ? 'Guest' : name.trim(),
        'number': next,
        'code': ticketCode(next),
        'status': TicketStatus.waiting.value,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> cancel(String placeId, String uid) =>
      _tickets(placeId).doc(uid).update({
        'status': TicketStatus.cancelled.value,
        'closedAt': FieldValue.serverTimestamp(),
      });

  /// Promotes the lowest-number waiting ticket to called.
  Future<void> callNext(String placeId) async {
    final waiting = await _tickets(
      placeId,
    ).where('status', isEqualTo: TicketStatus.waiting.value).get();
    if (waiting.docs.isEmpty) throw QueueException('Nobody is waiting.');
    final docs = waiting.docs.toList()
      ..sort((a, b) => (a['number'] as num).compareTo(b['number'] as num));
    await _db.runTransaction((tx) async {
      final fresh = await tx.get(docs.first.reference);
      if (fresh.data()?['status'] != TicketStatus.waiting.value) {
        throw QueueException('Queue changed, try again.');
      }
      tx.update(docs.first.reference, {
        'status': TicketStatus.called.value,
        'calledAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> finish(String placeId, String uid, TicketStatus status) =>
      _tickets(placeId).doc(uid).update({
        'status': status.value,
        'closedAt': FieldValue.serverTimestamp(),
      });
}
