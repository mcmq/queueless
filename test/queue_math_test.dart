import 'package:flutter_test/flutter_test.dart';
import 'package:queueless/core/utils/queue_math.dart';

void main() {
  test('ticketCode pads', () => expect(ticketCode(12), 'A012'));
  test('peopleInFront counts only lower numbers', () {
    expect(peopleInFront([3, 5, 9], 9), 2);
    expect(peopleInFront([3, 5, 9], 3), 0);
  });
  test('estimatedMinutes', () => expect(estimatedMinutes(4, 10), 40));
  test('formatWait', () {
    expect(formatWait(0), 'Next!');
    expect(formatWait(25), '~25 min');
    expect(formatWait(90), '~1h 30m');
    expect(formatWait(120), '~2h');
  });
}
