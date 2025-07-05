import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/firestore_utils.dart';
import '../../core/widgets/responsive_buttons.dart';

class MaintainerLoginScreen extends ConsumerStatefulWidget {
  const MaintainerLoginScreen({super.key});

  @override
  ConsumerState<MaintainerLoginScreen> createState() =>
      _MaintainerLoginScreenState();
}

class _MaintainerLoginScreenState extends ConsumerState<MaintainerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final authService = ref.read(authServiceProvider);
      try {
        final credential = await authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = credential.user;
        if (user == null) throw Exception('No user found');
        final userDoc = await safeQuery(() async {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          return doc.data();
        });
        if (userDoc != null && userDoc['isMaintainer'] == true) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/maintainer-dashboard');
          }
        } else {
          throw Exception('Access denied: Maintainer privileges required');
        }
      } catch (e) {
        throw Exception('Authentication failed: ${e.toString()}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestMaintainerAccess() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email first')),
      );
      return;
    }

    try {
      await safeQuery(() async {
        await FirebaseFirestore.instance.collection('maintainer_requests').add({
          'email': email,
          'requestedAt': FieldValue.serverTimestamp(),
          'status': 'pending',
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maintainer access request submitted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text(
          'Maintainer Login',
          style: TextStyle(color: Color(0xFFF0F6FC)),
        ),
        backgroundColor: const Color(0xFF21262D),
        iconTheme: const IconThemeData(color: Color(0xFFF0F6FC)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Maintainer Access',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF0F6FC),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in with your maintainer credentials',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF7D8590),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ResponsiveElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                isLoading: _isLoading,
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 16),
              ResponsiveTextButton(
                onPressed: _requestMaintainerAccess,
                child: const Text('Request Maintainer Access'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
