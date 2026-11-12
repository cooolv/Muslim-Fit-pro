import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CloudAccessGate extends StatefulWidget {
  final Widget Function(User user) builder;

  const CloudAccessGate({super.key, required this.builder});

  @override
  State<CloudAccessGate> createState() => _CloudAccessGateState();
}

class _CloudAccessGateState extends State<CloudAccessGate> {
  bool _connecting = false;
  String? _error;

  Future<void> _connect() async {
    setState(() {
      _connecting = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = 'تعذر الاتصال (${e.code}). تحقق من الإنترنت ثم أعد المحاولة.');
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('تعذر التحقق من تسجيل الدخول للخدمات السحابية'));
          }
          if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;
          if (user != null) return widget.builder(user);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'هذه الصفحة تحتاج اتصالًا بالإنترنت. التمارين والخطط الجاهزة تعمل دون اتصال.',
                    textAlign: TextAlign.center,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _connecting ? null : _connect,
                    child: Text(_connecting ? 'جارٍ الاتصال...' : 'اتصال وإعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
