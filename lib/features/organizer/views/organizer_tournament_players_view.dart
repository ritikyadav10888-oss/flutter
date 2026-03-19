import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';

class OrganizerTournamentPlayersView extends StatelessWidget {
  final Tournament tournament;

  const OrganizerTournamentPlayersView({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    // Generate some mock players based on a fixed number or tournament detail
    final int playerCount = 24; // Mock value

    final List<Map<String, dynamic>> _mockPlayers = List.generate(
      playerCount,
      (index) => {
        'id': 'p$index',
        'name': 'Player Name ${index + 1}',
        'email': 'player${index + 1}@example.com',
        'position': [
          'Forward',
          'Midfielder',
          'Defender',
          'Goalkeeper',
        ][index % 4],
        'status': index % 5 == 0 ? 'PENDING' : 'CONFIRMED',
        'registrationDate': DateTime.now().subtract(Duration(days: index)),
      },
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text('${tournament.name} Players'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export List',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting list...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search players...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _mockPlayers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final player = _mockPlayers[index];
                final isConfirmed = player['status'] == 'CONFIRMED';
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryIndigo.withOpacity(0.1),
                    child: Text(
                      player['name'].substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primaryIndigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    player['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        player['email'],
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.military_tech_rounded,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            player['position'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isConfirmed
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      player['status'],
                      style: TextStyle(
                        color: isConfirmed ? Colors.green : Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    // Show mock player details bottom sheet or navigate
                    showModalBottomSheet(
                      context: context,
                      builder: (context) =>
                          _buildPlayerDetailsSheet(context, player),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerDetailsSheet(
    BuildContext context,
    Map<String, dynamic> player,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primaryIndigo.withOpacity(0.1),
            child: Text(
              player['name'].substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primaryIndigo,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            player['name'],
            style: Theme.of(context).textTheme.displayMedium,
          ),
          Text(
            player['email'],
            style: const TextStyle(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.military_tech_rounded,
            'Position',
            player['position'],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.calendar_today,
            'Registration Date',
            '${player['registrationDate'].month}/${player['registrationDate'].day}/${player['registrationDate'].year}',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.info_outline, 'Status', player['status']),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryIndigo,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textMuted),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppTheme.textMuted)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
