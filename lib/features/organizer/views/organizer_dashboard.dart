import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/one_ui_widgets.dart';
import 'organizer_profile_view.dart';
import 'organizer_tournament_detail_view.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  // ── Mock tournament data ─────────────────────────────────────────────
  final List<Map<String, dynamic>> _mockTournaments = [
    {
      'id': 't1',
      'name': 'Summer Elite Cup 2026',
      'date': DateTime.now().add(const Duration(days: 14)),
      'location': 'City Stadium, Downtown',
      'status': 'OPEN',
      'playersCount': 42,
    },
    {
      'id': 't2',
      'name': 'Weekend Warriors League',
      'date': DateTime.now().add(const Duration(days: 3)),
      'location': 'Northside Sports Complex',
      'status': 'OPEN',
      'playersCount': 120,
    },
    {
      'id': 't3',
      'name': 'Spring Amateur Open',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'location': 'East Green Park',
      'status': 'CLOSED',
      'playersCount': 64,
    },
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
      body: OneUIResponsivePadding(
        child: IndexedStack(index: _selectedIndex, children: tabs),
      ),
      bottomNavigationBar: NavigationBar(
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > AppTheme.mobileBreakpoint;

    return CustomScrollView(
      slivers: [
        OneUISliverHeader(
          title:
              'Morning, ${authViewModel.user?.name?.split(' ').first ?? 'Organizer'}',
          subtitle: 'You have 2 tournaments today',
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.sectionSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: screenWidth > 900 ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWeb ? 1.5 : 1.1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard(
                      context,
                      'Active',
                      '2',
                      Icons.emoji_events,
                      AppTheme.primaryIndigo,
                    ).animate().fadeIn(delay: 100.ms).scale(),
                    _buildStatCard(
                      context,
                      'Players',
                      '162',
                      Icons.people,
                      AppTheme.secondaryBlue,
                    ).animate().fadeIn(delay: 200.ms).scale(),
                    _buildStatCard(
                      context,
                      'Pending',
                      '14',
                      Icons.pending_actions,
                      Colors.orange,
                    ).animate().fadeIn(delay: 300.ms).scale(),
                    _buildStatCard(
                      context,
                      'Done',
                      '5',
                      Icons.check_circle,
                      Colors.green,
                    ).animate().fadeIn(delay: 400.ms).scale(),
                  ],
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Tournaments',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(onPressed: () {}, child: const Text('View All')),
                  ],
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 16),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _mockTournaments.length,
                  itemBuilder: (context, index) {
                    final t = _mockTournaments[index];
                    final delay = (600 + (index * 100)).ms;
                    return _buildTournamentCard(
                      context,
                      t,
                    ).animate().fadeIn(delay: delay).moveY(begin: 20, end: 0);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildTournamentCard(
    BuildContext context,
    Map<String, dynamic> tournament,
  ) {
    final status = tournament['status'] as String;
    final isOpen = status == 'OPEN';

    return OneUICard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OrganizerTournamentDetailView(tournament: tournament),
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    color: AppTheme.primaryIndigo,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        tournament['location'],
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isOpen ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 16,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${tournament['playersCount']} registered',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  ME TAB
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildMeTab(BuildContext context, AuthViewModel authViewModel) {
    return CustomScrollView(
      slivers: [
        const OneUISliverHeader(
          title: 'My Profile',
          subtitle: 'Manage your account and settings',
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.sectionSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OneUICard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrganizerProfileView(),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryIndigo.withOpacity(
                          0.1,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppTheme.primaryIndigo,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authViewModel.user?.name ?? 'Organizer',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              authViewModel.user?.email ?? '',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OneUISection(
                  title: 'Settings',
                  showSeparator: true,
                  children: [
                    _buildSettingsTile(
                      context,
                      'Notifications',
                      Icons.notifications_none_outlined,
                    ),
                    _buildSettingsTile(
                      context,
                      'Privacy & Security',
                      Icons.security_outlined,
                    ),
                    _buildSettingsTile(
                      context,
                      'Help & Support',
                      Icons.help_outline,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => authViewModel.signOut(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.08),
                      foregroundColor: Colors.red,
                      elevation: 0,
                      side: BorderSide(
                        color: Colors.red.withValues(alpha: 0.2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
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
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryIndigo.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: AppTheme.primaryIndigo),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 18,
        color: AppTheme.textMuted,
      ),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$title coming soon!')));
      },
    );
  }
}
