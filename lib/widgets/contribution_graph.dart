import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import 'commit_dot.dart';
import 'dart:math';

/// GitHub-style contribution graph that displays commit activity over time
/// This is the crown jewel of our developer-focused UI
class ContributionGraph extends StatefulWidget {
  const ContributionGraph({
    super.key,
    this.data,
    this.title = 'Contribution Activity',
    this.showLabels = true,
    this.animateOnLoad = true,
    this.weeks = 12,
    this.days = 7,
  });

  /// Commit data to display. If null, generates sample data
  final List<CommitData>? data;

  /// Title shown above the graph
  final String title;

  /// Whether to show month and day labels
  final bool showLabels;

  /// Whether to animate when first loaded
  final bool animateOnLoad;

  final int weeks;
  final int days;

  @override
  State<ContributionGraph> createState() => _ContributionGraphState();
}

class _ContributionGraphState extends State<ContributionGraph>
    with TickerProviderStateMixin {
  late List<CommitData> _data;
  late AnimationController _titleController;
  late Animation<double> _titleAnimation;

  @override
  void initState() {
    super.initState();
    _data = widget.data ?? CommitData.generateSampleData();

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _titleAnimation = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutCubic,
    );

    if (widget.animateOnLoad) {
      _titleController.forward();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// Organizes data into weeks for grid layout
  List<List<CommitData>> get _weeks {
    final weeks = <List<CommitData>>[];
    List<CommitData> currentWeek = [];

    // Start from Sunday to match GitHub
    for (final commit in _data) {
      if (currentWeek.isNotEmpty && commit.date.weekday == DateTime.sunday) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
      currentWeek.add(commit);
    }

    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek);
    }

    return weeks;
  }

  /// Gets month labels for the timeline
  List<String> get _monthLabels {
    final labels = <String>[];
    final now = DateTime.now();

    for (int i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      labels.add(_getMonthAbbreviation(month.month));
    }

    return labels;
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  /// Gets total commits for stats
  int get _totalCommits {
    return _data.fold(0, (sum, commit) => sum + commit.commitCount);
  }

  /// Gets the current streak
  int get _currentStreak {
    int streak = 0;
    for (int i = _data.length - 1; i >= 0; i--) {
      if (_data[i].commitCount > 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Color _colorForLevel(int level) {
    switch (level) {
      case 0:
        return const Color(0xFF161B22);
      case 1:
        return const Color(0xFF2EA043).withOpacity(0.3);
      case 2:
        return const Color(0xFF2EA043).withOpacity(0.5);
      case 3:
        return const Color(0xFF2EA043).withOpacity(0.7);
      case 4:
      default:
        return const Color(0xFF2EA043);
    }
  }

  @override
  Widget build(BuildContext context) {
    final grid = List.generate(widget.weeks * widget.days, (i) => _data.length > i ? _data[i].commitCount : 0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GitAlongTheme.surfaceGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GitAlongTheme.borderGray, width: 1),
        boxShadow: [GitAlongTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Stats
          AnimatedBuilder(
            animation: _titleAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - _titleAnimation.value)),
                child: Opacity(
                  opacity: _titleAnimation.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: GitAlongTheme.titleStyle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_totalCommits commits in the last year',
                            style: GitAlongTheme.mutedStyle,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: GitAlongTheme.neonGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: GitAlongTheme.neonGreen.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$_currentStreak day streak',
                          style: GitAlongTheme.codeStyle.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Month Labels
          if (widget.showLabels) ...[
            Row(
              children: [
                const SizedBox(width: 40), // Space for day labels
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _monthLabels.map((month) {
                      return Text(
                        month,
                        style: GitAlongTheme.terminalStyle,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Main Graph
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day Labels
              if (widget.showLabels)
                Column(
                  children: [
                    const SizedBox(height: 14), // Align with first row
                    ...['Mon', 'Wed', 'Fri'].map((day) {
                      return Container(
                        height: 16,
                        margin: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          day,
                          style: GitAlongTheme.terminalStyle,
                        ),
                      );
                    }),
                  ],
                ),

              if (widget.showLabels) const SizedBox(width: 8),

              // Commit Grid
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: widget.weeks * 14,
                    height: widget.days * 14,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.days,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                      ),
                      itemCount: widget.weeks * widget.days,
                      itemBuilder: (context, i) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 400 + Random().nextInt(400)),
                          decoration: BoxDecoration(
                            color: _colorForLevel(grid[i]),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Less',
                style: GitAlongTheme.terminalStyle,
              ),
              Row(
                children: List.generate(5, (index) {
                  final theme = context.gitAlongTheme;
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(left: 2),
                    decoration: BoxDecoration(
                      color: theme.commitDotColors[index],
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: GitAlongTheme.borderGray.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                  );
                }),
              ),
              Text(
                'More',
                style: GitAlongTheme.terminalStyle,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(
          begin: 0.2,
          duration: 800.ms,
          curve: Curves.easeOutCubic,
        );
  }

  void _onCommitDotTapped(CommitData commit) {
    // Show detailed commit info
    showDialog(
      context: context,
      builder: (context) => _CommitDetailsDialog(commit: commit),
    );
  }
}

/// Dialog showing detailed commit information
class _CommitDetailsDialog extends StatelessWidget {
  const _CommitDetailsDialog({required this.commit});

  final CommitData commit;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: GitAlongTheme.surfaceGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: GitAlongTheme.borderGray, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.commit,
                  color: GitAlongTheme.neonGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Commit Activity',
                  style: GitAlongTheme.titleStyle.copyWith(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Date',
              '${commit.date.day}/${commit.date.month}/${commit.date.year}',
            ),
            _buildInfoRow(
              'Commits',
              commit.commitCount == 0
                  ? 'No commits'
                  : '${commit.commitCount} commit${commit.commitCount == 1 ? '' : 's'}',
            ),
            if (commit.commitCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GitAlongTheme.carbonBlack,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: GitAlongTheme.borderGray, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample commits:',
                      style: GitAlongTheme.terminalStyle,
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      commit.commitCount.clamp(1, 3),
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${_getSampleCommitMessage(index)}',
                          style: GitAlongTheme.codeStyle.copyWith(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: GitAlongTheme.ghostButtonStyle,
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 200.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: 200.ms);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GitAlongTheme.mutedStyle,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GitAlongTheme.bodyStyle,
            ),
          ),
        ],
      ),
    );
  }

  String _getSampleCommitMessage(int index) {
    const messages = [
      'feat: add user authentication',
      'fix: resolve navigation bug',
      'docs: update README',
      'refactor: improve code structure',
      'style: update UI components',
      'test: add unit tests',
    ];
    return messages[index % messages.length];
  }
}
