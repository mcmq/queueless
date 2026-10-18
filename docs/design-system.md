# Design System

Reference mockup: [`image.png`](image.png) (three screens: Home, Place Detail, Booking Ticket).
Follow its look; no need to be pixel-perfect.

## Style

Clean, white cards on a light grey background, one strong blue accent, rounded corners, soft
shadows, generous spacing. Material 3 with a custom `ColorScheme`.

## Tokens

| Token          | Value                    | Use                                |
|----------------|--------------------------|------------------------------------|
| primary        | `#0A8FE8` (approx. blue) | Buttons, ticket screen background, numbers |
| primaryDark    | `#0B5FB5`                | Queue code text                    |
| surface        | `#FFFFFF`                | Cards                              |
| background     | `#F5F7FA`                | Scaffold                           |
| open / success | `#2ED47A`                | "OPEN" chip                        |
| closed         | `#E5484D`                | "CLOSED" chip                      |
| text           | `#1B2430` / muted `#8A94A6` |                                 |
| radius         | 16 (cards), 12 (buttons) |                                    |

Font: Nunito or the default Material font; one family only.

## Customer screens

1. **Home**: greeting ("Good Morning, where are you going today?"), search field, list of place
   cards (image, name, `N Queues`, est. wait, OPEN/CLOSED chip). The map in the mockup is
   **omitted** in the MVP.
2. **Place Detail**: hero image, name, address, OPEN chip, 2x2 stat grid (People in front,
   Estimated wait; trip time/distance dropped), full-width **Book Queue** button.
3. **Ticket**: blue background. White card with place info, stats row (People in front,
   Minutes to go), dashed divider, large queue code (e.g. `A012`), **Cancel queue** button.
   When called: card turns green with "It's your turn". After cancel: **Rejoin** button.

## Staff screens

4. **Login / Sign up**: email, password, toggle between the two.
5. **Profile**: form for the fields in `data-model.md`, open/closed switch.
6. **Dashboard**: current ticket card (code, name, Served / No-show buttons), big **Call next**
   button, list of waiting tickets in order with waiting counts.

## Components to build once

`PrimaryButton`, `StatTile` (big number + label), `StatusChip`, `PlaceCard`, `TicketCard`,
`EmptyState`, `LoadingView`.
