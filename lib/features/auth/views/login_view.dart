import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/one_ui_widgets.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

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
                      const Text(
                        'PLAYER REGISTER APP',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          fontSize: 13,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Greeting
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue your sports journey',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 40),

                // Input Fields
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
                ).animate().fadeIn(delay: 700.ms),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        _showForgotPasswordDialog(context, viewModel),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF56A8B1), // Teal/Cyan from design
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 32),

                // Login Button
                ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          final success = await viewModel.signIn(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );
                          if (!success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  viewModel.errorMessage ??
                                      'Login failed. Please check your credentials.',
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
                          'SIGN IN',
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
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'OR CONTINUE WITH',
                          style: TextStyle(
                            color: AppTheme.textMuted.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1.2)),
                  ],
                ).animate().fadeIn(delay: 1000.ms),

                const SizedBox(height: 32),

                // Social Buttons
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

                // Signup Link Removed
                const SizedBox(height: 48),
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
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppTheme.textMuted.withValues(alpha: 0.5),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(icon, size: 22, color: AppTheme.textMuted),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: AppTheme.textMuted,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF1F5F9), // Light grey background
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

  void _showForgotPasswordDialog(
    BuildContext context,
    AuthViewModel viewModel,
  ) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email address to receive a password reset link.',
              style: TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'E-Mail',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;
              final success = await viewModel.resetPassword(email);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Password reset email sent!'
                          : viewModel.errorMessage ??
                                'Failed to send reset email.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('SEND LINK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
