import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:force_player_register_app/features/owner/viewmodels/organizer_viewmodel.dart';
import 'package:force_player_register_app/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:force_player_register_app/core/theme/app_theme.dart';
import 'package:force_player_register_app/core/models/models.dart';
import 'package:force_player_register_app/shared/widgets/one_ui_widgets.dart';
import 'package:force_player_register_app/shared/widgets/aura_widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'create_organizer_view.dart';
import 'organizer_details_view.dart';

class OrganizerListView extends StatefulWidget {
  const OrganizerListView({super.key});

  @override
  State<OrganizerListView> createState() => _OrganizerListViewState();
}

class _OrganizerListViewState extends State<OrganizerListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ownerId = context.read<AuthViewModel>().user?.uid;
      if (ownerId != null) {
        context.read<OrganizerViewModel>().startListening(ownerId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrganizerViewModel>();
    final filteredOrganizers = viewModel.organizers.where((o) {
      return o.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: AuraSimpleHeader(title: 'Organizers'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OneUISearchBar(
                controller: _searchController,
                hintText: 'Search Organizers',
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),
          if (viewModel.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (filteredOrganizers.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_disabled,
                      size: 64,
                      color: AppTheme.textMuted.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No organizers found. Add one to get started!'
                          : 'No organizers matching "$_searchQuery"',
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
                  final organizer = filteredOrganizers[index];
                  return _buildOrganizerCard(context, organizer, index);
                }, childCount: filteredOrganizers.length),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateOrganizerView()),
        ),
        label: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryIndigo,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildOrganizerCard(
    BuildContext context,
    AppUser organizer,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryIndigo.withValues(
                    alpha: 0.1,
                  ),
                  child: Text(
                    organizer.name[0].toLowerCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryIndigo,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        organizer.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        organizer.email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.visibility_outlined,
                  label: 'Details',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          OrganizerDetailsView(organizer: organizer),
                    ),
                  ),
                ),
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  onPressed: () {
                    // TODO: Implement edit
                  },
                ),
                _buildActionButton(
                  icon: Icons.add,
                  label: 'Assign',
                  onPressed: () {
                    // TODO: Implement assignment
                  },
                ),
                Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      // TODO: Implement delete confirmation
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: AppTheme.primaryIndigo),
      label: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primaryIndigo,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
