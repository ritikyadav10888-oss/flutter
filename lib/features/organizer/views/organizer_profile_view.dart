import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';

class OrganizerProfileView extends StatelessWidget {
  const OrganizerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    // roles list check is used to define layout/logic if needed here

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(title: const Text('My Profile'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 32),
            _buildInfoSection(context, 'Personal Details', [
              _buildInfoRow('Email', user.email),
              _buildInfoRow('Phone', user.phoneNumber ?? 'Not provided'),
              _buildInfoRow('Address', user.address ?? 'Not provided'),
            ]),
            const SizedBox(height: 24),
            _buildInfoSection(context, 'Identity Documents', [
              _buildInfoRow(
                'Aadhar Number',
                user.aadharNumber ?? 'Not provided',
              ),
              if (user.aadharPic != null)
                _buildDocumentLink(
                  context,
                  'View Aadhar Image',
                  user.aadharPic!,
                ),
              _buildInfoRow('PAN Number', user.panNumber ?? 'Not provided'),
              if (user.panPic != null)
                _buildDocumentLink(context, 'View PAN Image', user.panPic!),
            ]),
            const SizedBox(height: 24),
            _buildInfoSection(context, 'Bank Information', [
              _buildInfoRow('Bank Name', user.bankName ?? 'Not provided'),
              _buildInfoRow(
                'Account Number',
                user.accountNumber ?? 'Not provided',
              ),
              _buildInfoRow('IFSC Code', user.ifscCode ?? 'Not provided'),
            ]),
            const SizedBox(height: 24),
            _buildInfoSection(context, 'Access Details', [
              _buildInfoRow('Duration', user.accessDuration ?? 'Not set'),
              _buildInfoRow(
                'Created On',
                user.createdAt.toString().split(' ').first,
              ),
            ]),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Only the Owner can update these details.',
                style: TextStyle(
                  color: Colors.redAccent.withOpacity(0.7),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppUser user) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryIndigo.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              size: 50,
              color: AppTheme.primaryIndigo,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Club Organizer',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.primaryIndigo,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentLink(BuildContext context, String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          // Open URL logic
        },
        child: Row(
          children: [
            const Icon(Icons.image, size: 16, color: AppTheme.primaryIndigo),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.primaryIndigo,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.open_in_new,
              size: 14,
              color: AppTheme.primaryIndigo,
            ),
          ],
        ),
      ),
    );
  }
}
