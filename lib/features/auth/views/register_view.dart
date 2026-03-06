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
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: OneUIResponsivePadding(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 80,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo & Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryIndigo.withValues(
                                alpha: 0.05,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 60,
                            ),
                          ).animate().fadeIn().scale(),
                          const SizedBox(height: 16),
                          const Text(
                            'FORCE SPORTS',
                            style: TextStyle(
                              color: AppTheme.primaryIndigo,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              fontSize: 18,
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Greeting
                    Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 8),
                    const Text(
                      'Join the professional sports network.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 500.ms),

                    const SizedBox(height: 40),

                    // Input Fields
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'E-Mail',
                      icon: Icons.alternate_email_rounded,
                    ).animate().fadeIn(delay: 700.ms),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                    ).animate().fadeIn(delay: 800.ms),

                    const SizedBox(height: 40),

                    // Register Button
                    ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              final success = await viewModel.registerPlayer(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                                name: _nameController.text.trim(),
                              );
                              if (success && mounted) {
                                Navigator.pop(context);
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
                              'CREATE ACCOUNT',
                              style: TextStyle(
                                letterSpacing: 1.5,
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
                            'OR SIGN UP WITH',
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

                    // Login Link
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: const TextStyle(color: AppTheme.textMuted),
                            children: [
                              TextSpan(
                                text: 'Sign in',
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

            // Back Button
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textDark,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
