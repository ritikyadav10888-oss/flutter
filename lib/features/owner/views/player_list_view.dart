import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/one_ui_widgets.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/aura_widgets.dart';
import 'player_details_view.dart';

class PlayerListView extends StatefulWidget {
  const PlayerListView({super.key});

  @override
  State<PlayerListView> createState() => _PlayerListViewState();
}

class _PlayerListViewState extends State<PlayerListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: FutureBuilder<List<AppUser>>(
        future: AuthService().getPlayers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allPlayers = snapshot.data ?? [];

          final filteredPlayers = allPlayers.where((p) {
            return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.email.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return CustomScrollView(
            slivers: [
              const AuraHeader(
                title: 'Players',
                subtitle: 'Registry of all participants',
              ),
              SliverToBoxAdapter(
                child: OneUISearchBar(
                  controller: _searchController,
                  hintText: 'Search players by name or email...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              if (filteredPlayers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppTheme.textMuted.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No players found'
                              : 'No players matching "$_searchQuery"',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final player = filteredPlayers[index];
                      return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                ),
                              ),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PlayerDetailsView(player: player),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primaryIndigo
                                      .withValues(alpha: 0.1),
                                  backgroundImage: player.profilePic != null
                                      ? NetworkImage(player.profilePic!)
                                      : null,
                                  child: player.profilePic == null
                                      ? Text(
                                          player.name[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: AppTheme.primaryIndigo,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                title: Text(
                                  player.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(player.email),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: player.isProfileComplete
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    player.isProfileComplete
                                        ? 'Complete'
                                        : 'Incomplete',
                                    style: TextStyle(
                                      color: player.isProfileComplete
                                          ? Colors.green
                                          : Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: (index * 50).ms)
                          .slideX(begin: 0.1, end: 0);
                    }, childCount: filteredPlayers.length),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
