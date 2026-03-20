import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/one_ui_widgets.dart';
import '../viewmodels/auth_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: OneUIResponsivePadding(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryIndigo.withValues(
                              alpha: 0.5,
                            ),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: const AssetImage(
                            'assets/images/logo.png',
                          ),
                        ),
                      ).animate().fadeIn().scale(),
                      const SizedBox(height: 24),
                      const Text(
                        'FORCE SPORTS',
                        style: TextStyle(
                          color: Color(0xFF5C59BB),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          fontSize: 26,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 8),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 8),
                      const Text(
                        'Join the professional sports network.',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 400.ms),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Input Fields
                _buildFieldLabel('Full Name'),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _nameController,
                  hint: 'John Doe',
                  icon: Icons.person_outline_rounded,
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 20),

                _buildFieldLabel('E-Mail'),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _emailController,
                  hint: 'name@example.com',
                  icon: Icons.mail_outline_rounded,
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 20),

                _buildFieldLabel('Password'),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _passwordController,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  isVisible: _isPasswordVisible,
                  onToggleVisibility: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ).animate().fadeIn(delay: 700.ms),
                const SizedBox(height: 20),

                _buildFieldLabel('Confirm Password'),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  isVisible: _isConfirmPasswordVisible,
                  onToggleVisibility: () => setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  ),
                  showCheckmark:
                      _confirmPasswordController.text.isNotEmpty &&
                      _confirmPasswordController.text ==
                          _passwordController.text,
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 40),

                // Register Button
                ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          final name = _nameController.text.trim();
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();
                          final confirmPassword = _confirmPasswordController
                              .text
                              .trim();

                          if (name.isEmpty ||
                              email.isEmpty ||
                              password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          if (password != confirmPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Passwords do not match'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          final success = await viewModel.registerPlayer(
                            email: email,
                            password: password,
                            name: name,
                          );

                          if (!mounted) return;

                          if (success) {
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  viewModel.errorMessage ??
                                      'Registration failed',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black.withValues(alpha: 0.3),
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(
                            letterSpacing: 2,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                ).animate().fadeIn(delay: 900.ms).scale(),

                const SizedBox(height: 32),

                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1.2)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR SIGN UP WITH',
                        style: TextStyle(
                          color: AppTheme.textMuted.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1.2)),
                  ],
                ).animate().fadeIn(delay: 1000.ms),

                const SizedBox(height: 32),

                // Google Button
                OutlinedButton(
                  onPressed: () => viewModel.signInWithGoogle(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.textDark,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.google,
                          color: Color(0xFF4285F4),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 1100.ms),

                const SizedBox(height: 48),

                // Login Link
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: const TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 1200.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppTheme.textDark,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
    bool showCheckmark = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      onChanged: (_) {
        if (isPassword) setState(() {});
      },
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppTheme.textMuted.withValues(alpha: 0.5),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(icon, size: 22, color: AppTheme.textMuted),
        suffixIcon: isPassword
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showCheckmark)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                  IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: AppTheme.textMuted,
                    ),
                    onPressed: onToggleVisibility,
                  ),
                ],
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppTheme.secondarySky,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
