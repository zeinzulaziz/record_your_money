import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _busy = false;

  Future<void> _signIn() async {
    setState(() => _busy = true);
    try {
      if (_email.text.trim().isEmpty || _password.text.trim().isEmpty) {
        throw Exception('Email dan password wajib diisi');
      }
      await Supabase.instance.client.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('anonymous_provider_disabled')
            ? 'Provider anonymous dimatikan. Aktifkan Email provider di Supabase dan isi email/password.'
            : 'Login gagal: $e';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signUp() async {
    setState(() => _busy = true);
    try {
      if (_email.text.trim().isEmpty || _password.text.trim().isEmpty) {
        throw Exception('Email dan password wajib diisi');
      }
      await Supabase.instance.client.auth.signUp(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Registrasi berhasil, cek email bila perlu verifikasi.')));
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('anonymous_provider_disabled')
            ? 'Provider anonymous dimatikan. Aktifkan Email provider di Supabase dan isi email/password.'
            : 'Registrasi gagal: $e';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masuk')), 
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _signIn,
              child: const Text('Masuk'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : _signUp,
              child: const Text('Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          return const AuthScreen();
        }
        return child;
      },
    );
  }
}


