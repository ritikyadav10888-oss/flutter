import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';
import '../../../shared/widgets/one_ui_widgets.dart';

class PlayerDetailsView extends StatelessWidget {
  final Player player;

  const PlayerDetailsView({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: OneUIResponsivePadding(
        child: CustomScrollView(
          slivers: [
            OneUISliverHeader(
              title: player.name,
              subtitle: 'Registered Player',
              expanded: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.sectionSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar & Basic Info Card
                    _buildIdentityCard(context),
                    const SizedBox(height: 24),

                    // Basic Contact Info
                    OneUISection(
                      title: 'Contact Details',
                      showSeparator: true,
                      children: [
                        _buildDetailTile(
                          Icons.email_outlined,
                          'Email',
                          player.email,
                        ),
                        _buildDetailTile(
                          Icons.phone_outlined,
                          'Phone',
                          player.phoneNumber ?? 'Not provided',
                        ),
                        _buildDetailTile(
                          Icons.contact_phone_outlined,
                          'Emergency',
                          player.emergencyContactNumber ?? 'Not provided',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Personal Information
                    OneUISection(
                      title: 'Personal Information',
                      showSeparator: true,
                      children: [
                        _buildDetailTile(
                          Icons.cake_outlined,
                          'Birthday',
                          player.dateOfBirth != null
                              ? DateFormat(
                                  'MMM dd, yyyy',
                                ).format(player.dateOfBirth!)
                              : 'Not provided',
                        ),
                        _buildDetailTile(
                          Icons.person_outline,
                          'Gender',
                          player.gender ?? 'Not provided',
                        ),
                        _buildDetailTile(
                          Icons.workspace_premium_outlined,
                          'Position',
                          player.playingPosition ?? 'Not provided',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Health Information
                    OneUISection(
                      title: 'Health & Safety',
                      showSeparator: true,
                      children: [
                        _buildHealthTile(),
                        if (player.hasHealthIssues == true &&
                            player.healthIssueDetails != null)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              player.healthIssueDetails!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Verification
                    OneUISection(
                      title: 'Verification',
                      showSeparator: true,
                      children: [
                        _buildDetailTile(
                          Icons.badge_outlined,
                          'Aadhar Number',
                          player.aadharNumber ?? 'Not verified',
                        ),
                        if (player.aadharPic != null)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                player.aadharPic!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Text('Aadhar Image not available'),
                                    ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityCard(BuildContext context) {
    return OneUICard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primaryIndigo.withValues(alpha: 0.1),
            backgroundImage: player.profilePic != null
                ? NetworkImage(player.profilePic!)
                : null,
            child: player.profilePic == null
                ? const Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.primaryIndigo,
                  )
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: player.isProfileComplete
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    player.isProfileComplete
                        ? 'VERIFIED PROFILE'
                        : 'INCOMPLETE PROFILE',
                    style: TextStyle(
                      color: player.isProfileComplete
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryIndigo, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHealthTile() {
    final hasIssues = player.hasHealthIssues == true;
    return ListTile(
      leading: Icon(
        hasIssues ? Icons.warning_amber_rounded : Icons.check_circle_outline,
        color: hasIssues ? Colors.red : Colors.green,
      ),
      title: const Text(
        'Medical Conditions',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      trailing: Text(
        hasIssues ? 'Action Required' : 'Healthy',
        style: TextStyle(
          color: hasIssues ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
