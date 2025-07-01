import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/utils/logger.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  @override
  void initState() {
    super.initState();
    AppLogger.logger.navigation('💕 Swipe screen initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // GitHub black
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22), // GitHub dark gray
        elevation: 0,
        title: Text(
          'Discover',
          style: GoogleFonts.orbitron(
            color: const Color(0xFFF0F6FC), // GitHub white
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement filters
              AppLogger.logger.navigation('🔍 Filters tapped');
            },
            icon: Icon(
              PhosphorIcons.faders(PhosphorIconsStyle.regular),
              color: const Color(0xFF7D8590), // GitHub muted
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF238636), // GitHub green
                      Color(0xFF2EA043), // GitHub light green
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  PhosphorIcons.heart(PhosphorIconsStyle.fill),
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Start Swiping',
                style: GoogleFonts.orbitron(
                  color: const Color(0xFFF0F6FC), // GitHub white
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Discover amazing open source\ndevelopers and projects',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF7D8590), // GitHub muted
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  // TODO: Start swiping
                  AppLogger.logger.navigation('🚀 Start swiping tapped');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238636), // GitHub green
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Start Swiping',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
