// Seeds demo places into your Firebase project (plain Dart, no packages).
//
//   dart run tool/seed_demo.dart <web-api-key> <project-id>
//
// Find both in lib/firebase_options.dart (apiKey, projectId). For each demo
// place it signs up (or signs in) a staff account via the Identity Toolkit REST
// API, then writes the place doc as that staff user, so the Firestore security
// rules are respected. Demo logins: <slug>@queueless.demo / demo1234
import 'dart:convert';
import 'dart:io';

const _password = 'demo1234';

const _places = [
  {
    'slug': 'citycare',
    'name': 'CityCare Clinic',
    'category': 'clinic',
    'address': '12 Health Street',
    'description': 'Walk-in general practice. Bring your ID card.',
    'avgServiceMinutes': 12,
  },
  {
    'slug': 'uniregistrar',
    'name': 'University Registrar',
    'category': 'university',
    'address': 'Main Campus, Building B',
    'description': 'Transcripts, enrollment letters and student records.',
    'avgServiceMinutes': 8,
  },
  {
    'slug': 'quickfix',
    'name': 'QuickFix Phone Repair',
    'category': 'business',
    'address': '4 Market Square',
    'description': 'Screen and battery repairs while you wait.',
    'avgServiceMinutes': 20,
  },
];

Future<void> main(List<String> args) async {
  if (args.length != 2) {
    stderr.writeln('Usage: dart run tool/seed_demo.dart <web-api-key> <project-id>');
    exit(64);
  }
  final key = args[0], project = args[1];
  final http = HttpClient();

  Future<Map<String, dynamic>> post(String url, Map body, {String? token}) async {
    final req = await http.postUrl(Uri.parse(url));
    req.headers.contentType = ContentType.json;
    if (token != null) req.headers.set('Authorization', 'Bearer $token');
    req.write(jsonEncode(body));
    final res = await req.close();
    final text = await res.transform(utf8.decoder).join();
    final json = jsonDecode(text) as Map<String, dynamic>;
    if (res.statusCode >= 400) throw StateError(text);
    return json;
  }

  Future<Map<String, dynamic>> auth(String email) async {
    final body = {'email': email, 'password': _password, 'returnSecureToken': true};
    const base = 'https://identitytoolkit.googleapis.com/v1/accounts';
    try {
      return await post('$base:signUp?key=$key', body);
    } on StateError {
      return post('$base:signInWithPassword?key=$key', body);
    }
  }

  for (final p in _places) {
    final user = await auth('${p['slug']}@queueless.demo');
    final uid = user['localId'] as String;
    final url = 'https://firestore.googleapis.com/v1/projects/$project'
        '/databases/(default)/documents/places?documentId=$uid';
    final fields = {
      'ownerUid': {'stringValue': uid},
      'name': {'stringValue': p['name']},
      'category': {'stringValue': p['category']},
      'address': {'stringValue': p['address']},
      'description': {'stringValue': p['description']},
      'avgServiceMinutes': {'integerValue': '${p['avgServiceMinutes']}'},
      'isOpen': {'booleanValue': true},
      'lastTicketNumber': {'integerValue': '0'},
      'createdAt': {
        'timestampValue': DateTime.now().toUtc().toIso8601String()
      },
    };
    try {
      await post(url, {'fields': fields}, token: user['idToken'] as String);
      stdout.writeln('Created ${p['name']}');
    } on StateError catch (e) {
      stdout.writeln('Skipped ${p['name']} (already exists?): $e');
    }
  }
  http.close();
}
