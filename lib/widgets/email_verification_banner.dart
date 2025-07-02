import 'package:flutter/material.dart';

class EmailVerificationBanner extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onResend;

  const EmailVerificationBanner({
    super.key,
    required this.onRefresh,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      backgroundColor: const Color(0xFF161B22),
      content: const Text(
        "Please verify your email to continue. Check your inbox for a verification link.",
        style: TextStyle(color: Color(0xFFC9D1D9)),
      ),
      actions: [
        TextButton(
          onPressed: onResend,
          child: const Text("Resend"),
        ),
        TextButton(
          onPressed: onRefresh,
          child: const Text("Refresh"),
        ),
      ],
    );
  }
}
