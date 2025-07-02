import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FloatingOctocat extends StatelessWidget {
  final VoidCallback? onTap;
  const FloatingOctocat({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: GestureDetector(
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You found the Octocat! 🐙')),
              );
            },
        child: SizedBox(
          width: 64,
          height: 64,
          child: Lottie.asset(
            'assets/animations/octocat.json',
            repeat: true,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) => Image.asset(
              'assets/octocat.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
