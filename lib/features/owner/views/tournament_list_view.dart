import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../owner/viewmodels/tournament_viewmodel.dart';
import '../../owner/viewmodels/organizer_viewmodel.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/one_ui_widgets.dart';
import '../../../shared/widgets/aura_widgets.dart';
import 'create_tournament_view.dart';

class TournamentListView extends StatefulWidget {
  const TournamentListView({super.key});

  @override
  State<TournamentListView> createState() => _TournamentListViewState();
}

class _TournamentListViewState extends State<TournamentListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  final List<String> _filters = ['All', 'Upcoming', 'Ongoing', 'Completed'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TournamentViewModel>();
    final filteredTournaments = viewModel.tournaments.where((t) {
      final matchesSearch =
          t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.location.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _statusFilter == 'All' ||
          t.status.toUpperCase() == _statusFilter.toUpperCase();
      return matchesSearch && matchesStatus;
    }).toList();

    return CustomScrollView(
      slivers: [
        AuraHeader(
          title: 'Tournaments',
          subtitle: 'Manage and track all competitions',
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.tune, color: AppTheme.primaryIndigo),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: OneUIResponsivePadding(
              child: OneUISearchBar(
                controller: _searchController,
                hintText: 'Search tournaments, venues...',
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STATUS FILTER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _statusFilter == filter;
                      final count = filter == 'All'
                          ? viewModel.tournaments.length
                          : viewModel.tournaments
                                .where(
                                  (t) =>
                                      t.status.toUpperCase() ==
                                      filter.toUpperCase(),
                                )
                                .length;

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => setState(() => _statusFilter = filter),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: 300.ms,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryIndigo
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryIndigo
                                    : AppTheme.borderSoft,
                              ),
                              boxShadow: isSelected
                                  ? AppTheme.softShadow
                                  : null,
                            ),
                            child: Row(
                              children: [
                                if (isSelected)
                                  const Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.white,
                                  ).animate().scale(),
                                if (isSelected) const SizedBox(width: 8),
                                Text(
                                  '$filter',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textMuted,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '($count)',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.7)
                                        : AppTheme.textMuted.withOpacity(0.5),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (viewModel.isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (filteredTournaments.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryIndigo.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event_note_outlined,
                      size: 64,
                      color: AppTheme.primaryIndigo.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No Tournaments Yet'
                        : 'No relevant matches found',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Create your first tournament to start management.'
                        : 'Try adjusting your search or filters.',
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final tournament = filteredTournaments[index];
                return _buildTournamentCard(context, tournament, index);
              }, childCount: filteredTournaments.length),
            ),
          ),
        // Add some bottom padding for the FAB
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildTournamentCard(
    BuildContext context,
    Tournament tournament,
    int index,
  ) {
    final organizers = context.read<OrganizerViewModel>().organizers;
    final assignedOrganizer = organizers.cast<AppUser?>().firstWhere(
      (o) => o?.uid == tournament.organizerId,
      orElse: () => null,
    );

    return AuraCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Sport Icon & Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigo.withOpacity(0.03),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusLG),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Icon(
                    _getSportIcon(tournament.sportType),
                    color: AppTheme.primaryIndigo,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        '${tournament.sportType} · ${_getFormatText(tournament)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(tournament.status),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCardSectionHeader(
                  icon: Icons.person_outline,
                  title: 'ORGANIZER',
                ),
                _buildInfoRow(
                  'Assigned to',
                  assignedOrganizer?.name ?? 'Not Assigned',
                  isBold: true,
                  trailing: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: assignedOrganizer != null
                          ? AppTheme.successGreen
                          : AppTheme.warningAmber,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                if (assignedOrganizer == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            _showAssignOrganizerDialog(context, tournament),
                        icon: const Icon(Icons.person_add_alt_1, size: 16),
                        label: const Text(
                          'Assign Organizer',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryIndigo,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          backgroundColor: AppTheme.primaryIndigo.withOpacity(
                            0.05,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 0.5),
                ),

                _buildCardSectionHeader(
                  icon: Icons.analytics_outlined,
                  title: 'FINANCIAL OVERVIEW',
                ),
                _buildInfoRow(
                  'Total Revenue',
                  '₹1.0',
                  valueColor: AppTheme.successGreen,
                  isBold: true,
                ),
                _buildInfoRow('Organizer Earnings', '₹1.0', isSubtle: false),
                _buildInfoRow('Platform Fee', '₹0.0', isSubtle: true),
              ],
            ),
          ),

          // Action Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildFooterButton(
                    icon: Icons.edit,
                    label: 'Edit',
                    color: AppTheme.primaryIndigo,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFooterButton(
                    icon: Icons.description_outlined,
                    label: 'Export',
                    color: Colors.green,
                    onPressed: () {},
                    isOutline: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFooterButton(
                    icon: Icons.delete,
                    label: 'Delete',
                    color: Colors.red,
                    onPressed: () {},
                    isOutline: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildCardSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryIndigo),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryIndigo,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    bool isSubtle = false,
    Color? valueColor,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (trailing != null) ...[trailing, const SizedBox(width: 8)],
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                      color:
                          valueColor ??
                          (isSubtle ? AppTheme.textMuted : AppTheme.textDark),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isOutline = false,
  }) {
    return isOutline
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 16),
            label: Text(label, style: const TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 16),
            label: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'ONGOING':
        color = AppTheme.successGreen;
        break;
      case 'UPCOMING':
        color = AppTheme.secondarySky;
        break;
      case 'COMPLETED':
        color = AppTheme.textMuted;
        break;
      default:
        color = AppTheme.primaryIndigo;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket_rounded;
      case 'football':
        return Icons.sports_soccer_rounded;
      case 'kabaddi':
        return Icons.sports_kabaddi_rounded;
      case 'badminton':
        return Icons.sports_tennis_rounded;
      case 'volleyball':
        return Icons.sports_volleyball_rounded;
      case 'basketball':
        return Icons.sports_basketball_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  String _getFormatText(Tournament t) {
    String type = 'Normal';
    if (t.type == TournamentType.teamBased) type = 'Team';
    if (t.type == TournamentType.auctionBased) type = 'Auction';

    String entry = 'Solo';
    if (t.entryFormat == EntryFormat.duo) entry = 'Duo';
    if (t.entryFormat == EntryFormat.team) entry = 'Team';

    return '$type ($entry)';
  }

  void _showAssignOrganizerDialog(BuildContext context, Tournament tournament) {
    // Implementation for organizer assignment
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Organizer'),
        content: const Text('Searching for available organizers...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
