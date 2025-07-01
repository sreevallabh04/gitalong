import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/logger.dart';

/// Easter egg screen that would make GitHub's design team weep with envy
/// Features color-shifting background and floating Octocat animations
class OctocatModeScreen extends StatefulWidget {
  const OctocatModeScreen({super.key});

  @override
  State<OctocatModeScreen> createState() => _OctocatModeScreenState();
}

class _OctocatModeScreenState extends State<OctocatModeScreen>
    with TickerProviderStateMixin {
  late AnimationController _colorController;
  late AnimationController _floatController;
  late AnimationController _pulseController;

  late Animation<Color?> _backgroundAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    AppLogger.logger
        .navigation('🐙 Octocat mode activated - GitHub acquisition imminent');

    // Color shifting animation (green to purple sine wave)
    _colorController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // Floating animation for Octocat
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Pulsing animation for glow effects
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _backgroundAnimation = ColorTween(
      begin: GitAlongTheme.neonGreen,
      end: const Color(0xFF8B5CF6), // Purple
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));

    _floatAnimation = Tween<double>(
      begin: -20.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start all animations
    _colorController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _colorController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge(
            [_backgroundAnimation, _floatAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  _backgroundAnimation.value!.withOpacity(0.2),
                  GitAlongTheme.carbonBlack,
                  GitAlongTheme.carbonBlack,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Floating particles
                ..._buildFloatingParticles(),

                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      // Header with close button
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                PhosphorIcons.x(PhosphorIconsStyle.regular),
                                color: GitAlongTheme.ghostWhite,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    GitAlongTheme.surfaceGray.withOpacity(0.8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'OCTOCAT MODE',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _backgroundAnimation.value,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Main Octocat
                      Expanded(
                        child: Center(
                          child: Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: _backgroundAnimation.value!
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: _backgroundAnimation.value!
                                        .withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _backgroundAnimation.value!
                                          .withOpacity(0.4),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    PhosphorIcons.octagonFill(),
                                    size: 80,
                                    color: _backgroundAnimation.value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom text
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Text(
                              'You\'ve discovered the secret!',
                              style: GitAlongTheme.titleStyle.copyWith(
                                color: _backgroundAnimation.value,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'This level of polish is why GitHub would acquire us.\nEvery pixel crafted with developer obsession.',
                              style: GitAlongTheme.bodyStyle.copyWith(
                                color: GitAlongTheme.codeSilver,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    GitAlongTheme.carbonBlack.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _backgroundAnimation.value!
                                      .withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$ ',
                                    style: GitAlongTheme.codeStyle.copyWith(
                                      color: _backgroundAnimation.value,
                                    ),
                                  ),
                                  Text(
                                    'git commit -m "Octocat mode discovered"',
                                    style: GitAlongTheme.codeStyle.copyWith(
                                      color: GitAlongTheme.codeSilver,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 1000.ms).scale(
          begin: const Offset(0.8, 0.8),
          duration: 1200.ms,
          curve: Curves.elasticOut,
        );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(20, (index) {
      final random = math.Random(index);
      final delay = random.nextInt(3000);
      final duration = 3000 + random.nextInt(2000);

      return Positioned(
        left: random.nextDouble() * MediaQuery.of(context).size.width,
        top: random.nextDouble() * MediaQuery.of(context).size.height,
        child: AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return Container(
              width: 4 + random.nextDouble() * 8,
              height: 4 + random.nextDouble() * 8,
              decoration: BoxDecoration(
                color: _backgroundAnimation.value!.withOpacity(0.6),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: _backgroundAnimation.value!.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            );
          },
        )
            .animate(
              onPlay: (controller) => controller.repeat(),
            )
            .fadeIn(
              delay: Duration(milliseconds: delay),
              duration: Duration(milliseconds: duration),
            )
            .then(
              delay: Duration(milliseconds: 500),
            )
            .fadeOut(
              duration: Duration(milliseconds: 1000),
            ),
      );
    });
  }
}
