import 'package:flutter/material.dart';
import '../models/contribution_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

/// Data model for commit activity visualization
class CommitData {
  final DateTime date;
  final int commitCount;
  final int level;

  const CommitData({
    required this.date,
    required this.commitCount,
    required this.level,
  });

  static List<CommitData> generateSampleData() {
    final data = <CommitData>[];
    final now = DateTime.now();
    final random = Random();

    for (int i = 365; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final commitCount = random.nextBool() ? random.nextInt(10) : 0;
      final level = commitCount == 0 ? 0 : (commitCount / 3).ceil().clamp(1, 4);

      data.add(CommitData(
        date: date,
        commitCount: commitCount,
        level: level,
      ));
    }

    return data;
  }
}

/// GitHub-style contribution graph that displays commit activity over time
/// This is the crown jewel of our developer-focused UI
class ContributionGraph extends StatefulWidget {
  final List<ContributionModel> contributions;
  final int weeks;

  const ContributionGraph({
    super.key,
    required this.contributions,
    this.weeks = 52,
  });

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
    _data = CommitData.generateSampleData();

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _titleAnimation = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutCubic,
    );

    _titleController.forward();
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
    final theme = Theme.of(context);
    switch (level) {
      case 0:
        return const Color(0xFF161B22);
      case 1:
        return const Color(0xFF2EA043).withValues(alpha: 0.3);
      case 2:
        return const Color(0xFF2EA043).withValues(alpha: 0.5);
      case 3:
        return const Color(0xFF2EA043).withValues(alpha: 0.7);
      case 4:
      default:
        return const Color(0xFF2EA043);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grid = List.generate(
        widget.weeks, (i) => _data.length > i ? _data[i].commitCount : 0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                            'Contribution Activity',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_totalCommits commits in the last year',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$_currentStreak day streak',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
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
          Row(
            children: [
              const SizedBox(width: 40), // Space for day labels
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _monthLabels.map((month) {
                    return Text(
                      month,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Main Graph
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day Labels
              Column(
                children: [
                  const SizedBox(height: 14), // Align with first row
                  ...['Mon', 'Wed', 'Fri'].map((day) {
                    return Container(
                      height: 16,
                      margin: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        day,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }),
                ],
              ),

              const SizedBox(width: 8),

              // Commit Grid
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: widget.weeks * 14,
                    height: 14 * 7,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                      ),
                      itemCount: widget.weeks,
                      itemBuilder: (context, i) {
                        return AnimatedContainer(
                          duration: Duration(
                              milliseconds: 400 + Random().nextInt(400)),
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
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(left: 2),
                    decoration: BoxDecoration(
                      color: _colorForLevel(index),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                  );
                }),
              ),
              Text(
                'More',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor, width: 1),
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
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Commit Activity',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'Date',
              '${commit.date.day}/${commit.date.month}/${commit.date.year}',
            ),
            _buildInfoRow(
              context,
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
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.dividerColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample commits:',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      commit.commitCount.clamp(1, 3),
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${_getSampleCommitMessage(index)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
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
