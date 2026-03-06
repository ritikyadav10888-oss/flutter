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
import '../../../shared/widgets/one_ui_widgets.dart';

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
    if (u is Player) {
      final p = u;
      _healthCtrl.text = p.healthIssueDetails ?? '';
      _emergCtrl.text = p.emergencyContactNumber ?? '';
      _dob = p.dateOfBirth;
      _gender = p.gender;
      _bloodGroup = p.bloodGroup;
      _hasHealth = p.hasHealthIssues;
    } else if (u is Organizer) {
      final o = u;
      _addrCtrl.text = o.address ?? '';
      _bankCtrl.text = o.bankName ?? '';
      _accCtrl.text = o.accountNumber ?? '';
      _ifscCodeCtrl.text =
          o.ifscCode ?? ''; // Note: I'll fix this variable name if needed
      _panCtrl.text = o.panNumber ?? '';
      _accessCtrl.text = o.accessDuration ?? '';
    } else if (u is Owner) {
      final ow = u;
      _panCtrl.text = ow.panNumber ?? '';
    }
    _profileBytes = null;
    _aadharBytes = null;
    if (mounted) setState(() {});
  }

  // Helper variable fix for Organizer if mismatch above
  TextEditingController get _ifscCodeCtrl => _ifscCtrl;

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

      if (user is Player) {
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
      } else if (user is Organizer) {
        updateData.addAll({
          'address': _addrCtrl.text.trim(),
          'bankName': _bankCtrl.text.trim(),
          'accountNumber': _accCtrl.text.trim(),
          'ifscCode': _ifscCtrl.text.trim(),
          'panNumber': _panCtrl.text.trim(),
          'accessDuration': _accessCtrl.text.trim(),
        });
      } else if (user is Owner) {
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
            OneUISliverHeader(
              title: _isEditing ? 'Editing Profile' : 'My Profile',
              subtitle: user.email,
              actions: [
                if (!_isEditing) ...[
                  IconButton(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text(
                            'Are you sure you want to sign out?',
                          ),
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
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                  ),
                ] else
                  IconButton(
                    onPressed: _saving
                        ? null
                        : () {
                            setState(() => _isEditing = false);
                            _load();
                          },
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.sectionSpacing),
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
                                color: AppTheme.primaryIndigo.withValues(
                                  alpha: 0.1,
                                ),
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
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryIndigo,
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

                    OneUISection(
                      title: 'PERSONAL INFORMATION',
                      showSeparator: true,
                      children: [
                        _buildField(
                          'Full Name',
                          _nameCtrl,
                          Icons.person_outline,
                        ),
                        _buildField(
                          'Phone Number',
                          _phoneCtrl,
                          Icons.phone_outlined,
                          type: TextInputType.phone,
                        ),
                        if (user is Player) ...[
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
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),

                    if (user is Player)
                      OneUISection(
                        title: 'EMERGENCY & HEALTH',
                        showSeparator: true,
                        children: [
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
                      ),

                    if (user is Organizer) ...[
                      OneUISection(
                        title: 'PROFESSIONAL DETAILS',
                        showSeparator: true,
                        children: [
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
                        ],
                      ),
                      const SizedBox(height: 24),
                      OneUISection(
                        title: 'BANKING & TAX',
                        showSeparator: true,
                        children: [
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
                          _buildField(
                            'IFSC Code',
                            _ifscCtrl,
                            Icons.code_outlined,
                          ),
                          _buildField(
                            'PAN Number',
                            _panCtrl,
                            Icons.badge_outlined,
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    OneUISection(
                      title: 'IDENTITY',
                      showSeparator: true,
                      children: [
                        _buildField(
                          'Aadhar Number',
                          _aadharCtrl,
                          Icons.credit_card_outlined,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
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
                                child: OneUICard(
                                  padding: EdgeInsets.zero,
                                  child: _aadharBytes != null
                                      ? Image.memory(
                                          _aadharBytes!,
                                          fit: BoxFit.cover,
                                          height: 180,
                                          width: double.infinity,
                                        )
                                      : (user.aadharPic != null
                                            ? Image.network(
                                                user.aadharPic!,
                                                fit: BoxFit.cover,
                                                height: 180,
                                                width: double.infinity,
                                              )
                                            : Container(
                                                height: 120,
                                                width: double.infinity,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .add_photo_alternate_outlined,
                                                      color: AppTheme.textMuted
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                      size: 32,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    const Text(
                                                      'Upload Aadhar Card',
                                                      style: TextStyle(
                                                        color:
                                                            AppTheme.textMuted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    if (_isEditing)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
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
                      ),

                    OneUISection(
                      title: 'ACCOUNT',
                      showSeparator: true,
                      children: [
                        ListTile(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Sign Out'),
                                content: const Text(
                                  'Are you sure you want to sign out?',
                                ),
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
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                          title: const Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: Colors.red,
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
          color: AppTheme.primaryIndigo.withValues(alpha: 0.7),
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
        color: AppTheme.primaryIndigo.withValues(alpha: 0.7),
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
        color: AppTheme.primaryIndigo.withValues(alpha: 0.7),
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryIndigo,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
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
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                .map(
                  (bg) => ListTile(
                    title: Text(
                      bg,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      setState(() => _bloodGroup = bg);
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
