import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/aura_widgets.dart';
import '../../../shared/widgets/one_ui_widgets.dart';
import 'organizer_tournament_players_view.dart';

class OrganizerTournamentDetailView extends StatelessWidget {
  final Tournament tournament;

  const OrganizerTournamentDetailView({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    final date = tournament.date;
    final dateStr = DateFormat('dd MMM yyyy').format(date);

    String formatDetail = '';
    if (tournament.type == TournamentType.teamBased) {
      formatDetail =
          '${tournament.maxTeams ?? 0} Teams · ${tournament.playersPerTeam ?? 0} Players each';
    } else if (tournament.type == TournamentType.auctionBased) {
      formatDetail = 'Auction Pool · Solo Entry';
    } else {
      formatDetail = tournament.entryFormat.name.toUpperCase();
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundAura,
      body: CustomScrollView(
        slivers: [
          AuraHeader(
            title: 'Tournament Hub',
            subtitle: 'Management Dashboard',
            onBack: () => Navigator.pop(context),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share_outlined,
                  color: AppTheme.primaryIndigo,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Premium Hero Card
                  AuraCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryIndigo.withOpacity(0.05),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppTheme.radiusLG),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  _getSportIcon(tournament.sportType),
                                  size: 80,
                                  color: AppTheme.primaryIndigo.withOpacity(
                                    0.2,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: _buildStatusChip(tournament.status),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tournament.name.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${tournament.sportType} · $formatDetail',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryIndigo.withOpacity(
                                    0.7,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildDetailRow(
                                Icons.calendar_today_outlined,
                                'Schedule',
                                '$dateStr · ${DateFormat('hh:mm a').format(date)}',
                              ),
                              const Divider(height: 24, thickness: 0.5),
                              _buildDetailRow(
                                Icons.place_outlined,
                                'Venue',
                                tournament.location,
                              ),
                              const Divider(height: 24, thickness: 0.5),
                              _buildDetailRow(
                                Icons.groups_outlined,
                                'Format Info',
                                formatDetail,
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 32),
                  const OneUISection(title: 'QUICK MANAGEMENT', children: []),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildActionCard(
                        context,
                        'Players',
                        Icons.group_outlined,
                        AppTheme.primaryIndigo,
                      ),
                      _buildActionCard(
                        context,
                        'Fixtures',
                        Icons.account_tree_outlined,
                        AppTheme.successGreen,
                      ),
                      _buildActionCard(
                        context,
                        'Payments',
                        Icons.payments_outlined,
                        AppTheme.warningAmber,
                      ),
                      _buildActionCard(
                        context,
                        'Settings',
                        Icons.settings_outlined,
                        AppTheme.accentCoral,
                      ),
                    ],
                  ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textMuted),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: AppTheme.textMuted,
                letterSpacing: 1,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final isClosed = status.toUpperCase() == 'CLOSED';
    final color = isClosed ? AppTheme.accentCoral : AppTheme.successGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
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
    return AuraCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          if (title == 'Players') {
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
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSportIcon(String sport) {
    final s = sport.toLowerCase();
    if (s.contains('cricket')) return Icons.sports_cricket;
    if (s.contains('football')) return Icons.sports_soccer;
    if (s.contains('basketball')) return Icons.sports_basketball;
    if (s.contains('tennis')) return Icons.sports_tennis;
    if (s.contains('badminton')) return Icons.sports;
    if (s.contains('volleyball')) return Icons.sports_volleyball;
    if (s.contains('kabaddi')) return Icons.sports_kabaddi;
    if (s.contains('hockey')) return Icons.sports_hockey;
    if (s.contains('chess')) return Icons.grid_view;
    if (s.contains('boxing')) return Icons.sports_mma;
    return Icons.emoji_events_outlined;
  }
}
