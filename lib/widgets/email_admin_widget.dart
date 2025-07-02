import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/email_service.dart';
import '../core/utils/logger.dart';
import '../providers/auth_provider.dart';

class EmailAdminWidget extends ConsumerStatefulWidget {
  const EmailAdminWidget({super.key});

  @override
  ConsumerState<EmailAdminWidget> createState() => _EmailAdminWidgetState();
}

class _EmailAdminWidgetState extends ConsumerState<EmailAdminWidget> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _statusMessage;
  Map<String, dynamic>? _emailHealth;

  @override
  void initState() {
    super.initState();
    _checkEmailHealth();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkEmailHealth() async {
    try {
      final health = await EmailService.testEmailSystem();
      if (mounted) {
        setState(() {
          _emailHealth = health;
        });
      }
    } catch (e) {
      AppLogger.logger.e('❌ Error checking email health', error: e);
    }
  }

  Future<void> _sendWelcomeEmail() async {
    if (_emailController.text.trim().isEmpty) {
      _showMessage('Please enter an email address', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final name = _nameController.text.trim().isEmpty
          ? email.split('@')[0]
          : _nameController.text.trim();

      await EmailService.sendWelcomeEmail(
        email: email,
        displayName: name,
      );

      _showMessage('✅ Welcome email triggered for: $email');
      _emailController.clear();
      _nameController.clear();

      // Refresh health status
      await _checkEmailHealth();
    } catch (e) {
      _showMessage('❌ Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendWelcomeToCurrentUser() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      await EmailService.sendWelcomeToCurrentUser();
      _showMessage('✅ Welcome email sent to current user');
      await _checkEmailHealth();
    } catch (e) {
      _showMessage('❌ Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    setState(() {
      _statusMessage = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor:
            isError ? const Color(0xFFDA3633) : const Color(0xFF2EA043),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.email_rounded,
                color: Color(0xFF2EA043),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Email System Admin',
                style: TextStyle(
                  color: Color(0xFFF0F6FC),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF2EA043)),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Email Health Status
          if (_emailHealth != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _emailHealth!['firebase_connection'] == true
                            ? Icons.check_circle
                            : Icons.error,
                        color: _emailHealth!['firebase_connection'] == true
                            ? const Color(0xFF2EA043)
                            : const Color(0xFFDA3633),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'System Status',
                        style: TextStyle(
                          color: Color(0xFFF0F6FC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Firebase: ${_emailHealth!['firebase_connection'] ? "Connected" : "Disconnected"}',
                    style: const TextStyle(
                      color: Color(0xFF7D8590),
                      fontSize: 12,
                    ),
                  ),
                  if (_emailHealth!['current_user'] != null) ...[
                    Text(
                      'Current User: ${_emailHealth!['current_user']['email']}',
                      style: const TextStyle(
                        color: Color(0xFF7D8590),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Has Welcome Email: ${_emailHealth!['current_user']['has_welcome_email']}',
                      style: const TextStyle(
                        color: Color(0xFF7D8590),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Quick Actions for Current User
          if (authState.value != null) ...[
            const Text(
              'Quick Actions',
              style: TextStyle(
                color: Color(0xFFF0F6FC),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _sendWelcomeToCurrentUser,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Send Welcome to Current User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2EA043),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Manual Email Send
          const Text(
            'Send Welcome Email',
            style: TextStyle(
              color: Color(0xFFF0F6FC),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _emailController,
            style: const TextStyle(color: Color(0xFFF0F6FC)),
            decoration: InputDecoration(
              hintText: 'Enter email address',
              hintStyle: const TextStyle(color: Color(0xFF7D8590)),
              filled: true,
              fillColor: const Color(0xFF0D1117),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF30363D)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF30363D)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2EA043)),
              ),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Color(0xFF7D8590),
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _nameController,
            style: const TextStyle(color: Color(0xFFF0F6FC)),
            decoration: InputDecoration(
              hintText: 'Display name (optional)',
              hintStyle: const TextStyle(color: Color(0xFF7D8590)),
              filled: true,
              fillColor: const Color(0xFF0D1117),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF30363D)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF30363D)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2EA043)),
              ),
              prefixIcon: const Icon(
                Icons.person_outline,
                color: Color(0xFF7D8590),
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendWelcomeEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Send Welcome Email',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Refresh Button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _checkEmailHealth,
              icon: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF7D8590),
                size: 16,
              ),
              label: const Text(
                'Refresh Status',
                style: TextStyle(
                  color: Color(0xFF7D8590),
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // Status Message
          if (_statusMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _statusMessage!.contains('❌')
                    ? const Color(0xFFDA3633).withOpacity(0.1)
                    : const Color(0xFF2EA043).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _statusMessage!.contains('❌')
                      ? const Color(0xFFDA3633)
                      : const Color(0xFF2EA043),
                ),
              ),
              child: Text(
                _statusMessage!,
                style: TextStyle(
                  color: _statusMessage!.contains('❌')
                      ? const Color(0xFFDA3633)
                      : const Color(0xFF2EA043),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
