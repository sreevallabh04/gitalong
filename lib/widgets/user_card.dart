import 'package:flutter/material.dart';
import '../models/models.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final dynamic swipeProperties;

  const UserCard({super.key, required this.user, this.swipeProperties});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? user.id,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(
                          user.role.toString().split('.').last.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bio
            if (user.bio != null) ...[
              Text(
                user.bio!,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
            ],

            // Skills
            if (user.skills.isNotEmpty) ...[
              Text(
                'Skills:',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.skills.take(5).map((skill) {
                  return Chip(
                    label: Text(skill),
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            const Spacer(),

            // GitHub link
            if (user.githubUrl != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.link,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.githubUrl!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
