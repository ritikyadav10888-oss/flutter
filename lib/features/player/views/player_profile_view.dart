import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/aura_widgets.dart';

class PlayerProfileView extends StatefulWidget {
  const PlayerProfileView({super.key});
  @override
  State<PlayerProfileView> createState() => _PlayerProfileViewState();
}

class _PlayerProfileViewState extends State<PlayerProfileView> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _saving = false;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emergCtrl = TextEditingController();
  final _aadharCtrl = TextEditingController();
  final _healthCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _accCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _accessCtrl = TextEditingController();

  DateTime? _dob;
  String? _gender;
  String? _bloodGroup;
  bool? _hasHealth;

  Uint8List? _profileBytes;
  String? _profileName;
  Uint8List? _aadharBytes;
  String? _aadharName;

  final _picker = ImagePicker();
  final _storage = StorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final u = context.read<AuthViewModel>().user;
    if (u == null) return;
    _nameCtrl.text = u.name;
    _phoneCtrl.text = u.phoneNumber ?? '';
    _aadharCtrl.text = u.aadharNumber ?? '';
    if (u.roles.contains(UserRole.player)) {
      _healthCtrl.text = u.healthIssueDetails ?? '';
      _emergCtrl.text = u.emergencyContactNumber ?? '';
      _dob = u.dateOfBirth;
      _gender = u.gender;
      _bloodGroup = u.bloodGroup;
      _hasHealth = u.hasHealthIssues;
    }
    if (u.roles.contains(UserRole.organizer)) {
      _addrCtrl.text = u.address ?? '';
      _bankCtrl.text = u.bankName ?? '';
      _accCtrl.text = u.accountNumber ?? '';
      _ifscCtrl.text = u.ifscCode ?? '';
      _panCtrl.text = u.panNumber ?? '';
      _accessCtrl.text = u.accessDuration ?? '';
    }
    if (u.roles.contains(UserRole.owner)) {
      _panCtrl.text = u.panNumber ?? '';
    }
    _profileBytes = null;
    _aadharBytes = null;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emergCtrl.dispose();
    _aadharCtrl.dispose();
    _healthCtrl.dispose();
    _addrCtrl.dispose();
    _bankCtrl.dispose();
    _accCtrl.dispose();
    _ifscCtrl.dispose();
    _panCtrl.dispose();
    _accessCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick({required bool isProfile}) async {
    if (!_isEditing) return;
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

  Future<void> _save() async {
    final user = context.read<AuthViewModel>().user;
    if (user == null) return;

    if (!_formKey.currentState!.validate()) {
      _snack('Please fill all required fields.', Colors.red);
      return;
    }

    setState(() => _saving = true);
    try {
      final vm = context.read<AuthViewModel>();
      final uid = vm.user!.uid;
      String? profileUrl = vm.user?.profilePic;
      String? aadharUrl = vm.user?.aadharPic;

      if (_profileBytes != null) {
        profileUrl = await _storage.uploadProfilePicture(
          uid,
          _profileBytes!,
          _profileName!,
        );
      }
      if (_aadharBytes != null) {
        aadharUrl = await _storage.uploadAadharPicture(
          uid,
          _aadharBytes!,
          _aadharName!,
        );
      }

      final Map<String, dynamic> updateData = {
        'name': _nameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'aadharNumber': _aadharCtrl.text.trim(),
        if (profileUrl != null) 'profilePic': profileUrl,
        if (aadharUrl != null) 'aadharPic': aadharUrl,
      };

      if (user.roles.contains(UserRole.player)) {
        updateData.addAll({
          'gender': _gender,
          'bloodGroup': _bloodGroup,
          'dateOfBirth': _dob,
          'hasHealthIssues': _hasHealth,
          'healthIssueDetails': _hasHealth == true
              ? _healthCtrl.text.trim()
              : null,
          'emergencyContactNumber': _emergCtrl.text.trim(),
        });
      }
      if (user.roles.contains(UserRole.organizer)) {
        updateData.addAll({
          'address': _addrCtrl.text.trim(),
          'bankName': _bankCtrl.text.trim(),
          'accountNumber': _accCtrl.text.trim(),
          'ifscCode': _ifscCtrl.text.trim(),
          'panNumber': _panCtrl.text.trim(),
          'accessDuration': _accessCtrl.text.trim(),
        });
      }
      if (user.roles.contains(UserRole.owner)) {
        updateData.addAll({'panNumber': _panCtrl.text.trim()});
      }

      await AuthService().updatePlayerProfile(uid, updateData);
      setState(() => _isEditing = false);
      _snack('Profile updated successfully!', Colors.green);
    } catch (e) {
      _snack('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;
    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            AuraHeader(
              title: _isEditing ? 'Editing Profile' : 'My Profile',
              subtitle: user.email,
              actions: [
                if (!_isEditing) ...[
                  IconButton(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(
                      Icons.edit_note_rounded,
                      color: AppTheme.primaryIndigo,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showSignOutDialog(),
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppTheme.accentCoral,
                    ),
                  ),
                ] else
                  IconButton(
                    onPressed: _saving
                        ? null
                        : () {
                            setState(() => _isEditing = false);
                            _load();
                          },
                    icon: const Icon(Icons.close_rounded),
                  ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.auraPadding),
                child: Column(
                  children: [
                    // Profile Image
                    Center(
                      child: GestureDetector(
                        onTap: () => _pick(isProfile: true),
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryIndigo.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                image: _profileBytes != null
                                    ? DecorationImage(
                                        image: MemoryImage(_profileBytes!),
                                        fit: BoxFit.cover,
                                      )
                                    : (user.profilePic != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                user.profilePic!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null),
                              ),
                              child:
                                  (_profileBytes == null &&
                                      user.profilePic == null)
                                  ? Center(
                                      child: Text(
                                        user.name[0].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryIndigo
                                              .withOpacity(0.1),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryIndigo,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // PERSONAL INFORMATION
                    AuraStatsCard(
                      label: 'Personal Information',
                      value: '',
                      icon: Icons.person_rounded,
                      accentColor: AppTheme.primaryIndigo,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      'Full Name',
                      _nameCtrl,
                      Icons.person_outline_rounded,
                    ),
                    _buildField(
                      'Phone Number',
                      _phoneCtrl,
                      Icons.phone_outlined,
                      type: TextInputType.phone,
                    ),

                    if (user.roles.contains(UserRole.player)) ...[
                      _buildSelectionRow(
                        'Gender',
                        _gender ?? 'Select',
                        Icons.wc_outlined,
                        () => _showGenderPicker(),
                      ),
                      _buildSelectionRow(
                        'Birthday',
                        _dob != null
                            ? DateFormat('dd MMM yyyy').format(_dob!)
                            : 'Select',
                        Icons.cake_outlined,
                        () => _showDatePicker(),
                      ),
                      const SizedBox(height: 24),
                      AuraStatsCard(
                        label: 'Emergency & Health',
                        value: '',
                        icon: Icons.health_and_safety_rounded,
                        accentColor: AppTheme.accentCoral,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        'Emergency Contact',
                        _emergCtrl,
                        Icons.emergency_outlined,
                        type: TextInputType.phone,
                      ),
                      _buildSelectionRow(
                        'Blood Group',
                        _bloodGroup ?? 'Select',
                        Icons.bloodtype_outlined,
                        () => _showBloodGroupPicker(),
                      ),
                      _buildToggleRow(
                        'Health Issues',
                        _hasHealth ?? false,
                        Icons.health_and_safety_outlined,
                        (val) => setState(() => _hasHealth = val),
                      ),
                      if (_hasHealth == true)
                        _buildField(
                          'Details',
                          _healthCtrl,
                          Icons.description_outlined,
                          maxLines: 3,
                        ),
                    ],

                    if (user.roles.contains(UserRole.organizer)) ...[
                      const SizedBox(height: 24),
                      AuraStatsCard(
                        label: 'Professional details',
                        value: '',
                        icon: Icons.work_rounded,
                        accentColor: AppTheme.primaryIndigo,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        'Address',
                        _addrCtrl,
                        Icons.location_on_outlined,
                      ),
                      _buildField(
                        'Access Duration',
                        _accessCtrl,
                        Icons.timer_outlined,
                      ),
                      const SizedBox(height: 24),
                      AuraStatsCard(
                        label: 'Banking & Tax',
                        value: '',
                        icon: Icons.account_balance_rounded,
                        accentColor: AppTheme.primaryIndigo,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        'Bank Name',
                        _bankCtrl,
                        Icons.account_balance_outlined,
                      ),
                      _buildField(
                        'Account Number',
                        _accCtrl,
                        Icons.numbers_outlined,
                      ),
                      _buildField('IFSC Code', _ifscCtrl, Icons.code_outlined),
                      _buildField('PAN Number', _panCtrl, Icons.badge_outlined),
                    ],

                    if (user.roles.contains(UserRole.owner)) ...[
                      const SizedBox(height: 24),
                      AuraStatsCard(
                        label: 'Tax details',
                        value: '',
                        icon: Icons.badge_rounded,
                        accentColor: AppTheme.primaryIndigo,
                      ),
                      const SizedBox(height: 16),
                      _buildField('PAN Number', _panCtrl, Icons.badge_outlined),
                    ],

                    const SizedBox(height: 24),
                    AuraStatsCard(
                      label: 'Identity',
                      value: '',
                      icon: Icons.credit_card_rounded,
                      accentColor: AppTheme.primaryIndigo,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      'Aadhar Number',
                      _aadharCtrl,
                      Icons.credit_card_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildAadharPicker(user),

                    const SizedBox(height: 48),

                    if (_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _saving
                                  ? null
                                  : () {
                                      setState(() => _isEditing = false);
                                      _load();
                                    },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _saving ? null : _save,
                              child: _saving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    if (!_isEditing) {
      return ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: AppTheme.primaryIndigo.withOpacity(0.7),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          ctrl.text.isEmpty ? 'Not set' : ctrl.text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
    );
  }

  Widget _buildSelectionRow(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: _isEditing ? onTap : null,
      leading: Icon(
        icon,
        size: 20,
        color: AppTheme.primaryIndigo.withOpacity(0.7),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.textMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
        ),
      ),
      trailing: _isEditing ? const Icon(Icons.chevron_right, size: 20) : null,
    );
  }

  Widget _buildToggleRow(
    String label,
    bool value,
    IconData icon,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: _isEditing ? onChanged : null,
      secondary: Icon(
        icon,
        size: 20,
        color: AppTheme.primaryIndigo.withOpacity(0.7),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildAadharPicker(AppUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aadhar Card Image',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _pick(isProfile: false),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.backgroundWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
              image: _aadharBytes != null
                  ? DecorationImage(
                      image: MemoryImage(_aadharBytes!),
                      fit: BoxFit.cover,
                    )
                  : (user.aadharPic != null
                        ? DecorationImage(
                            image: NetworkImage(user.aadharPic!),
                            fit: BoxFit.cover,
                          )
                        : null),
            ),
            child: (_aadharBytes == null && user.aadharPic == null)
                ? const Center(
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppTheme.textMuted,
                      size: 32,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthViewModel>().signOut();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.accentCoral),
            ),
          ),
        ],
      ),
    );
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Male', 'Female', 'Other']
              .map(
                (g) => ListTile(
                  title: Text(
                    g,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    setState(() => _gender = g);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _dob = d);
  }

  void _showBloodGroupPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          children: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
              .map(
                (bg) => InkWell(
                  onTap: () {
                    setState(() => _bloodGroup = bg);
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Text(
                      bg,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
