import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/one_ui_widgets.dart';
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
  final _healthController = TextEditingController();

  // State
  DateTime? _dob;
  String? _gender;
  String? _bloodGroup;
  bool? _hasHealthIssues;

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
    if (_hasHealthIssues == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer the health question.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_hasHealthIssues == true && _healthController.text.trim().isEmpty) {
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
        'hasHealthIssues': _hasHealthIssues,
        'healthIssueDetails': _hasHealthIssues == true
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
    _healthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: CustomScrollView(
        slivers: [
          const OneUISliverHeader(
            title: 'Complete Profile',
            subtitle: 'Tell us about yourself to get started',
            expanded: true,
          ),
          SliverToBoxAdapter(
            child: OneUIResponsivePadding(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.sectionSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileImagePicker(),
                    const SizedBox(height: 32),

                    OneUISection(
                      title: 'PERSONAL INFORMATION',
                      showSeparator:
                          false, // Disabling separators for new box style
                      children: [
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _emailController,
                          label: 'Email Address',
                          icon: Icons.alternate_email,
                          type: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_android,
                          type: TextInputType.phone,
                        ),
                        const SizedBox(height: 8),
                        _buildSelectionRow(
                          label: 'Gender',
                          value: _gender ?? 'Select',
                          icon: Icons.wc_outlined,
                          onTap: () => _showPicker(
                            title: 'Select Gender',
                            options: ['Male', 'Female', 'Other'],
                            onSelect: (v) => setState(() => _gender = v),
                          ),
                        ),
                        _buildSelectionRow(
                          label: 'Blood Group',
                          value: _bloodGroup ?? 'Select',
                          icon: Icons.bloodtype_outlined,
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
                        _buildSelectionRow(
                          label: 'Date of Birth',
                          value: _dob != null
                              ? DateFormat('dd MMM yyyy').format(_dob!)
                              : 'Select',
                          icon: Icons.calendar_today_outlined,
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    const SizedBox(height: 32),

                    OneUISection(
                      title: 'IDENTITY & DOCUMENTS',
                      showSeparator: false,
                      children: [
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _emergencyController,
                          label: 'Emergency Phone',
                          icon: Icons.contact_emergency_outlined,
                          type: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _aadharController,
                          label: 'Aadhar Number',
                          icon: Icons.badge_outlined,
                          type: TextInputType.number,
                          formatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(12),
                            _AadharFmt(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildAadharPicker(),
                        const SizedBox(height: 16),
                      ],
                    ),
                    const SizedBox(height: 32),

                    OneUISection(
                      title: 'HEALTH & EMERGENCY',
                      showSeparator: false,
                      children: [
                        const SizedBox(height: 16),
                        _buildToggleRow(
                          label: 'Any health issues?',
                          value: _hasHealthIssues ?? false,
                          onChanged: (v) =>
                              setState(() => _hasHealthIssues = v),
                        ),
                        if (_hasHealthIssues == true) ...[
                          const SizedBox(height: 16),
                          _buildField(
                            controller: _healthController,
                            label: 'Health Issue Details',
                            icon: Icons.medical_services_outlined,
                            lines: 3,
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                    const SizedBox(height: 48),

                    _buildSubmitButton(),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: () => _pick(isProfile: true),
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryIndigo.withOpacity(0.1),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryIndigo.withOpacity(0.12),
                blurRadius: 25,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(70),
                  child: _profileBytes != null
                      ? Image.memory(_profileBytes!, fit: BoxFit.cover)
                      : Container(
                          color: AppTheme.primaryIndigo.withOpacity(0.05),
                          child: const Icon(
                            Icons.person_outline,
                            size: 64,
                            color: AppTheme.primaryIndigo,
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigo,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    List<TextInputFormatter>? formatters,
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        inputFormatters: formatters,
        maxLines: lines,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppTheme.textDark,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            size: 22,
            color: AppTheme.primaryIndigo.withOpacity(0.8),
          ),
          alignLabelWithHint: lines > 1,
          // Note: Decoration is mostly inherited from AppTheme.lightTheme.inputDecorationTheme
        ),
      ),
    );
  }

  Widget _buildSelectionRow({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: AppTheme.primaryIndigo.withOpacity(0.8),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMuted,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.expand_more,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.health_and_safety_outlined,
                    size: 22,
                    color: AppTheme.primaryIndigo.withOpacity(0.8),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primaryIndigo,
              activeTrackColor: AppTheme.primaryIndigo.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAadharPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 16,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Aadhar Card Photo',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _pick(isProfile: false),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.primaryIndigo.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: _aadharBytes != null
                    ? Image.memory(_aadharBytes!, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 32,
                              color: AppTheme.primaryIndigo.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Click to upload Aadhar',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryIndigo.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _validateAndSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryIndigo,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
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
                  Flexible(
                    child: Text(
                      'COMPLETE REGISTRATION',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14, // Slightly smaller to prevent overflow
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
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
