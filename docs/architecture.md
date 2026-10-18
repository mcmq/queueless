# Architecture

## Stack

- Flutter (Dart 3.9+), Material 3
- Firebase Auth (anonymous for customers, email/password for staff)
- Cloud Firestore (real-time data)
- `flutter_riverpod` for state, `go_router` for navigation
- No backend code and no Cloud Functions (keeps it on the free Spark plan)

## Folder structure (feature-first)

```
lib/
  main.dart                  # Firebase init, ProviderScope, MaterialApp.router
  app/
    router.dart              # go_router config + role-based redirects
    theme.dart               # colors/typography from design-system.md
  core/
    models/                  # Place, Ticket (plain Dart classes, fromMap/toMap)
    services/                # AuthService, PlaceRepository, QueueRepository
    utils/                   # eta calculation, formatters
    widgets/                 # shared UI (PrimaryButton, StatTile, StatusChip)
  features/
    customer/
      home/                  # place list + search
      place_detail/          # place info + Book Queue
      ticket/                # live ticket, cancel, rejoin
    staff/
      auth/                  # login + sign up
      profile/               # place profile form
      dashboard/             # live queue, call next, served/no-show
```

## Layering

`UI (widgets)` -> `Riverpod providers` -> `Repositories` -> `Firestore/Auth SDKs`.
Widgets never call Firebase directly. Repositories expose `Stream`s for live data and
`Future`s for actions. Queue-mutating actions that need atomicity use Firestore transactions.

## Auth and routing

- On app start, if no user is signed in, sign in anonymously (customers never see this).
- Staff are users with a non-anonymous provider. `router.dart` redirects `/staff/**` to
  `/staff/login` unless `user.isAnonymous == false`.
- Role is derived, not stored: staff = signed in with email; customer = anonymous.

## Routes

| Path                  | Screen          | Role     |
|-----------------------|-----------------|----------|
| `/`                   | Home            | customer |
| `/place/:placeId`     | Place detail    | customer |
| `/ticket/:placeId`    | Ticket          | customer |
| `/staff/login`        | Login / sign up | staff    |
| `/staff/profile`      | Place profile   | staff    |
| `/staff/dashboard`    | Dashboard       | staff    |

An entry point to staff (e.g. a small "Staff login" link on Home) switches between the two flows.

## Testing approach

Unit tests for pure logic (`test/queue_math_test.dart`). `fake_cloud_firestore` is not used (incompatible with current `cloud_firestore`). Keep it light.
