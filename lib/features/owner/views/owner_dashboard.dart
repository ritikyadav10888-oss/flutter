import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/aura_widgets.dart';
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
      backgroundColor: AppTheme.backgroundAura,
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
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
            icon: Icon(Icons.assignment_ind_outlined),
            selectedIcon: Icon(Icons.assignment_ind_rounded),
            label: 'Organizers',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events_rounded),
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
    return CustomScrollView(
      slivers: [
        AuraHeader(
          title: 'Welcome Back',
          subtitle: authViewModel.user?.name ?? 'Owner',
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppTheme.accentCoral,
                ),
                onPressed: () => authViewModel.signOut(),
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
                // Stats Grid
                AuraResponsiveGrid(
                  mobileCount: 2,
                  tabletCount: 2,
                  desktopCount: 4,
                  children: [
                    AuraStatsCard(
                      label: 'Organizers',
                      value: '12',
                      icon: Icons.assignment_ind_rounded,
                      accentColor: AppTheme.primaryIndigo,
                    ),
                    AuraStatsCard(
                      label: 'Tournaments',
                      value: '5',
                      icon: Icons.emoji_events_rounded,
                      accentColor: AppTheme.secondarySky,
                    ),
                    AuraStatsCard(
                      label: 'Players',
                      value: '128',
                      icon: Icons.people_rounded,
                      accentColor: AppTheme.successGreen,
                    ),
                    AuraStatsCard(
                      label: 'Revenue',
                      value: '₹45k',
                      icon: Icons.payments_rounded,
                      accentColor: AppTheme.warningAmber,
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).moveY(begin: 30, end: 0),

                const SizedBox(height: 48),

                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ).animate().fadeIn(delay: 400.ms).moveX(begin: -20, end: 0),

                const SizedBox(height: 24),

                // Quick Actions via Aura Tiles
                Column(
                  children: [
                    _buildActionItem(
                      context,
                      'Manage Organizers',
                      'View and approve organizer accounts',
                      Icons.assignment_ind_rounded,
                      () => setState(() => _selectedIndex = 1),
                    ),
                    const SizedBox(height: 12),
                    _buildActionItem(
                      context,
                      'Tournament Schedule',
                      'Check upcoming and live matches',
                      Icons.emoji_events_rounded,
                      () => setState(() => _selectedIndex = 2),
                    ),
                    const SizedBox(height: 12),
                    _buildActionItem(
                      context,
                      'Player Database',
                      'Search through registered players',
                      Icons.people_alt_rounded,
                      () => setState(() => _selectedIndex = 3),
                    ),
                    const SizedBox(height: 12),
                    _buildActionItem(
                      context,
                      'Financial Reports',
                      'View payouts and revenue history',
                      Icons.account_balance_wallet_rounded,
                      () => setState(() => _selectedIndex = 4),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms).moveY(begin: 30, end: 0),

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
    return AuraCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryIndigo.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppTheme.primaryIndigo, size: 24),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppTheme.textMuted,
        ),
      ),
    );
  }
} // End of _OwnerDashboardState
