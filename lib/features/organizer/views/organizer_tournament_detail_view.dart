import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'organizer_tournament_players_view.dart';

class OrganizerTournamentDetailView extends StatelessWidget {
  final Map<String, dynamic> tournament;

  const OrganizerTournamentDetailView({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    final date = tournament['date'] as DateTime;
    final dateStr = '${date.month}/${date.day}/${date.year}';
    final isClosed = tournament['status'] == 'CLOSED';

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Manage Tournament'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Placeholder
            Container(
              height: 200,
              color: AppTheme.primaryIndigo.withOpacity(0.1),
              child: const Center(
                child: Icon(
                  Icons.sports_soccer,
                  size: 64,
                  color: AppTheme.primaryIndigo,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          tournament['name'],
                          style: Theme.of(
                            context,
                          ).textTheme.displayLarge?.copyWith(fontSize: 24),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isClosed
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isClosed
                                ? Colors.red.withOpacity(0.5)
                                : Colors.green.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          tournament['status'],
                          style: TextStyle(
                            color: isClosed ? Colors.red : Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: AppTheme.textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                dateStr,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppTheme.textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tournament['location'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(
                                Icons.people,
                                color: AppTheme.textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${tournament['playersCount']} Registered Players',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildActionCard(
                        context,
                        'View Players',
                        Icons.group,
                        AppTheme.primaryIndigo,
                      ),
                      _buildActionCard(
                        context,
                        'Edit Details',
                        Icons.edit,
                        Colors.blue,
                      ),
                      _buildActionCard(
                        context,
                        'Match Schedule',
                        Icons.sports,
                        Colors.orange,
                      ),
                      _buildActionCard(
                        context,
                        'Send Announcement',
                        Icons.campaign,
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        if (title == 'View Players') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OrganizerTournamentPlayersView(tournament: tournament),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title feature coming soon!')),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: MediaQuery.of(context).size.width > 600
            ? 200
            : (MediaQuery.of(context).size.width - 64) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
