import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/firestore_utils.dart';
import '../../providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class MaintainerLoginScreen extends ConsumerStatefulWidget {
  const MaintainerLoginScreen({super.key});

  @override
  ConsumerState<MaintainerLoginScreen> createState() =>
      _MaintainerLoginScreenState();
}

class _MaintainerLoginScreenState extends ConsumerState<MaintainerLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final auth = ref.read(authServiceProvider);
    try {
      final userCred = await auth.signInWithEmail(email, password);
      final user = userCred.user;
      if (user == null) throw Exception('No user found');
      final userDoc = await safeQuery(() async {
        final doc =
            await auth.firestore.collection('users').doc(user.uid).get();
        return doc.data();
      });
      if (userDoc == null || userDoc['isMaintainer'] != true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contributor access only')),
          );
        }
        await auth.signOut();
        setState(() => _isLoading = false);
        return;
      }
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/maintainer-dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Maintainer Login',
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFFC9D1D9),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                style: GoogleFonts.jetBrainsMono(color: Color(0xFFC9D1D9)),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFF7D8590)),
                  filled: true,
                  fillColor: Color(0xFF0D1117),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.jetBrainsMono(color: Color(0xFFC9D1D9)),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color(0xFF7D8590)),
                  filled: true,
                  fillColor: Color(0xFF0D1117),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
