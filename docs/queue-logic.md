# Queue Logic

## Ordering

Tickets are ordered by `number` ascending. Only `waiting` tickets count toward position.

## Position and "people in front"

```
peopleInFront = count(tickets where status == waiting and number < myNumber)
position      = peopleInFront + 1
```

If my status is `called`, position is 0 ("It's your turn").

## Estimated wait

```
estimatedMinutes = peopleInFront * place.avgServiceMinutes
```

If a customer is currently being served, add one `avgServiceMinutes` (optional refinement).
Display as "~N min"; show "Next!" when `peopleInFront == 0`.
Staff can tune `avgServiceMinutes` in their profile. No ML, no history-based estimate in MVP.

## Staff actions

| Action    | Effect                                                                            |
|-----------|-----------------------------------------------------------------------------------|
| Call next | Transaction: find lowest-number `waiting` ticket, set `called` + `calledAt`        |
| Served    | Set `served` + `closedAt` on the called ticket                                    |
| No-show   | Set `no_show` + `closedAt`; customer may rejoin                                   |

Call next is disabled while a ticket is still `called` (finish the current one first) and when no
one is waiting.

## Live updates

All of position, ETA and status come from Firestore snapshot streams; the UI recomputes on every
emit. No polling and no timers except for relative-time labels.

## Customer state machine

```
(none) --join--> waiting --call--> called --served--> served
                    |                 |
                 cancel            no_show
                    v                 v
                cancelled         no_show   --rejoin--> waiting (new number)
```
