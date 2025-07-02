import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/utils/logger.dart';
import '../../core/monitoring/analytics_service.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;

  @override
  void initState() {
    super.initState();
    AppLogger.logger.navigation('💬 Messages screen initialized');
    AnalyticsService.trackScreenView('messages_screen');
    
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
            center: Alignment.topRight,
            radius: 2.5,
            colors: [
              const Color(0xFF1F6FEB).withValues(alpha: 0.08),
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
                colors: [Color(0xFF1F6FEB), Color(0xFF388BFD)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F6FEB).withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              PhosphorIcons.chatCircle(PhosphorIconsStyle.fill),
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
                  'Messages',
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFF0F6FC),
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Connect with developers',
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  AppLogger.logger.navigation('🔍 Search messages tapped');
                },
                child: Icon(
                  PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                  color: const Color(0xFF7D8590),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate(controller: _contentController)
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
            // Animated Chat Icon
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1F6FEB),
                    Color(0xFF388BFD),
                  ],
                ),
                borderRadius: BorderRadius.circular(70),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1F6FEB).withValues(alpha: 0.4),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      PhosphorIcons.chatCircle(PhosphorIconsStyle.fill),
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                  
                  // Floating message bubbles
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF238636),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF238636).withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        PhosphorIcons.heart(PhosphorIconsStyle.fill),
                        color: Colors.white,
                        size: 12,
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .moveY(begin: 0, end: -10, duration: 2000.ms)
                      .fadeIn(duration: 1000.ms),
                  ),
                  
                  Positioned(
                    bottom: 25,
                    left: 15,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE09800),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE09800).withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        PhosphorIcons.star(PhosphorIconsStyle.fill),
                        color: Colors.white,
                        size: 10,
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .moveX(begin: 0, end: 8, duration: 1500.ms)
                      .fadeIn(duration: 1200.ms, delay: 500.ms),
                  ),
                ],
              ),
            ).animate(controller: _contentController)
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
                  Color(0xFF1F6FEB),
                  Color(0xFF388BFD),
                ],
              ).createShader(bounds),
              child: Text(
                'No Messages Yet',
                style: GoogleFonts.orbitron(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ).animate(controller: _contentController)
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
                    'Start connecting with amazing developers',
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
                        PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                        color: const Color(0xFF1F6FEB),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Swipe right to start conversations',
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
            ).animate(controller: _contentController)
              .fadeIn(duration: 800.ms, delay: 600.ms)
              .slideY(begin: 0.2, curve: Curves.easeOut),

            const SizedBox(height: 48),

            // Action Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1F6FEB).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  AppLogger.logger.navigation('🔄 Start discovering tapped');
                  // TODO: Navigate to swipe screen
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    PhosphorIcons.heart(PhosphorIconsStyle.fill),
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                label: Text(
                  'Start Discovering',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F6FEB),
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
            ).animate(controller: _contentController)
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
                    icon: PhosphorIcons.lightning(PhosphorIconsStyle.fill),
                    title: 'Instant Chat',
                    subtitle: 'Real-time messaging',
                    color: const Color(0xFFE09800),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFeatureCard(
                    icon: PhosphorIcons.users(PhosphorIconsStyle.fill),
                    title: 'Team Up',
                    subtitle: 'Collaborate on projects',
                    color: const Color(0xFF238636),
                  ),
                ),
              ],
            ).animate(controller: _contentController)
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
