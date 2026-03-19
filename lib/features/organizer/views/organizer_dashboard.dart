import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/models/models.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/aura_widgets.dart';
import 'organizer_profile_view.dart';
import 'organizer_tournament_detail_view.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  // ── Mock tournament data ─────────────────────────────────────────────
  final List<Tournament> _mockTournaments = [
    Tournament(
      id: 't1',
      name: 'Summer Elite Cup 2026',
      description: 'Elite summer tournament for veteran players.',
      sportType: 'Cricket',
      type: TournamentType.normal,
      entryFormat: EntryFormat.team,
      playersPerTeam: 11,
      maxTeams: 16,
      date: DateTime.now().add(const Duration(days: 14)),
      location: 'City Stadium, Downtown',
      status: 'OPEN',
      createdBy: 'system',
      entryFee: 500,
      prizePool: 50000,
      rules: ['Standard rules apply'],
      terms: 'Accept all terms',
      bannerUrl: '',
      organizerId: 'org1',
    ),
    Tournament(
      id: 't2',
      name: 'Weekend Warriors League',
      description: 'Casual weekend league.',
      sportType: 'Football',
      type: TournamentType.normal,
      entryFormat: EntryFormat.team,
      playersPerTeam: 7,
      maxTeams: 8,
      date: DateTime.now().add(const Duration(days: 3)),
      location: 'Northside Sports Complex',
      status: 'OPEN',
      createdBy: 'system',
      entryFee: 200,
      prizePool: 10000,
      rules: ['Standard rules apply'],
      terms: 'Accept all terms',
      bannerUrl: '',
      organizerId: 'org1',
    ),
    Tournament(
      id: 't3',
      name: 'Spring Amateur Open',
      description: 'Amateur open for individuals.',
      sportType: 'Badminton',
      type: TournamentType.normal,
      entryFormat: EntryFormat.solo,
      maxParticipants: 32,
      date: DateTime.now().subtract(const Duration(days: 5)),
      location: 'East Green Park',
      status: 'CLOSED',
      createdBy: 'system',
      entryFee: 100,
      prizePool: 5000,
      rules: ['Standard rules apply'],
      terms: 'Accept all terms',
      bannerUrl: '',
      organizerId: 'org1',
    ),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    final List<Widget> tabs = [
      _buildHomeTab(context, authViewModel),
      _buildMeTab(context, authViewModel),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundAura,
      body: IndexedStack(index: _selectedIndex, children: tabs),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  HOME TAB
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildHomeTab(BuildContext context, AuthViewModel authViewModel) {
    return CustomScrollView(
      slivers: [
        AuraHeader(
          title:
              'Morning, ${authViewModel.user?.name.split(' ').first ?? 'Organizer'}',
          subtitle: 'You have 2 tournaments today',
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
                AuraResponsiveGrid(
                  mobileCount: 2,
                  tabletCount: 2,
                  desktopCount: 4,
                  children: [
                    AuraStatsCard(
                      label: 'Active',
                      value: '2',
                      icon: Icons.emoji_events_rounded,
                      accentColor: AppTheme.primaryIndigo,
                    ),
                    AuraStatsCard(
                      label: 'Players',
                      value: '162',
                      icon: Icons.people_rounded,
                      accentColor: AppTheme.secondarySky,
                    ),
                    AuraStatsCard(
                      label: 'Pending',
                      value: '14',
                      icon: Icons.pending_actions_rounded,
                      accentColor: AppTheme.warningAmber,
                    ),
                    AuraStatsCard(
                      label: 'Done',
                      value: '5',
                      icon: Icons.check_circle_rounded,
                      accentColor: AppTheme.successGreen,
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).moveY(begin: 30, end: 0),

                const SizedBox(height: 48),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Tournaments',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: AppTheme.primaryIndigo,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 24),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _mockTournaments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final t = _mockTournaments[index];
                    final delay = (600 + (index * 100)).ms;
                    return _buildTournamentCard(
                      context,
                      t,
                    ).animate().fadeIn(delay: delay).moveY(begin: 30, end: 0);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Removed OneUI stat card helper

  Widget _buildTournamentCard(BuildContext context, Tournament tournament) {
    final status = tournament.status;
    final isOpen = status == 'OPEN';

    return AuraCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OrganizerTournamentDetailView(tournament: tournament),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryIndigo.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.military_tech_rounded,
                      color: AppTheme.primaryIndigo,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tournament.location,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(status, isOpen),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundAura.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppTheme.radiusLG),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.people_alt_rounded,
                        size: 16,
                        color: AppTheme.primaryIndigo,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Active Participants', // Placeholder since playersCount is not in model explicitly or is computed
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isOpen ? AppTheme.successGreen : AppTheme.textMuted)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isOpen ? AppTheme.successGreen : AppTheme.textMuted,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  ME TAB
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildMeTab(BuildContext context, AuthViewModel authViewModel) {
    return CustomScrollView(
      slivers: [
        const AuraHeader(
          title: 'My Profile',
          subtitle: 'Manage your organizer account',
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
                AuraCard(
                  padding: const EdgeInsets.all(20),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OrganizerProfileView(),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryIndigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMD,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppTheme.primaryIndigo,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authViewModel.user?.name ?? 'Organizer',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20,
                                    ),
                              ),
                              Text(
                                authViewModel.user?.email ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: AppTheme.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    _buildSettingsTile(
                      context,
                      'Notifications',
                      Icons.notifications_none_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      context,
                      'Privacy & Security',
                      Icons.security_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      context,
                      'Help & Support',
                      Icons.help_outline_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => authViewModel.signOut(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentCoral.withOpacity(0.1),
                      foregroundColor: AppTheme.accentCoral,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      ),
                    ),
                    child: const Text(
                      'Logout Account',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSettingsTile(BuildContext context, String title, IconData icon) {
    return AuraCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryIndigo.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: AppTheme.primaryIndigo),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppTheme.textMuted,
        ),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$title coming soon!')));
        },
      ),
    );
  }
}
