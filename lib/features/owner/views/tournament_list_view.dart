import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:force_player_register_app/features/owner/viewmodels/tournament_viewmodel.dart';
import 'package:force_player_register_app/features/owner/viewmodels/organizer_viewmodel.dart';
import 'package:force_player_register_app/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:force_player_register_app/core/theme/app_theme.dart';
import 'package:force_player_register_app/core/models/models.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/one_ui_widgets.dart';
import 'create_tournament_view.dart';

class TournamentListView extends StatefulWidget {
  const TournamentListView({super.key});

  @override
  State<TournamentListView> createState() => _TournamentListViewState();
}

class _TournamentListViewState extends State<TournamentListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TournamentViewModel>();
    final filteredTournaments = viewModel.tournaments.where((t) {
      return t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.location.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          OneUISearchBar(
            controller: _searchController,
            hintText: 'Search tournaments...',
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTournaments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 64,
                          color: AppTheme.textMuted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No tournaments found. Create one to get started!'
                              : 'No tournaments matching "$_searchQuery"',
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTournaments.length,
                    itemBuilder: (context, index) {
                      final tournament = filteredTournaments[index];
                      return _buildTournamentCard(context, tournament, index);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateTournamentView()),
        ),
        label: const Text('New Tournament'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryIndigo,
      ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Placeholder or Image
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigo.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              image: tournament.bannerUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(tournament.bannerUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: tournament.bannerUrl.isEmpty
                ? const Center(
                    child: Icon(
                      Icons.image,
                      color: AppTheme.primaryIndigo,
                      size: 48,
                    ),
                  )
                : null,
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tournament.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusChip(tournament.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(tournament.date),
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tournament.location,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assigned Organizer',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          assignedOrganizer?.name ?? 'Not Assigned',
                          style: TextStyle(
                            color: assignedOrganizer != null
                                ? AppTheme.textDark
                                : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.person_add_alt_1, size: 20),
                          onPressed: () =>
                              _showAssignOrganizerDialog(context, tournament),
                          tooltip: 'Assign Organizer',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreateTournamentView(),
                              ),
                            );
                          },
                          tooltip: 'Edit Tournament',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'OPEN':
        color = Colors.green;
        break;
      case 'CLOSED':
        color = Colors.redAccent;
        break;
      default:
        color = AppTheme.textMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAssignOrganizerDialog(BuildContext context, Tournament tournament) {
    final viewModel = context.read<OrganizerViewModel>();
    final tournamentViewModel = context.read<TournamentViewModel>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign Organizer'),
          content: viewModel.organizers.isEmpty
              ? const Text('No organizers available. Create one first.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: viewModel.organizers.length,
                    itemBuilder: (context, index) {
                      final organizer = viewModel.organizers[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(organizer.name),
                        subtitle: Text(organizer.email),
                        onTap: () async {
                          final success = await tournamentViewModel
                              .assignOrganizer(tournament.id, organizer.uid);
                          if (success) {
                            Navigator.pop(context);
                          }
                        },
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
