import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/place.dart';

class PlaceRepository {
  PlaceRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _places =>
      _db.collection('places');

  Stream<List<Place>> watchAll() => _places.snapshots().map((s) {
    final list = s.docs.map(Place.fromDoc).toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  });

  Stream<Place?> watch(String placeId) => _places
      .doc(placeId)
      .snapshots()
      .map((d) => d.exists ? Place.fromDoc(d) : null);

  /// Creates or updates the staff member's place (place id = staff uid).
  Future<void> save({
    required String uid,
    required String name,
    required String category,
    required String address,
    required String description,
    required String? imageUrl,
    required int avgServiceMinutes,
  }) async {
    final ref = _places.doc(uid);
    final exists = (await ref.get()).exists;
    final data = {
      'name': name,
      'category': category,
      'address': address,
      'description': description,
      'imageUrl': imageUrl,
      'avgServiceMinutes': avgServiceMinutes,
    };
    if (exists) {
      await ref.update(data);
    } else {
      await ref.set({
        ...data,
        'ownerUid': uid,
        'isOpen': false,
        'lastTicketNumber': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> setOpen(String placeId, bool open) =>
      _places.doc(placeId).update({'isOpen': open});
}
