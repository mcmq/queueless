# CLAUDE.md

Queueless: a simple Flutter + Firebase virtual queue app (portfolio project). Customers join a
queue with no login; staff sign up/log in, manage their place, and call the next customer.
**Keep it simple.** Do not add features outside `docs/product-requirements.md`.

## Docs (read before changing related code)

- [docs/product-requirements.md](docs/product-requirements.md): roles, user stories, scope
- [docs/architecture.md](docs/architecture.md): stack, folder structure, layering, routes
- [docs/data-model.md](docs/data-model.md): Firestore collections, queries, join transaction
- [docs/queue-logic.md](docs/queue-logic.md): position, ETA formula, state machine, staff actions
- [docs/firebase-setup.md](docs/firebase-setup.md): Firebase config, packages, security rules
- [docs/design-system.md](docs/design-system.md): colors, screens, components
- [docs/image.png](docs/image.png): visual design reference
- [docs/roadmap.md](docs/roadmap.md): milestones and stretch goals

## Commands

```bash
flutter pub get
flutter run
flutter analyze
flutter test
```

## Conventions

- Feature-first folders under `lib/features/`; shared code in `lib/core/`.
- Widgets never call Firebase directly; go through repositories + Riverpod providers.
- Live data uses Firestore snapshot streams; atomic changes (join, call next) use transactions.
- Customers use silent anonymous auth; staff = email/password. Role is derived from the auth
  provider, never stored.
- Place doc id = staff uid; ticket doc id = customer uid (one ticket per customer per place).
- Put queue math (position, ETA) in pure functions in `lib/core/utils/` and unit test them.
- Follow `analysis_options.yaml` lints; run `flutter analyze` and `flutter test` before finishing.
- If you change the data model or security rules, update the matching doc in the same change.
