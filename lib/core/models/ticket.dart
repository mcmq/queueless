import 'package:cloud_firestore/cloud_firestore.dart';

enum TicketStatus {
  waiting,
  called,
  served,
  cancelled,
  noShow;

  String get value => this == noShow ? 'no_show' : name;

  static TicketStatus parse(String? s) => TicketStatus.values.firstWhere(
    (e) => e.value == s,
    orElse: () => TicketStatus.cancelled,
  );
}

class Ticket {
  const Ticket({
    required this.customerUid,
    required this.customerName,
    required this.number,
    required this.code,
    required this.status,
  });

  final String customerUid;
  final String customerName;
  final int number;
  final String code;
  final TicketStatus status;

  bool get isActive =>
      status == TicketStatus.waiting || status == TicketStatus.called;

  factory Ticket.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Ticket(
      customerUid: doc.id,
      customerName: d['customerName'] as String? ?? 'Guest',
      number: (d['number'] as num?)?.toInt() ?? 0,
      code: d['code'] as String? ?? '',
      status: TicketStatus.parse(d['status'] as String?),
    );
  }
}
