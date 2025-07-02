import 'package:flutter/material.dart';

class OctocatFloating extends StatelessWidget {
  final VoidCallback onTap;

  const OctocatFloating({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      backgroundColor: const Color(0xFF238636),
      child: const Text('🐙', style: TextStyle(fontSize: 24)),
    );
  }
}
