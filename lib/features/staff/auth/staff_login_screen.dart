import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/providers.dart';
import '../../../core/widgets/common.dart';

class StaffLoginScreen extends ConsumerStatefulWidget {
  const StaffLoginScreen({super.key});
  @override
  ConsumerState<StaffLoginScreen> createState() => _State();
}

class _State extends ConsumerState<StaffLoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUp = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final auth = ref.read(authServiceProvider);
    try {
      final email = _email.text.trim();
      if (_signUp) {
        await auth.staffSignUp(email, _password.text);
      } else {
        await auth.staffLogIn(email, _password.text);
      }
      // Router redirects to the dashboard once the staff user is signed in.
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/')),
        title: const Text('Staff'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _signUp ? 'Create staff account' : 'Staff login',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'At least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(_signUp ? 'Sign up' : 'Log in'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _signUp = !_signUp),
                    child: Text(
                      _signUp
                          ? 'Have an account? Log in'
                          : 'New here? Create an account',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
