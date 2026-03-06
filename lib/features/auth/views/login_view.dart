import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/one_ui_widgets.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'register_view.dart';

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
      backgroundColor: AppTheme.backgroundWhite,
      body: OneUIResponsivePadding(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryIndigo.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 80,
                        ),
                      ).animate().fadeIn().scale(),
                      const SizedBox(height: 24),
                      const Text(
                        'FORCE SPORTS',
                        style: TextStyle(
                          color: AppTheme.primaryIndigo,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          fontSize: 24,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const Text(
                        'PLAYER REGISTER APP',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
                const SizedBox(height: 60),

                // Greeting
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue your sports journey',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 48),

                // Input Fields
                _buildTextField(
                  controller: _emailController,
                  label: 'E-Mail',
                  icon: Icons.alternate_email_rounded,
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
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
                        color: AppTheme.primaryIndigo,
                        fontWeight: FontWeight.w600,
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
                              const SnackBar(
                                content: Text(
                                  'Login failed. Please check your credentials.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: AppTheme.textDark,
                    foregroundColor: Colors.white,
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'SIGN IN',
                          style: TextStyle(
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ).animate().fadeIn(delay: 900.ms).scale(),

                const SizedBox(height: 24),

                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: TextStyle(
                          color: AppTheme.textMuted.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ).animate().fadeIn(delay: 1000.ms),

                const SizedBox(height: 24),

                // Google Button
                OutlinedButton.icon(
                  onPressed: viewModel.isLoading
                      ? null
                      : () => viewModel.signInWithGoogle(),
                  icon: const FaIcon(
                    FontAwesomeIcons.google,
                    color: Color(0xFF4285F4),
                    size: 18,
                  ),
                  label: const Text('Google Account'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: BorderSide(
                      color: AppTheme.primaryIndigo.withValues(alpha: 0.1),
                    ),
                  ),
                ).animate().fadeIn(delay: 1100.ms),

                const SizedBox(height: 48),

                // Signup Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterView(),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: const TextStyle(color: AppTheme.textMuted),
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(
                              color: AppTheme.primaryIndigo,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
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
