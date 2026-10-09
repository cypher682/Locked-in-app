import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';

/// Redesigned Login screen matching design references
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleEmailLogin() {
    ref.read(authProvider.notifier).signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  void _handleGoogleSignIn() {
    ref.read(authProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Navigate to home when authenticated
    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientStart,
              AppColors.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Name
                  Text(
                    'Locked-In',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Join the community or log in to continue',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Sign Up Button
                  CustomButton(
                    text: 'Sign Up',
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    width: double.infinity,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Log In Button (Secondary)
                  CustomButton(
                    text: 'Log In',
                    type: ButtonType.secondary,
                    onPressed: () {
                      Navigator.pushNamed(context, '/login-email');
                    },
                    width: double.infinity,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.white.withOpacity(0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or continue with',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white.withOpacity(0.6),
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.white.withOpacity(0.3))),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Social Auth Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: Icons.g_mobiledata,
                        onTap: _handleGoogleSignIn,
                      ),
                      const SizedBox(width: 16),
                      _buildSocialButton(
                        icon: Icons.facebook,
                        onTap: () {
                          // TODO: Implement Facebook auth
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildSocialButton(
                        icon: Icons.flutter_dash, // Placeholder for Twitter
                        onTap: () {
                          // TODO: Implement Twitter auth
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Error Message
                  if (authState.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.darkError.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.darkError),
                      ),
                      child: Text(
                        authState.error!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.darkError,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Terms & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          // TODO: Forgot password
                        },
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(color: AppColors.white.withOpacity(0.5)),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Terms of service
                        },
                        child: Text(
                          'Terms of Service',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.darkSurface,
          border: Border.all(
            color: AppColors.darkBorder,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: 28,
        ),
      ),
    );
  }
}
