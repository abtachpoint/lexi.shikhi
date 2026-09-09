import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/auth_service.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool createAccount = false;
  bool obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = AuthService.instance;
    try {
      if (createAccount) {
        await auth.createEmailAccount(
          email: _email.text,
          password: _password.text,
        );
      } else {
        await auth.signInWithEmail(
          email: _email.text,
          password: _password.text,
        );
      }
      if (mounted && auth.isSignedIn) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.lastError ?? widget.appState.t('Sign in ব্যর্থ হয়েছে।', 'Sign-in failed.'))),
      );
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.appState.t('আগে valid email লিখুন।', 'Enter a valid email first.'))),
      );
      return;
    }
    final ok = await AuthService.instance.sendPasswordReset(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? widget.appState.t('Password reset email পাঠানো হয়েছে।', 'Password reset email sent.')
              : (AuthService.instance.lastError ?? widget.appState.t('Reset email পাঠানো যায়নি।', 'Could not send reset email.')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final auth = AuthService.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          createAccount
              ? state.t('Email account তৈরি করুন', 'Create Email Account')
              : state.t('Email দিয়ে Sign in', 'Sign in with Email'),
        ),
      ),
      body: AnimatedBuilder(
        animation: auth,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            Icon(
              createAccount ? Icons.person_add_alt_1_rounded : Icons.email_rounded,
              size: 62,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 22),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: state.t('Email', 'Email'),
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                    ),
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty || !v.contains('@') || !v.contains('.')) {
                        return state.t('Valid email লিখুন', 'Enter a valid email');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: obscure,
                    textInputAction: TextInputAction.done,
                    autofillHints: createAccount
                        ? const [AutofillHints.newPassword]
                        : const [AutofillHints.password],
                    onFieldSubmitted: (_) {
                      if (!auth.busy) _submit();
                    },
                    decoration: InputDecoration(
                      labelText: state.t('Password', 'Password'),
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => obscure = !obscure),
                        icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? '').length < 6) {
                        return state.t('কমপক্ষে 6 characters দিন', 'Use at least 6 characters');
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            if (!createAccount)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: auth.busy ? null : _resetPassword,
                  child: Text(state.t('Password ভুলে গেছেন?', 'Forgot password?')),
                ),
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: auth.busy ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: auth.busy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        createAccount
                            ? state.t('Account তৈরি করুন', 'Create Account')
                            : state.t('Sign in', 'Sign in'),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: auth.busy
                  ? null
                  : () => setState(() {
                        createAccount = !createAccount;
                      }),
              child: Text(
                createAccount
                    ? state.t('আগে account আছে? Sign in', 'Already have an account? Sign in')
                    : state.t('নতুন account তৈরি করুন', 'Create a new account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
