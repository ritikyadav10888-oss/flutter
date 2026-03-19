import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/aura_widgets.dart';
import 'player_profile_view.dart';
import 'tournament_registration_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../owner/viewmodels/tournament_viewmodel.dart';
import '../../../core/models/models.dart';

class PlayerDashboard extends StatefulWidget {
  const PlayerDashboard({super.key});

  @override
  State<PlayerDashboard> createState() => _PlayerDashboardState();
}

class _PlayerDashboardState extends State<PlayerDashboard> {
  int _currentIndex = 0;

  final List<Widget> _views = [const _HomeView(), const PlayerProfileView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundAura,
      body: IndexedStack(index: _currentIndex, children: _views),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final tournamentViewModel = context.watch<TournamentViewModel>();
    final tournaments = tournamentViewModel.tournaments;

    return CustomScrollView(
      slivers: [
        AuraHeader(
          title:
              'Hello, ${authViewModel.user?.name?.split(' ').first ?? 'Player'}',
          subtitle: 'Ready for your next tournament?',
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppTheme.accentCoral,
                ),
                onPressed: () => _showSignOutDialog(context),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.auraPadding,
              vertical: AppTheme.sectionGap,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Featured Tournaments',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ).animate().fadeIn(delay: 200.ms).moveX(begin: -20, end: 0),
                const SizedBox(height: 24),
                if (tournamentViewModel.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (tournaments.isEmpty)
                  _buildEmptyTournaments()
                else
                  AuraResponsiveGrid(
                    mobileCount: 1,
                    tabletCount: 2,
                    desktopCount: 3,
                    children: tournaments
                        .map((t) => _buildTournamentCard(context, t))
                        .toList(),
                  ).animate().fadeIn(delay: 400.ms).moveY(begin: 30, end: 0),

                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.military_tech_outlined,
                        color: AppTheme.textMuted.withValues(alpha: 0.3),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'More tournaments coming soon...',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTournaments() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            color: AppTheme.textMuted.withValues(alpha: 0.3),
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No tournaments available right now.',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthViewModel>().signOut();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.accentCoral),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentCard(BuildContext context, Tournament tournament) {
    Color statusColor;
    switch (tournament.status.toUpperCase()) {
      case 'OPEN':
        statusColor = Colors.green;
        break;
      case 'UPCOMING':
        statusColor = AppTheme.primaryIndigo;
        break;
      case 'CLOSED':
        statusColor = Colors.redAccent;
        break;
      default:
        statusColor = AppTheme.textMuted;
    }

    return AuraCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              bottom: -40,
              child: Icon(
                Icons.emoji_events_rounded,
                size: 160,
                color: statusColor.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.auraPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tournament.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.more_horiz_rounded,
                        color: AppTheme.textMuted,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    tournament.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tournament.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TournamentRegistrationView(
                              tournament: tournament,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: statusColor,
                        shadowColor: statusColor.withOpacity(0.4),
                        elevation: 8,
                      ),
                      child: const Text(
                        'REGISTER NOW',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
