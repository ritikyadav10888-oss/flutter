import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';
import '../viewmodels/organizer_viewmodel.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/services/storage_service.dart';

class CreateOrganizerView extends StatefulWidget {
  final AppUser? organizer; // If provided, we are editing

  const CreateOrganizerView({super.key, this.organizer});

  @override
  State<CreateOrganizerView> createState() => _CreateOrganizerViewState();
}

class _CreateOrganizerViewState extends State<CreateOrganizerView> {
  final _formKey = GlobalKey<FormState>();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;
  late final TextEditingController aadharController;
  late final TextEditingController panController;
  late final TextEditingController bankNameController;
  late final TextEditingController accNoController;
  late final TextEditingController ifscController;
  late final TextEditingController durationController;

  Uint8List? profilePicBytes;
  String? profilePicFileName;
  Uint8List? aadharBytes;
  String? aadharFileName;
  Uint8List? panBytes;
  String? panFileName;

  String? existingProfilePicUrl;
  String? existingAadharUrl;
  String? existingPanUrl;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final user = widget.organizer;

    nameController = TextEditingController(text: user?.name);
    emailController = TextEditingController(text: user?.email);
    passwordController = TextEditingController();
    phoneController = TextEditingController(text: user?.phoneNumber ?? '+91 ');
    addressController = TextEditingController(text: user?.address);
    aadharController = TextEditingController(text: user?.aadharNumber);
    panController = TextEditingController(text: user?.panNumber);
    bankNameController = TextEditingController(text: user?.bankName);
    accNoController = TextEditingController(text: user?.accountNumber);
    ifscController = TextEditingController(text: user?.ifscCode);
    durationController = TextEditingController(text: user?.accessDuration);

    existingProfilePicUrl = user?.profilePic;
    existingAadharUrl = user?.aadharPic;
    existingPanUrl = user?.panPic;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    aadharController.dispose();
    panController.dispose();
    bankNameController.dispose();
    accNoController.dispose();
    ifscController.dispose();
    durationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int type) async {
    // 0: Profile, 1: Aadhar, 2: PAN
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        if (type == 0) {
          profilePicBytes = bytes;
          profilePicFileName = image.name;
        } else if (type == 1) {
          aadharBytes = bytes;
          aadharFileName = image.name;
        } else if (type == 2) {
          panBytes = bytes;
          panFileName = image.name;
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        durationController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final viewModel = context.read<OrganizerViewModel>();
      final ownerId = context.read<AuthViewModel>().user?.uid;
      if (ownerId == null) throw Exception('Owner session not found');

      final isEditing = widget.organizer != null;
      String? finalProfilePicUrl = existingProfilePicUrl;
      String? finalAadharUrl = existingAadharUrl;
      String? finalPanUrl = existingPanUrl;

      if (isEditing) {
        if (profilePicBytes != null) {
          finalProfilePicUrl = await _storageService.uploadProfilePicture(
            widget.organizer!.uid,
            profilePicBytes!,
            profilePicFileName!,
          );
        }
        if (aadharBytes != null) {
          finalAadharUrl = await _storageService.uploadAadharPicture(
            widget.organizer!.uid,
            aadharBytes!,
            aadharFileName!,
          );
        }
        if (panBytes != null) {
          finalPanUrl = await _storageService.uploadPanPicture(
            widget.organizer!.uid,
            panBytes!,
            panFileName!,
          );
        }

        final success = await viewModel.updateOrganizer(widget.organizer!.uid, {
          'name': nameController.text.trim(),
          'phoneNumber': phoneController.text.trim(),
          'address': addressController.text.trim(),
          'aadharNumber': aadharController.text.trim(),
          'aadharPic': finalAadharUrl,
          'panNumber': panController.text.trim(),
          'panPic': finalPanUrl,
          'profilePic': finalProfilePicUrl,
          'bankName': bankNameController.text.trim(),
          'accountNumber': accNoController.text.trim(),
          'ifscCode': ifscController.text.trim(),
          'accessDuration': durationController.text.trim(),
        });
        if (success && mounted) Navigator.pop(context);
      } else {
        final success = await viewModel.createOrganizer(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          ownerId: ownerId,
          phoneNumber: phoneController.text.trim(),
          address: addressController.text.trim(),
          aadharNumber: aadharController.text.trim(),
          aadharBytes: aadharBytes,
          aadharFileName: aadharFileName,
          panNumber: panController.text.trim(),
          panBytes: panBytes,
          panFileName: panFileName,
          profilePicBytes: profilePicBytes,
          profilePicFileName: profilePicFileName,
          bankName: bankNameController.text.trim(),
          accountNumber: accNoController.text.trim(),
          ifscCode: ifscController.text.trim(),
          accessDuration: durationController.text.trim(),
        );
        if (success) {
          if (mounted) Navigator.pop(context);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(viewModel.errorMessage ?? 'Operation failed'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.organizer != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Organizer' : 'Create Organizer'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfilePicPicker(),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      title: 'Personal Details',
                      icon: Icons.person_outline,
                      children: [
                        _buildTextField(
                          nameController,
                          'Full Name',
                          Icons.person,
                        ),
                        _buildTextField(
                          emailController,
                          'Email Address',
                          Icons.email,
                          enabled: !isEditing,
                        ),
                        _buildTextField(
                          phoneController,
                          'Phone Number',
                          Icons.phone,
                        ),
                        _buildTextField(
                          addressController,
                          'Full Address',
                          Icons.location_on,
                          maxLines: 4,
                        ),
                        _buildTextField(
                          aadharController,
                          'Aadhar Number',
                          Icons.credit_card,
                        ),
                        _buildTextField(
                          panController,
                          'PAN Card Number',
                          Icons.badge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Aadhar Card Photo',
                      icon: Icons.image_outlined,
                      children: [
                        _buildDashedUploadArea(
                          label: 'Tap to Upload Aadhar',
                          icon: Icons.file_present_outlined,
                          hasFile:
                              aadharBytes != null || existingAadharUrl != null,
                          onTap: () => _pickImage(1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'PAN Card Photo',
                      icon: Icons.image_outlined,
                      children: [
                        _buildDashedUploadArea(
                          label: 'Tap to Upload PAN Card',
                          icon: Icons.credit_card_outlined,
                          hasFile: panBytes != null || existingPanUrl != null,
                          onTap: () => _pickImage(2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Bank Details',
                      icon: Icons.account_balance_outlined,
                      children: [
                        _buildTextField(
                          accNoController,
                          'Account Number',
                          Icons.numbers,
                        ),
                        _buildTextField(
                          ifscController,
                          'IFSC Code',
                          Icons.qr_code,
                        ),
                        _buildTextField(
                          bankNameController,
                          'Bank Name',
                          Icons.account_balance,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Access Duration',
                      icon: Icons.access_time,
                      children: [
                        const Text(
                          'Set how long this organizer has access to the platform.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          durationController,
                          '',
                          Icons.calendar_today_outlined,
                          readOnly: true,
                          suffixIcon: const Icon(
                            Icons.calendar_month,
                            size: 20,
                          ),
                          onTap: () => _selectDate(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Security',
                      icon: Icons.security,
                      children: [
                        _buildTextField(
                          passwordController,
                          'Set Password',
                          Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (v) =>
                              (!isEditing && (v == null || v.length < 6))
                              ? 'Minimum 6 characters required'
                              : null,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Minimum 6 characters required.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6750A4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              isEditing ? 'Update Account' : 'Create Account',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfilePicPicker() {
    ImageProvider? imageProvider;
    if (profilePicBytes != null) {
      imageProvider = MemoryImage(profilePicBytes!);
    } else if (existingProfilePicUrl != null) {
      imageProvider = NetworkImage(existingProfilePicUrl!);
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _pickImage(0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF6750A4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool enabled = true,
    bool obscureText = false,
    bool readOnly = false,
    int maxLines = 1,
    Widget? suffixIcon,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        validator:
            validator ?? (v) => (v == null || v.isEmpty) ? 'Required' : null,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          hintText: label,
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF6750A4), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDashedUploadArea({
    required String label,
    required IconData icon,
    required bool hasFile,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD1D5DB),
            style: BorderStyle.solid,
          ), // Future note: replace with CustomPaint for actual dashed
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFile ? Icons.check_circle : icon,
              color: hasFile ? Colors.green : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              hasFile ? 'Image Selected' : label,
              style: TextStyle(
                color: hasFile ? Colors.green : Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
