import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/storage_service.dart';
import '../viewmodels/auth_viewmodel.dart';

class PlayerProfileFormView extends StatefulWidget {
  final String uid;
  const PlayerProfileFormView({super.key, required this.uid});

  @override
  State<PlayerProfileFormView> createState() => _PlayerProfileFormViewState();
}

class _PlayerProfileFormViewState extends State<PlayerProfileFormView> {
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyController = TextEditingController();
  final _aadharController = TextEditingController();
  final _addressController = TextEditingController();
  final _healthController = TextEditingController();

  // State
  DateTime? _dob;
  String? _gender;
  String? _bloodGroup;
  bool _hasHealthIssues = false;

  Uint8List? _profileBytes;
  String? _profileName;
  Uint8List? _aadharBytes;
  String? _aadharName;

  final _picker = ImagePicker();
  final _storage = StorageService();

  Future<void> _pick({required bool isProfile}) async {
    final f = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (f == null) return;
    final b = await f.readAsBytes();
    setState(() {
      if (isProfile) {
        _profileBytes = b;
        _profileName = f.name;
      } else {
        _aadharBytes = b;
        _aadharName = f.name;
      }
    });
  }

  void _validateAndSubmit() {
    if (_nameController.text.trim().isEmpty ||
        !_emailController.text.trim().contains('@') ||
        _phoneController.text.trim().length < 10 ||
        _gender == null ||
        _dob == null ||
        _emergencyController.text.trim().length < 10 ||
        _aadharController.text.replaceAll(' ', '').length != 12 ||
        _aadharBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _submit();
  }

  Future<void> _submit() async {
    if (_hasHealthIssues && _healthController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe your health issues.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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

      if (!mounted) return;

      final success = await context.read<AuthViewModel>().updateProfile({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'gender': _gender,
        'bloodGroup': _bloodGroup,
        'dateOfBirth': _dob,
        'emergencyContactNumber': _emergencyController.text.trim(),
        'aadharNumber': _aadharController.text.trim(),
        'address': _addressController.text.trim(),
        'hasHealthIssues': _hasHealthIssues,
        'healthIssueDetails': _hasHealthIssues
            ? _healthController.text.trim()
            : null,
        'profilePic': profileUrl,
        'aadharPic': aadharUrl,
        'isProfileCompleted': true,
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile completed successfully!'),
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
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _emergencyController.dispose();
    _aadharController.dispose();
    _addressController.dispose();
    _healthController.dispose();
    super.dispose();
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
          'Complete Profile',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.read<AuthViewModel>().signOut(),
            icon: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.w600,
              ),
            ),
            label: const Icon(
              Icons.logout_rounded,
              color: Color(0xFF4F46E5),
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              _buildProfileImagePicker(),
              const SizedBox(height: 12),
              const Text(
                'Force Sports',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'Upload your profile picture',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4F46E5),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                hint: 'Enter your full name',
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.mail_outline,
                type: TextInputType.emailAddress,
                hint: 'example@email.com',
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_android,
                type: TextInputType.phone,
                hint: '+91 00000 00000',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropDownField(
                      label: 'Gender',
                      value: _gender,
                      onTap: () => _showPicker(
                        title: 'Select Gender',
                        options: ['Male', 'Female', 'Other'],
                        onSelect: (v) => setState(() => _gender = v),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropDownField(
                      label: 'Blood Group',
                      value: _bloodGroup,
                      onTap: () => _showPicker(
                        title: 'Select Blood Group',
                        options: [
                          'A+',
                          'A-',
                          'B+',
                          'B-',
                          'AB+',
                          'AB-',
                          'O+',
                          'O-',
                        ],
                        onSelect: (v) => setState(() => _bloodGroup = v),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDropDownField(
                label: 'Date of Birth',
                value: _dob != null
                    ? DateFormat('MM/dd/yyyy').format(_dob!)
                    : null,
                hint: 'mm/dd/yyyy',
                icon: Icons.calendar_today_outlined,
                onTap: _pickDate,
              ),
              const SizedBox(height: 32),

              const Text(
                'Identity & Documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _emergencyController,
                label: 'Emergency Phone',
                icon: Icons.phone_android,
                type: TextInputType.phone,
                hint: 'Emergency contact number',
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _aadharController,
                label: 'Aadhar Number',
                icon: Icons.badge_outlined,
                type: TextInputType.number,
                hint: 'XXXX XXXX XXXX',
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                  _AadharFmt(),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _addressController,
                label: 'Current Address',
                icon: Icons.location_on_outlined,
                hint: 'Enter your full address',
                lines: 2,
              ),
              const SizedBox(height: 16),
              _buildAadharPicker(),
              const SizedBox(height: 32),

              const Text(
                'Health & Emergency',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              _buildToggleRow(
                label: 'Any health issues?',
                value: _hasHealthIssues,
                onChanged: (v) => setState(() => _hasHealthIssues = v),
              ),
              if (_hasHealthIssues) ...[
                const SizedBox(height: 16),
                _buildField(
                  controller: _healthController,
                  label: 'Health Issue Details',
                  icon: Icons.medical_services_outlined,
                  lines: 3,
                ),
              ],
              const SizedBox(height: 40),

              _buildSubmitButton(),
              const SizedBox(height: 24),
              _buildFooter(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _pick(isProfile: true),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFFDE68A), // Light yellowish background
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: _profileBytes != null
                    ? Image.memory(_profileBytes!, fit: BoxFit.cover)
                    : Container(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            // Minimal frame look
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            size: 64,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            bottom: -5,
            right: -5,
            child: GestureDetector(
              onTap: () => _pick(isProfile: true),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType type = TextInputType.text,
    List<TextInputFormatter>? formatters,
    int lines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: type,
          inputFormatters: formatters,
          maxLines: lines,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFF64748B).withOpacity(0.5),
            ),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF4F46E5)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropDownField({
    required String label,
    String? value,
    String? hint,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: const Color(0xFF4F46E5)),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    value ?? hint ?? 'Select',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: value != null
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF64748B).withOpacity(0.5),
                    ),
                  ),
                ),
                Icon(
                  label == 'Date of Birth'
                      ? Icons.calendar_today_outlined
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF64748B),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.medical_services_outlined,
                size: 20,
                color: Color(0xFF4F46E5),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4F46E5),
          ),
        ],
      ),
    );
  }

  Widget _buildAadharPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Aadhar Card Photo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _pick(isProfile: false),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _aadharBytes != null
                  ? Image.memory(_aadharBytes!, fit: BoxFit.cover)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.file_upload_outlined,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Upload Aadhar Card',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          'PNG, JPG or PDF (Max 2MB)',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _validateAndSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'COMPLETE REGISTRATION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.person_add_alt_1_rounded, size: 20),
              ],
            ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'By clicking "Complete Registration", you agree to',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Terms & Conditions',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Text(
              'and',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPicker({
    required String title,
    required List<String> options,
    required Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: options
                    .map(
                      (o) => ListTile(
                        title: Text(
                          o,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          onSelect(o);
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate:
          _dob ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primaryIndigo,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (p != null) setState(() => _dob = p);
  }
}

class _AadharFmt extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue nv) {
    final d = nv.text.replaceAll(' ', '');
    if (d.length > 12) return old;
    final buf = StringBuffer();
    for (int i = 0; i < d.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(d[i]);
    }
    final s = buf.toString();
    return TextEditingValue(
      text: s,
      selection: TextSelection.collapsed(offset: s.length),
    );
  }
}
