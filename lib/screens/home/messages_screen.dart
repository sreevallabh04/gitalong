import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/utils/logger.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    AppLogger.logger.navigation('💬 Messages screen initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // GitHub black
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22), // GitHub dark gray
        elevation: 0,
        title: Text(
          'Messages',
          style: GoogleFonts.orbitron(
            color: const Color(0xFFF0F6FC), // GitHub white
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement search
              AppLogger.logger.navigation('🔍 Search messages tapped');
            },
            icon: Icon(
              PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
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
                      Color(0xFF1F6FEB), // GitHub blue
                      Color(0xFF388BFD), // GitHub light blue
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  PhosphorIcons.chatCircle(PhosphorIconsStyle.fill),
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No Messages Yet',
                style: GoogleFonts.orbitron(
                  color: const Color(0xFFF0F6FC), // GitHub white
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Start swiping to connect with\nawesome developers',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF7D8590), // GitHub muted
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to swipe screen
                  AppLogger.logger.navigation('🔄 Go to swipe tapped');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F6FEB), // GitHub blue
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
                  'Start Discovering',
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
