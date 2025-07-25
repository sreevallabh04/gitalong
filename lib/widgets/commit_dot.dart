import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';

/// A single commit dot in the contribution graph that animates with heat levels
/// This is the building block for our GitHub-style contribution visualization
class CommitDot extends StatefulWidget {
  const CommitDot({
    super.key,
    required this.commitCount,
    required this.date,
    this.size = 12.0,
    this.animationDelay = Duration.zero,
    this.onTap,
  });

  /// Number of commits for this day (0-20+)
  final int commitCount;

  /// The date this dot represents
  final DateTime date;

  /// Size of the dot
  final double size;

  /// Delay before animation starts
  final Duration animationDelay;

  /// Callback when dot is tapped
  final VoidCallback? onTap;

  @override
  State<CommitDot> createState() => _CommitDotState();
}

class _CommitDotState extends State<CommitDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  /// Converts commit count to heat level (0-4)
  int get _heatLevel {
    if (widget.commitCount == 0) return 0;
    if (widget.commitCount <= 2) return 1;
    if (widget.commitCount <= 5) return 2;
    if (widget.commitCount <= 10) return 3;
    return 4; // 11+ commits
  }

  /// Gets the color for the current heat level
  Color get _dotColor {
    final theme = Theme.of(context).extension<GitAlongThemeExtension>()!;
    return theme.commitDotColors[_heatLevel];
  }

  /// Gets the glow effect based on heat level
  List<BoxShadow> get _glowEffect {
    if (_heatLevel == 0) return [];

    final intensity = _heatLevel / 4.0;
    final glowColor = AppTheme.accentColor.withValues(alpha: 0.3 * intensity);

    return [
      BoxShadow(
        color: glowColor,
        blurRadius: 8 * intensity,
        spreadRadius: 2 * intensity,
      ),
    ];
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            final scale = 1.0 + (_hoverController.value * 0.2);
            final opacity = 0.7 + (_hoverController.value * 0.3);

            return Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: _dotColor.withValues(alpha: opacity),
                  borderRadius: BorderRadius.circular(2),
                  border: _isHovered
                      ? Border.all(
                          color: AppTheme.accentColor.withValues(alpha: 0.5),
                          width: 1,
                        )
                      : null,
                  boxShadow: _isHovered ? _glowEffect : null,
                ),
                child: _heatLevel > 0
                    ? Center(
                        child: Container(
                          width: widget.size * 0.3,
                          height: widget.size * 0.3,
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      )
                    : null,
              ),
            );
          },
        ),
      ),
    )
        .animate(delay: widget.animationDelay)
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          curve: Curves.elasticOut,
        );
  }
}

/// A tooltip that shows commit details when hovering over a CommitDot
class CommitTooltip extends StatelessWidget {
  const CommitTooltip({
    super.key,
    required this.commitCount,
    required this.date,
    required this.child,
  });

  final int commitCount;
  final DateTime date;
  final Widget child;

  String get _tooltipText {
    final dateStr = '${date.day}/${date.month}/${date.year}';
    if (commitCount == 0) {
      return 'No commits on $dateStr';
    } else if (commitCount == 1) {
      return '1 commit on $dateStr';
    } else {
      return '$commitCount commits on $dateStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _tooltipText,
      textStyle: AppTheme.codeStyle.copyWith(
        color: AppTheme.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      waitDuration: const Duration(milliseconds: 500),
      child: child,
    );
  }
}

/// Helper class for managing commit data
class CommitData {
  const CommitData({
    required this.date,
    required this.commitCount,
  });

  final DateTime date;
  final int commitCount;

  /// Creates empty commit data for the last 53 weeks (GitHub-style)
  /// In production, this should be replaced with real GitHub API data
  static List<CommitData> generateEmptyData() {
    final data = <CommitData>[];
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 371)); // ~53 weeks

    for (int i = 0; i < 371; i++) {
      final date = startDate.add(Duration(days: i));
      data.add(CommitData(date: date, commitCount: 0));
    }

    return data;
  }

  /// Creates commit data from real GitHub API response
  /// This method should be used in production with actual GitHub data
  static List<CommitData> fromGitHubData(Map<String, dynamic> githubResponse) {
    final data = <CommitData>[];
    // Implementation depends on GitHub API response format
    // This is a placeholder for real implementation
    return data;
  }
}
