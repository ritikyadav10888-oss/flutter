import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/storage_service.dart';
import '../viewmodels/auth_viewmodel.dart';

class OrganizerProfileFormView extends StatefulWidget {
  final String uid;
  const OrganizerProfileFormView({super.key, required this.uid});

  @override
  State<OrganizerProfileFormView> createState() => _OrganizerProfileFormViewState();
}

class _OrganizerProfileFormViewState extends State<OrganizerProfileFormView> {
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _aadharController = TextEditingController();
  final _panController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accNoController = TextEditingController();
  final _ifscController = TextEditingController();

  Uint8List? _profileBytes;
  String? _profileName;
  Uint8List? _aadharBytes;
  String? _aadharName;
  Uint8List? _panBytes;
  String? _panName;

  final _picker = ImagePicker();
  final _storage = StorageService();

  Future<void> _pick({required int type}) async {
    // 0: Profile, 1: Aadhar, 2: PAN
    final f = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (f == null) return;
    final b = await f.readAsBytes();
    setState(() {
      if (type == 0) {
        _profileBytes = b;
        _profileName = f.name;
      } else if (type == 1) {
        _aadharBytes = b;
        _aadharName = f.name;
      } else if (type == 2) {
        _panBytes = b;
        _panName = f.name;
      }
    });
  }

  void _validateAndSubmit() {
    if (_nameController.text.trim().isEmpty ||
        !_emailController.text.trim().contains('@') ||
        _phoneController.text.trim().length < 10 ||
        _addressController.text.trim().isEmpty ||
        _aadharController.text.replaceAll(' ', '').length != 12 ||
        _aadharBytes == null ||
        _panController.text.trim().isEmpty ||
        _panBytes == null ||
        _bankNameController.text.trim().isEmpty ||
        _accNoController.text.trim().isEmpty ||
        _ifscController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields and upload documents.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _submit();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      String? profileUrl;
      if (_profileBytes != null) {
        profileUrl = await _storage.uploadProfilePicture(
          widget.uid,
          _profileBytes!,
          _profileName!,
        );
      }
      String? aadharUrl;
      if (_aadharBytes != null) {
        aadharUrl = await _storage.uploadAadharPicture(
          widget.uid,
          _aadharBytes!,
          _aadharName!,
        );
      }
      String? panUrl;
      if (_panBytes != null) {
        panUrl = await _storage.uploadPanPicture(
          widget.uid,
          _panBytes!,
          _panName!,
        );
      }

      if (!mounted) return;

      final success = await context.read<AuthViewModel>().updateProfile({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'aadharNumber': _aadharController.text.trim(),
        'panNumber': _panController.text.trim(),
        'bankName': _bankNameController.text.trim(),
        'accountNumber': _accNoController.text.trim(),
        'ifscCode': _ifscController.text.trim(),
        'profilePic': profileUrl,
        'aadharPic': aadharUrl,
        'panPic': panUrl,
        'isProfileComplete': true,
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Organizer profile completed successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final u = context.read<AuthViewModel>().user;
      if (u != null) {
        if (_nameController.text.isEmpty && u.name.isNotEmpty)
          _nameController.text = u.name;
        if (_emailController.text.isEmpty && u.email.isNotEmpty)
          _emailController.text = u.email;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Complete Organizer Profile',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthViewModel>().signOut(),
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF4F46E5)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            _buildProfilePicker(),
            const SizedBox(height: 32),
            const Text(
              'Business Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildField(_nameController, 'Full Name', Icons.person_outline),
            const SizedBox(height: 16),
            _buildField(_emailController, 'Business Email', Icons.mail_outline, type: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildField(_phoneController, 'Phone Number', Icons.phone_android, type: TextInputType.phone),
            const SizedBox(height: 16),
            _buildField(_addressController, 'Club/Business Address', Icons.location_on_outlined, lines: 2),
            const SizedBox(height: 32),
            const Text(
              'Identity Documents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildField(_aadharController, 'Aadhar Number', Icons.badge_outlined, type: TextInputType.number),
            const SizedBox(height: 12),
            _buildDocPicker(label: 'Upload Aadhar Card', hasFile: _aadharBytes != null, onTap: () => _pick(type: 1)),
            const SizedBox(height: 20),
            _buildField(_panController, 'PAN Card Number', Icons.credit_card_outlined),
            const SizedBox(height: 12),
            _buildDocPicker(label: 'Upload PAN Card', hasFile: _panBytes != null, onTap: () => _pick(type: 2)),
            const SizedBox(height: 32),
            const Text(
              'Banking Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildField(_bankNameController, 'Bank Name', Icons.account_balance_outlined),
            const SizedBox(height: 16),
            _buildField(_accNoController, 'Account Number', Icons.numbers),
            const SizedBox(height: 16),
            _buildField(_ifscController, 'IFSC Code', Icons.qr_code_scanner_outlined),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isLoading ? null : _validateAndSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('COMPLETE REGISTRATION', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicker() {
    return Center(
      child: GestureDetector(
        onTap: () => _pick(type: 0),
        child: CircleAvatar(
          radius: 60,
          backgroundColor: const Color(0xFFF1F5F9),
          backgroundImage: _profileBytes != null ? MemoryImage(_profileBytes!) : null,
          child: _profileBytes == null ? const Icon(Icons.camera_alt_outlined, size: 40, color: Color(0xFF4F46E5)) : null,
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {TextInputType type = TextInputType.text, int lines = 1}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      maxLines: lines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4F46E5), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDocPicker({required String label, required bool hasFile, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasFile ? Colors.green.withOpacity(0.05) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hasFile ? Colors.green : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(hasFile ? Icons.check_circle : Icons.upload_file, color: hasFile ? Colors.green : const Color(0xFF4F46E5)),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: hasFile ? Colors.green : Colors.black87)),
            const Spacer(),
            if (hasFile) const Text('Uploaded', style: TextStyle(fontSize: 12, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
