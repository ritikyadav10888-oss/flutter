import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';
import 'create_organizer_view.dart';

class OrganizerDetailsView extends StatelessWidget {
  final AppUser organizer;

  const OrganizerDetailsView({super.key, required this.organizer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Organizer Profile'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateOrganizerView(organizer: organizer),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSectionCard(
              title: 'Personal Details',
              icon: Icons.person_outline,
              children: [
                _buildDetailRow(Icons.email_outlined, 'Email', organizer.email),
                _buildDetailRow(
                  Icons.phone_outlined,
                  'Phone',
                  organizer.phoneNumber ?? 'Not provided',
                ),
                _buildDetailRow(
                  Icons.location_on_outlined,
                  'Address',
                  organizer.address ?? 'Not provided',
                  isLong: true,
                ),
                _buildDetailRow(
                  Icons.credit_card_outlined,
                  'Aadhar',
                  organizer.aadharNumber ?? 'Not provided',
                ),
                _buildDetailRow(
                  Icons.badge_outlined,
                  'PAN',
                  organizer.panNumber ?? 'Not provided',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Bank Information',
              icon: Icons.account_balance_outlined,
              children: [
                _buildDetailRow(
                  Icons.account_balance_outlined,
                  'Bank Name',
                  organizer.bankName ?? 'Not provided',
                ),
                _buildDetailRow(
                  Icons.numbers_outlined,
                  'Account Number',
                  organizer.accountNumber ?? 'Not provided',
                ),
                _buildDetailRow(
                  Icons.qr_code_outlined,
                  'IFSC Code',
                  organizer.ifscCode ?? 'Not provided',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Access & Validity',
              icon: Icons.access_time_outlined,
              children: [
                _buildDetailRow(
                  Icons.calendar_today_outlined,
                  'Access Duration',
                  organizer.accessDuration ?? 'Not set',
                ),
                _buildDetailRow(
                  Icons.history_outlined,
                  'Created On',
                  organizer.createdAt.toString().split(' ').first,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (organizer.aadharPic != null || organizer.panPic != null)
              _buildSectionCard(
                title: 'Documents',
                icon: Icons.file_copy_outlined,
                children: [
                  if (organizer.aadharPic != null)
                    _buildDocumentItem('Aadhar Card', organizer.aadharPic!),
                  if (organizer.panPic != null)
                    _buildDocumentItem('PAN Card', organizer.panPic!),
                ],
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          backgroundImage: organizer.profilePic != null
              ? NetworkImage(organizer.profilePic!)
              : null,
          child: organizer.profilePic == null
              ? const Icon(Icons.person, size: 50, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          organizer.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF322942),
          ),
        ),
        const Text(
          'Registered Organizer',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6750A4), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF322942),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isLong = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: isLong
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF322942),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String title, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.image_outlined,
                color: Color(0xFF6750A4),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              // Full screen image viewer could be added here
            },
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                image: DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
