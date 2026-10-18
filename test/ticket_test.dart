import 'package:flutter_test/flutter_test.dart';
import 'package:queueless/core/models/ticket.dart';

void main() {
  test('status values round-trip', () {
    for (final s in TicketStatus.values) {
      expect(TicketStatus.parse(s.value), s);
    }
    expect(TicketStatus.noShow.value, 'no_show');
  });

  test('unknown status falls back to cancelled', () {
    expect(TicketStatus.parse('???'), TicketStatus.cancelled);
    expect(TicketStatus.parse(null), TicketStatus.cancelled);
  });
}
