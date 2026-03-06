import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/one_ui_widgets.dart';
import 'player_profile_view.dart';
import 'tournament_registration_view.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
      body: OneUIResponsivePadding(
        child: IndexedStack(index: _currentIndex, children: _views),
      ),
      bottomNavigationBar: NavigationBar(
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= AppTheme.mobileBreakpoint;

    return CustomScrollView(
      slivers: [
        OneUISliverHeader(
          title:
              'Hello, ${authViewModel.user?.name?.split(' ').first ?? 'Player'}',
          subtitle: 'Ready for your next tournament?',
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
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
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.sectionSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Featured Tournaments',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),

                // Adaptive Grid for Tournament Cards
                GridView.count(
                  crossAxisCount: screenWidth > 900
                      ? 3
                      : (screenWidth > 600 ? 2 : 1),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: isWide ? 1.4 : 1.2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Mock Card 1
                    _buildTournamentCard(
                      context,
                      'National Turf Championship 2024',
                      'Join the biggest turf event of the season. 5v5 format.',
                      'UPCOMING',
                      AppTheme.tertiaryAmber,
                    ),
                    // Mock Card 2
                    _buildTournamentCard(
                      context,
                      'Elite Summer League',
                      'Compete with the best teams in the city. Prize pool ₹50k.',
                      'OPEN',
                      Colors.green,
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).moveY(begin: 20, end: 0),

                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.sports_soccer_outlined,
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

  Widget _buildTournamentCard(
    BuildContext context,
    String name,
    String description,
    String status,
    Color statusColor,
  ) {
    return OneUICard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.emoji_events_outlined,
              size: 120,
              color: statusColor.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.share_outlined,
                      size: 18,
                      color: AppTheme.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    description,
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TournamentRegistrationView(tournamentName: name),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shadowColor: statusColor.withValues(alpha: 0.3),
                    ),
                    child: const Text(
                      'REGISTER NOW',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
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
}
