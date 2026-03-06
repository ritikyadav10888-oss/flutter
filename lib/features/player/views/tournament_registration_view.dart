import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/models/models.dart';

class TournamentRegistrationView extends StatefulWidget {
  final String tournamentName;

  const TournamentRegistrationView({super.key, required this.tournamentName});

  @override
  State<TournamentRegistrationView> createState() =>
      _TournamentRegistrationViewState();
}

class _TournamentRegistrationViewState
    extends State<TournamentRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;

    if (user == null) return const Center(child: Text("Please log in."));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Register for Tournament'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        titleTextStyle: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(color: AppTheme.backgroundWhite),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tournament Banner
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 48,
                                color: AppTheme.primaryIndigo,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.tournamentName,
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(
                                      color: AppTheme.textDark,
                                      fontSize: 24,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Player Registration',
                                style: TextStyle(color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ).animate().fadeIn().scale(),

                        const SizedBox(height: 32),

                        const Text(
                          'PERSONAL INFORMATION (Pre-filled from Profile)',
                          style: TextStyle(
                            color: AppTheme.primaryIndigo,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ).animate().fadeIn(delay: 200.ms),

                        const SizedBox(height: 16),

                        _buildInfoCard(user),

                        const SizedBox(height: 32),

                        // Confirmation Form
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Confirmation',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'By clicking register, you confirm that the profile information above is accurate and you agree to the tournament rules.',
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _isSubmitting ? null : _register,
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('CONFIRM REGISTRATION'),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 20, end: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(AppUser user) {
    final player = user is Player ? user : null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          _buildDetailRow(Icons.person, 'Full Name', user.name),
          const Divider(height: 24, color: Colors.black12),
          _buildDetailRow(Icons.phone, 'Phone', user.phoneNumber ?? 'N/A'),
          const Divider(height: 24, color: Colors.black12),
          _buildDetailRow(
            Icons.person_outline,
            'Gender',
            player?.gender ?? 'N/A',
          ),
          const Divider(height: 24, color: Colors.black12),
          _buildDetailRow(Icons.cake, 'Age', player?.age?.toString() ?? 'N/A'),
          const Divider(height: 24, color: Colors.black12),
          _buildDetailRow(
            Icons.sports_soccer,
            'Position',
            player?.playingPosition ?? 'N/A',
          ),
          const Divider(height: 24, color: Colors.black12),
          _buildDetailRow(
            Icons.credit_card,
            'Aadhar',
            user.aadharNumber ?? 'N/A',
          ),
          const Divider(height: 24, color: Colors.white10),
          _buildDetailRow(
            Icons.medical_services,
            'Health Issues',
            player?.hasHealthIssues == true
                ? (player?.healthIssueDetails ?? 'Yes')
                : 'None',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryIndigo),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _register() async {
    setState(() => _isSubmitting = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful!')));
      Navigator.pop(context);
    }
  }
}
