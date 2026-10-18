import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/auth_service.dart';
import '../core/services/providers.dart';
import '../features/customer/home/home_screen.dart';
import '../features/customer/place_detail/place_detail_screen.dart';
import '../features/customer/ticket/ticket_screen.dart';
import '../features/staff/auth/staff_login_screen.dart';
import '../features/staff/dashboard/dashboard_screen.dart';
import '../features/staff/profile/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(userProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) {
      final user = ref.read(userProvider).value;
      final path = state.matchedLocation;
      final staff = AuthService.isStaff(user);
      if (path.startsWith('/staff') && path != '/staff/login' && !staff) {
        return '/staff/login';
      }
      if (path == '/staff/login' && staff) return '/staff/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/place/:id',
        builder: (_, s) => PlaceDetailScreen(placeId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/ticket/:id',
        builder: (_, s) => TicketScreen(placeId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/staff/login',
        builder: (_, _) => const StaffLoginScreen(),
      ),
      GoRoute(path: '/staff/profile', builder: (_, _) => const ProfileScreen()),
      GoRoute(
        path: '/staff/dashboard',
        builder: (_, _) => const DashboardScreen(),
      ),
    ],
  );
});
