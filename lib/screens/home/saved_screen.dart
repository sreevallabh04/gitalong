import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/utils/logger.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  @override
  void initState() {
    super.initState();
    AppLogger.logger.navigation('🔖 Saved screen initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // GitHub black
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22), // GitHub dark gray
        elevation: 0,
        title: Text(
          'Saved',
          style: GoogleFonts.orbitron(
            color: const Color(0xFFF0F6FC), // GitHub white
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement sort/filter
              AppLogger.logger.navigation('🔧 Sort saved items tapped');
            },
            icon: Icon(
              PhosphorIcons.sortAscending(PhosphorIconsStyle.regular),
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
                      Color(0xFFBC4C00), // GitHub orange
                      Color(0xFFE09800), // GitHub yellow
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  PhosphorIcons.bookmark(PhosphorIconsStyle.fill),
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No Saved Items',
                style: GoogleFonts.orbitron(
                  color: const Color(0xFFF0F6FC), // GitHub white
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Projects and profiles you save\nwill appear here',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF7D8590), // GitHub muted
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to discover
                  AppLogger.logger.navigation('🔍 Discover projects tapped');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBC4C00), // GitHub orange
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
                  'Discover Projects',
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
