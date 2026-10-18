import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  const Place({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.category,
    required this.address,
    required this.description,
    required this.imageUrl,
    required this.isOpen,
    required this.avgServiceMinutes,
    required this.lastTicketNumber,
  });

  final String id;
  final String ownerUid;
  final String name;
  final String category;
  final String address;
  final String description;
  final String? imageUrl;
  final bool isOpen;
  final int avgServiceMinutes;
  final int lastTicketNumber;

  static const categories = ['clinic', 'university', 'business'];

  factory Place.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Place(
      id: doc.id,
      ownerUid: d['ownerUid'] as String? ?? doc.id,
      name: d['name'] as String? ?? '',
      category: d['category'] as String? ?? 'business',
      address: d['address'] as String? ?? '',
      description: d['description'] as String? ?? '',
      imageUrl: d['imageUrl'] as String?,
      isOpen: d['isOpen'] as bool? ?? false,
      avgServiceMinutes: (d['avgServiceMinutes'] as num?)?.toInt() ?? 10,
      lastTicketNumber: (d['lastTicketNumber'] as num?)?.toInt() ?? 0,
    );
  }
}
