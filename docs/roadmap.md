# Roadmap

## MVP milestones

1. **Foundation**: Firebase connected, theme, router, anonymous sign-in.
2. **Staff**: sign up/login, place profile form, open/close toggle.
3. **Customer browse**: place list, search, place detail.
4. **Queue core**: join transaction, live ticket, position + ETA, cancel, rejoin.
5. **Dashboard**: live queue, call next, served / no-show.
6. **Polish**: empty/error/loading states, tests, README screenshots, seed demo places.

## Stretch goals

- Push notifications when "you're next" (FCM + Cloud Function)
- Cloud Function for join/call to replace the client-side counter rule
- Map and distance (`google_maps_flutter`, `geolocator`) as in the mockup
- Place opening hours and auto close
- Ticket history for customers, daily stats for staff
- Multiple staff per place, multiple counters
- Image upload via Firebase Storage
