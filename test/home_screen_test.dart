import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queueless/core/models/place.dart';
import 'package:queueless/core/models/ticket.dart';
import 'package:queueless/core/services/providers.dart';
import 'package:queueless/features/customer/home/home_screen.dart';

Place _place(String id, String name, {bool open = true}) => Place(
  id: id,
  ownerUid: id,
  name: name,
  category: 'clinic',
  address: '1 Main St',
  description: '',
  imageUrl: null,
  isOpen: open,
  avgServiceMinutes: 10,
  lastTicketNumber: 0,
);

Widget _app(Stream<List<Place>> places) => ProviderScope(
  retry: (_, _) => null,
  overrides: [
    placesProvider.overrideWith((ref) => places),
    waitingProvider.overrideWith((ref, id) => Stream.value(<Ticket>[])),
  ],
  child: const MaterialApp(home: HomeScreen()),
);

void main() {
  testWidgets('lists places with status chips', (tester) async {
    await tester.pumpWidget(
      _app(
        Stream.value([
          _place('a', 'Alpha Clinic'),
          _place('b', 'Beta Office', open: false),
        ]),
      ),
    );
    await tester.pump();
    expect(find.text('Alpha Clinic'), findsOneWidget);
    expect(find.text('OPEN'), findsOneWidget);
    expect(find.text('CLOSED'), findsOneWidget);
  });

  testWidgets('search filters and shows empty state', (tester) async {
    await tester.pumpWidget(_app(Stream.value([_place('a', 'Alpha Clinic')])));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('No places found.'), findsOneWidget);
    expect(find.text('Alpha Clinic'), findsNothing);
  });

  testWidgets('shows loading then error state', (tester) async {
    final controller = StreamController<List<Place>>();
    addTearDown(controller.close);
    await tester.pumpWidget(_app(controller.stream));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    controller.addError('boom');
    await tester.pump(const Duration(milliseconds: 10));
    expect(find.textContaining('Could not load places'), findsOneWidget);
  });
}
