/// Display code for a ticket number, e.g. 12 -> "A012".
String ticketCode(int number) => 'A${number.toString().padLeft(3, '0')}';

/// Number of waiting tickets ahead of [myNumber].
int peopleInFront(Iterable<int> waitingNumbers, int myNumber) =>
    waitingNumbers.where((n) => n < myNumber).length;

/// Estimated minutes until my turn.
int estimatedMinutes(int peopleAhead, int avgServiceMinutes) =>
    peopleAhead * avgServiceMinutes;

String formatWait(int minutes) {
  if (minutes <= 0) return 'Next!';
  if (minutes < 60) return '~$minutes min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '~${h}h' : '~${h}h ${m}m';
}
