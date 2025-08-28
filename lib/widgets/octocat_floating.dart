import 'package:flutter/material.dart';

class OctocatFloating extends StatelessWidget {

  const OctocatFloating({
    required this.onTap, super.key,
  });
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => FloatingActionButton(
      onPressed: onTap,
      backgroundColor: const Color(0xFF238636),
      child: const Text('🐙', style: TextStyle(fontSize: 24)),
    );
}

