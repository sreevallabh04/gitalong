import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../core/theme/app_theme.dart';
import '../models/github_user_model.dart';

/// GitHub profile card that makes recruiters weep with its beauty
/// Features real GitHub data, hover effects, and terminal aesthetics
class GitHubProfileCard extends StatefulWidget {
  const GitHubProfileCard({
    super.key,
    required this.user,
    this.onTap,
    this.showContributions = true,
  });

  final GitHubUser user;
  final VoidCallback? onTap;
  final bool showContributions;

  @override
  State<GitHubProfileCard> createState() => _GitHubProfileCardState();
}

class _GitHubProfileCardState extends State<GitHubProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
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
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: GitAlongTheme.surfaceGray,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isHovered
                        ? GitAlongTheme.neonGreen.withValues(alpha: 0.5)
                        : GitAlongTheme.borderGray,
                    width: 1,
                  ),
                  boxShadow: [
                    GitAlongTheme.cardShadow,
                    if (_isHovered)
                      BoxShadow(
                        color: GitAlongTheme.neonGreen
                            .withValues(alpha: 0.2 * _glowAnimation.value),
                        blurRadius: 20 * _glowAnimation.value,
                        spreadRadius: 5 * _glowAnimation.value,
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with avatar and basic info
                    _buildHeader(),

                    const SizedBox(height: 16),

                    // Bio section
                    if (widget.user.bio != null) ...[
                      _buildBio(),
                      const SizedBox(height: 16),
                    ],

                    // Stats row
                    _buildStatsRow(),

                    const SizedBox(height: 16),

                    // Languages and skills
                    _buildLanguages(),

                    const SizedBox(height: 16),

                    // Recent activity
                    _buildRecentActivity(),

                    const SizedBox(height: 16),

                    // Footer with actions
                    _buildFooter(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(
          begin: 0.2,
          duration: 800.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar with glow effect
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: GitAlongTheme.neonGreen
                          .withValues(alpha: 0.3 * _glowAnimation.value),
                      blurRadius: 15 * _glowAnimation.value,
                      spreadRadius: 3 * _glowAnimation.value,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CachedNetworkImage(
              imageUrl: widget.user.avatarUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: GitAlongTheme.borderGray,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  PhosphorIcons.user(PhosphorIconsStyle.regular),
                  color: GitAlongTheme.devGray,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: GitAlongTheme.borderGray,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  PhosphorIcons.user(PhosphorIconsStyle.regular),
                  color: GitAlongTheme.devGray,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Name and username
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      widget.user.name ?? widget.user.login,
                      style: GitAlongTheme.titleStyle.copyWith(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.user.isVerified) ...[
                    const SizedBox(width: 8),
                    Icon(
                      PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                      size: 16,
                      color: GitAlongTheme.neonGreen,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '@${widget.user.login}',
                    style: GitAlongTheme.codeStyle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: GitAlongTheme.neonGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: GitAlongTheme.neonGreen.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '${widget.user.followers} followers',
                      style: GitAlongTheme.terminalStyle.copyWith(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // GitHub icon
        Icon(
          PhosphorIcons.githubLogo(PhosphorIconsStyle.fill),
          color: GitAlongTheme.devGray,
          size: 24,
        ),
      ],
    );
  }

  Widget _buildBio() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GitAlongTheme.carbonBlack.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: GitAlongTheme.borderGray.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        widget.user.bio!,
        style: GitAlongTheme.bodyStyle.copyWith(
          fontStyle: FontStyle.italic,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem(
          PhosphorIcons.gitBranch(PhosphorIconsStyle.regular),
          '${widget.user.publicRepos}',
          'repos',
        ),
        const SizedBox(width: 20),
        _buildStatItem(
          PhosphorIcons.star(PhosphorIconsStyle.regular),
          '${widget.user.totalStars}',
          'stars',
        ),
        const SizedBox(width: 20),
        _buildStatItem(
          PhosphorIcons.gitCommit(PhosphorIconsStyle.regular),
          '${widget.user.totalCommits}',
          'commits',
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: GitAlongTheme.devGray,
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: GitAlongTheme.codeStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GitAlongTheme.mutedStyle,
        ),
      ],
    );
  }

  Widget _buildLanguages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Languages & Skills',
          style: GitAlongTheme.terminalStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: widget.user.topLanguages.map((language) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: GitAlongTheme.borderGray.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: GitAlongTheme.borderGray,
                  width: 0.5,
                ),
              ),
              child: Text(
                language,
                style: GitAlongTheme.terminalStyle.copyWith(fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GitAlongTheme.carbonBlack.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: GitAlongTheme.borderGray.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.clock(PhosphorIconsStyle.regular),
                size: 14,
                color: GitAlongTheme.devGray,
              ),
              const SizedBox(width: 6),
              Text(
                'Latest Activity',
                style: GitAlongTheme.terminalStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.user.latestCommitMessage ?? 'No recent activity',
            style: GitAlongTheme.codeStyle.copyWith(
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // Location if available
        if (widget.user.location != null) ...[
          Icon(
            PhosphorIcons.mapPin(PhosphorIconsStyle.regular),
            size: 14,
            color: GitAlongTheme.devGray,
          ),
          const SizedBox(width: 4),
          Text(
            widget.user.location!,
            style: GitAlongTheme.mutedStyle,
          ),
          const Spacer(),
        ] else
          const Spacer(),

        // Action buttons
        Row(
          children: [
            IconButton(
              onPressed: () {
                // TODO: Open GitHub profile
              },
              icon: Icon(
                PhosphorIcons.arrowSquareOut(PhosphorIconsStyle.regular),
                size: 18,
                color: GitAlongTheme.devGray,
              ),
              style: IconButton.styleFrom(
                backgroundColor:
                    GitAlongTheme.borderGray.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.all(8),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                // TODO: Start conversation
              },
              icon: Icon(
                PhosphorIcons.chatCircle(PhosphorIconsStyle.regular),
                size: 18,
                color: GitAlongTheme.neonGreen,
              ),
              style: IconButton.styleFrom(
                backgroundColor: GitAlongTheme.neonGreen.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
