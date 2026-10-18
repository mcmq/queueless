# Product Requirements

Queueless is a virtual queue app: people join a line from their phone instead of standing in it.
Target places: clinics, university offices, small businesses. This is a portfolio project, so the
scope is deliberately small and finished rather than broad and half-done.

## Roles

| Role     | Auth                                   | Can do                                                                 |
|----------|----------------------------------------|------------------------------------------------------------------------|
| Customer | None visible (silent anonymous auth)   | Browse places, join / cancel / rejoin a queue, watch live position + ETA |
| Staff    | Email + password (sign up / log in)    | Manage their place profile, open/close the queue, call next customer   |

A staff account owns exactly one place (MVP).

## Customer stories

- C1. Browse/search the list of places, each showing open/closed, people waiting, estimated wait.
- C2. Open a place and see people in front of me, estimated wait, and a **Book Queue** button.
- C3. Join the queue (optionally entering a display name) and get a ticket with a number like `A012`.
- C4. See my live position and estimated wait on the ticket; they update without refreshing.
- C5. Be clearly notified in-app when my ticket is **called**.
- C6. Cancel my ticket at any time while waiting.
- C7. Rejoin after cancelling (or after being missed) and get a new ticket at the back of the line.
- C8. Only one active ticket per place at a time.

## Staff stories

- S1. Sign up / log in / log out.
- S2. Create and edit my place profile: name, category, address, description, image URL,
  average service time (minutes).
- S3. Open or close the queue (closed places reject new joins).
- S4. See the live list of waiting customers in order.
- S5. **Call next**: promotes the first waiting ticket to `called`.
- S6. Mark the called customer as **served** or **no-show**.

## Rules

- Queue is first-come first-served by ticket number. No priorities.
- A called ticket is still "active" until served / no-show / cancelled.
- Estimated wait = `position_ahead * avgServiceMinutes` (see `queue-logic.md`).

## Out of scope (MVP)

Push notifications, maps and distance, multi-staff per place, multiple counters, analytics,
payments, ticket history, localization. Listed in `roadmap.md` as stretch goals.

## Screens

See `design-system.md`. Customer: Home, Place Detail, Ticket. Staff: Login/Sign up, Profile form,
Dashboard.
