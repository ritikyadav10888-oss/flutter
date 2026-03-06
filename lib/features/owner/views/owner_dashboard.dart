import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/one_ui_widgets.dart';
import 'organizer_list_view.dart';
import 'tournament_list_view.dart';
import 'player_list_view.dart';
import 'payout_list_view.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    final List<Widget> _tabs = [
      _buildHomeTab(context, authViewModel),
      const OrganizerListView(),
      const TournamentListView(),
      const PlayerListView(),
      const PayoutListView(),
    ];

    return Scaffold(
      body: OneUIResponsivePadding(
        child: IndexedStack(index: _selectedIndex, children: _tabs),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_work_outlined),
            selectedIcon: Icon(Icons.group_work),
            label: 'Organizers',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_soccer_outlined),
            selectedIcon: Icon(Icons.sports_soccer),
            label: 'Tournaments',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Players',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'Payouts',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, AuthViewModel authViewModel) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > AppTheme.mobileBreakpoint;

    return CustomScrollView(
      slivers: [
        OneUISliverHeader(
          title: 'Welcome Back',
          subtitle: authViewModel.user?.name ?? 'Owner',
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authViewModel.signOut(),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.sectionSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Grid
                GridView.count(
                  crossAxisCount: screenWidth > 900
                      ? 4
                      : (screenWidth > 600 ? 2 : 2),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWeb ? 1.5 : 1.1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard(
                      context,
                      'Total Organizers',
                      '12',
                      Icons.group_work,
                      AppTheme.primaryIndigo,
                    ),
                    _buildStatCard(
                      context,
                      'Active Tournaments',
                      '5',
                      Icons.sports_soccer,
                      AppTheme.secondaryBlue,
                    ),
                    _buildStatCard(
                      context,
                      'Total Players',
                      '128',
                      Icons.people,
                      Colors.green,
                    ),
                    _buildStatCard(
                      context,
                      'Total Revenue',
                      '₹45k',
                      Icons.payments,
                      Colors.purple,
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),

                const SizedBox(height: 40),

                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 16),

                // Quick Actions in a One UI Section
                OneUISection(
                  showSeparator: true,
                  children: [
                    _buildActionItem(
                      context,
                      'Manage Organizers',
                      'View and approve organizer accounts',
                      Icons.group_work,
                      () => setState(() => _selectedIndex = 1),
                    ),
                    _buildActionItem(
                      context,
                      'Tournament Schedule',
                      'Check upcoming and live matches',
                      Icons.emoji_events,
                      () => setState(() => _selectedIndex = 2),
                    ),
                    _buildActionItem(
                      context,
                      'Player Database',
                      'Search through registered players',
                      Icons.people,
                      () => setState(() => _selectedIndex = 3),
                    ),
                    _buildActionItem(
                      context,
                      'Financial Reports',
                      'View payouts and revenue history',
                      Icons.payments,
                      () => setState(() => _selectedIndex = 4),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms).moveY(begin: 20, end: 0),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryIndigo.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: AppTheme.primaryIndigo, size: 22),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chevron_right,
          size: 16,
          color: AppTheme.textMuted,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return OneUICard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Background accent
          Positioned(
            right: -20,
            top: -20,
            child: Icon(icon, size: 100, color: color.withValues(alpha: 0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Subtle indicator bar at bottom
          Positioned(
            bottom: 0,
            left: 20,
            right: 20,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
