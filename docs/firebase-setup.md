# Firebase Setup

## 1. Create the project

1. Create a project in the [Firebase console](https://console.firebase.google.com).
2. **Authentication -> Sign-in method**: enable **Anonymous** and **Email/Password**.
3. **Firestore Database**: create in production mode, pick a nearby region.

## 2. Connect Flutter

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `lib/firebase_options.dart` (the repo ships a placeholder so it compiles) and the platform config files. Add the generated
`google-services.json` / `GoogleService-Info.plist` to `.gitignore` if you do not want them public
(they are not secrets, but keep the repo clean of personal project IDs if preferred).

## 3. Packages

```bash
flutter pub add firebase_core firebase_auth cloud_firestore flutter_riverpod go_router
# already in pubspec.yaml; run `flutter pub get`
```

## 4. Security rules

Paste into Firestore -> Rules (also keep a copy in `firestore.rules`):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    function signedIn() { return request.auth != null; }
    function isStaff()  { return signedIn() && request.auth.token.firebase.sign_in_provider == 'password'; }

    match /places/{placeId} {
      allow read: if true;
      allow create: if isStaff() && request.auth.uid == placeId
                    && request.resource.data.ownerUid == request.auth.uid;
      allow update: if isStaff() && request.auth.uid == placeId
                    // customers may only bump the ticket counter by exactly 1 when joining
                    || (signedIn()
                        && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['lastTicketNumber'])
                        && request.resource.data.lastTicketNumber == resource.data.lastTicketNumber + 1);
      allow delete: if false;

      match /tickets/{customerUid} {
        allow read: if signedIn();
        // join / rejoin: only my own doc, only as waiting
        allow create, update: if signedIn() && request.auth.uid == customerUid
                              && request.resource.data.status == 'waiting'
                              && get(/databases/$(db)/documents/places/$(placeId)).data.isOpen == true;
        // cancel: only my own ticket, only to cancelled
        allow update: if signedIn() && request.auth.uid == customerUid
                      && request.resource.data.status == 'cancelled';
        // staff manage tickets in their own place
        allow update: if isStaff() && request.auth.uid == placeId;
        allow delete: if false;
      }
    }
  }
}
```

Known simplification: a malicious customer could bump the counter without creating a ticket.
That is acceptable for a portfolio demo; the proper fix is a Cloud Function (see `roadmap.md`).

## 5. Seed data

Sign up as staff in the app and fill the profile form; that creates the place. Create two or
three places with different accounts so the home list looks real.
