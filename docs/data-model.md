# Data Model (Firestore)

## `places/{placeId}`

| Field              | Type      | Notes                                          |
|--------------------|-----------|------------------------------------------------|
| `ownerUid`         | string    | Staff user who owns the place                  |
| `name`             | string    |                                                |
| `category`         | string    | `clinic` \| `university` \| `business`         |
| `address`          | string    |                                                |
| `description`      | string    |                                                |
| `imageUrl`         | string?   | Plain URL (no Firebase Storage in MVP)         |
| `isOpen`           | bool      | Closed places reject joins                     |
| `avgServiceMinutes`| int       | Used for ETA, default 10                       |
| `lastTicketNumber` | int       | Monotonic counter, incremented on join         |
| `createdAt`        | timestamp |                                                |

`placeId` = staff user's uid (one place per staff, simple rules and lookups).

## `places/{placeId}/tickets/{customerUid}`

Doc id is the customer's anonymous uid, which enforces **one ticket per customer per place**.
Rejoining overwrites the doc with a fresh ticket.

| Field          | Type       | Notes                                                       |
|----------------|------------|-------------------------------------------------------------|
| `customerUid`  | string     | Same as doc id                                              |
| `customerName` | string     | Optional display name, default "Guest"                      |
| `number`       | int        | From `lastTicketNumber`; defines order                      |
| `code`         | string     | Display code, e.g. `A012` (`A` + zero-padded number)        |
| `status`       | string     | `waiting` \| `called` \| `served` \| `cancelled` \| `no_show` |
| `joinedAt`     | timestamp  |                                                             |
| `calledAt`     | timestamp? |                                                             |
| `closedAt`     | timestamp? | Set on served / cancelled / no_show                         |

Active = `waiting` or `called`.

## Queries

| Need                           | Query                                                                 |
|--------------------------------|-----------------------------------------------------------------------|
| Place list                     | `places` ordered by `name`                                            |
| Waiting count for a place card | `places/{id}/tickets` where `status == waiting` (count)               |
| Staff live queue               | `tickets` where `status == waiting` (sorted by `number` client-side) + `status == called`       |
| My ticket                      | doc `places/{id}/tickets/{myUid}` snapshot                            |
| Position                       | count of `waiting` tickets with `number < mine` (+1)                  |

Queries filter on a single `status` value and sort by `number` client-side, so no composite index is needed.

## Join transaction

1. Read place; abort if `isOpen == false`.
2. Read my ticket doc; abort if it is `waiting` or `called`.
3. `lastTicketNumber += 1` on the place.
4. Write ticket with that number, `status: waiting`.

Cancel = update my ticket to `cancelled` + `closedAt`. Rejoin = run the join transaction again.
