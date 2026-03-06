import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:force_player_register_app/features/owner/viewmodels/organizer_viewmodel.dart';
import 'package:force_player_register_app/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:force_player_register_app/core/theme/app_theme.dart';
import 'package:force_player_register_app/shared/widgets/one_ui_widgets.dart';
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
      body: OneUIResponsivePadding(
        child: Column(
          children: [
            OneUISearchBar(
              controller: _searchController,
              hintText: 'Search organizers...',
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredOrganizers.isEmpty
                  ? Center(
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
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.sectionSpacing),
                      itemCount: filteredOrganizers.length,
                      itemBuilder: (context, index) {
                        final organizer = filteredOrganizers[index];
                        return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: OneUICard(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OrganizerDetailsView(
                                      organizer: organizer,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.primaryIndigo
                                        .withValues(alpha: 0.1),
                                    child: const Icon(
                                      Icons.person,
                                      color: AppTheme.primaryIndigo,
                                    ),
                                  ),
                                  title: Text(
                                    organizer.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(organizer.email),
                                  trailing: const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: (index * 50).ms)
                            .slideX(begin: 20, end: 0);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateOrganizerView()),
        ),
        label: const Text('Add Organizer'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryIndigo,
      ),
    );
  }
}
