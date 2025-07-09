import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/utils/logger.dart';
import '../../core/monitoring/analytics_service.dart';
import '../../core/utils/accessibility_utils.dart';
import '../../widgets/common/accessible_button.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;

  @override
  void initState() {
    super.initState();
    AppLogger.logger.navigation('🔖 Saved screen initialized');
    AnalyticsService.trackScreenView('saved_screen');

    _setupAnimations();
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.5,
            colors: [
              const Color(0xFFE09800).withValues(alpha: 0.08),
              const Color(0xFF0D1117),
              const Color(0xFF0D1117),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildEnhancedAppBar(),
              Expanded(
                child: _buildEmptyState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE09800), Color(0xFFF7C52D)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE09800).withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              PhosphorIcons.bookmark(PhosphorIconsStyle.fill),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved',
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFF0F6FC),
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Your favorite discoveries',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF7D8590),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF30363D),
              ),
            ),
            child: AccessibleIconButton(
              onPressed: () {
                HapticUtils.lightImpact();
                AppLogger.logger.navigation('🔧 Sort saved items tapped');
              },
              icon: PhosphorIcons.funnelSimple(PhosphorIconsStyle.regular),
              label: 'Sort or filter saved items',
              semanticLabel: AccessibilityUtils.getButtonLabel(
                  'Sort or filter saved items', false),
              enableHapticFeedback: true,
              iconColor: const Color(0xFF7D8590),
              size: 20,
            ),
          ),
        ],
      ),
    )
        .animate(controller: _contentController)
        .fadeIn(duration: 800.ms)
        .slideY(begin: -0.5, curve: Curves.easeOutBack);
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Bookmark Stack
            Stack(
              alignment: Alignment.center,
              children: [
                // Background bookmark
                Transform.rotate(
                  angle: -0.1,
                  child: Container(
                    width: 120,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFBC4C00),
                          Color(0xFFE09800),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE09800).withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .rotate(begin: -0.1, end: -0.05, duration: 3000.ms),

                // Main bookmark
                Container(
                  width: 140,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE09800),
                        Color(0xFFF7C52D),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE09800).withValues(alpha: 0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          PhosphorIcons.bookmark(PhosphorIconsStyle.fill),
                          size: 80,
                          color: Colors.white,
                        ),
                      ),

                      // Floating stars
                      Positioned(
                        top: 20,
                        right: 15,
                        child: Icon(
                          PhosphorIcons.star(PhosphorIconsStyle.fill),
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 16,
                        )
                            .animate(
                                onPlay: (controller) => controller.repeat())
                            .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1.2, 1.2))
                            .then(delay: 500.ms)
                            .scale(
                                begin: const Offset(1.2, 1.2),
                                end: const Offset(0.8, 0.8)),
                      ),

                      Positioned(
                        bottom: 30,
                        left: 10,
                        child: Icon(
                          PhosphorIcons.heart(PhosphorIconsStyle.fill),
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 14,
                        )
                            .animate(
                                onPlay: (controller) => controller.repeat())
                            .fadeIn(duration: 1000.ms)
                            .then(delay: 1000.ms)
                            .fadeOut(duration: 1000.ms),
                      ),
                    ],
                  ),
                ),
              ],
            )
                .animate(controller: _contentController)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 1200.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 800.ms),

            const SizedBox(height: 48),

            // Title with gradient
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFE09800),
                  Color(0xFFF7C52D),
                ],
              ).createShader(bounds),
              child: Text(
                'No Saved Items',
                style: GoogleFonts.orbitron(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            )
                .animate(controller: _contentController)
                .fadeIn(duration: 1000.ms, delay: 400.ms)
                .slideY(begin: 0.3, curve: Curves.easeOutBack),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF21262D).withValues(alpha: 0.6),
                    const Color(0xFF161B22).withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF30363D).withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Projects and profiles you save will appear here',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: const Color(0xFFC9D1D9),
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.bold),
                        color: const Color(0xFFE09800),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tap the bookmark icon to save items',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          color: const Color(0xFF7D8590),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
                .animate(controller: _contentController)
                .fadeIn(duration: 800.ms, delay: 600.ms)
                .slideY(begin: 0.2, curve: Curves.easeOut),

            const SizedBox(height: 48),

            // Action Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE09800).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  AppLogger.logger.navigation('🔍 Discover projects tapped');
                  // TODO: Navigate to discover
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.bold),
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                label: Text(
                  'Discover Projects',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE09800),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            )
                .animate(controller: _contentController)
                .fadeIn(duration: 800.ms, delay: 800.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  curve: Curves.elasticOut,
                ),

            const SizedBox(height: 32),

            // Feature Cards
            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: PhosphorIcons.folders(PhosphorIconsStyle.fill),
                    title: 'Organize',
                    subtitle: 'Create collections',
                    color: const Color(0xFF238636),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFeatureCard(
                    icon: PhosphorIcons.export(PhosphorIconsStyle.fill),
                    title: 'Share',
                    subtitle: 'Export your lists',
                    color: const Color(0xFF1F6FEB),
                  ),
                ),
              ],
            )
                .animate(controller: _contentController)
                .fadeIn(duration: 800.ms, delay: 1000.ms)
                .slideY(begin: 0.3, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF0F6FC),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF7D8590),
            ),
          ),
        ],
      ),
    );
  }
}
