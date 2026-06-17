import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushroom_monitor/features/dashboard/providers/auth_provider.dart';

// ── Shared palette ──────────────────────────────────────────────────────────
// Mirrors _AuthColors in login_page.dart. Extract to a shared
// `auth_theme.dart` if you want a single source of truth.
class _AuthColors {
  static const bg = Color(0xFF0B150D);
  static const surface = Color(0xFF13201A);
  static const border = Color(0xFF22382B);
  static const borderFocus = Color(0xFF5FE39A);
  static const glow = Color(0xFF5FE39A);
  static const textPrimary = Color(0xFFE9F2EA);
  static const textMuted = Color(0xFF7FA08A);
  static const textFaint = Color(0xFF4A6A57);
  static const danger = Color(0xFFEF6B5B);
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    // Repaint the password-strength hint as the user types.
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Privacy Policy'),
          backgroundColor: _AuthColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(authErrorProvider.notifier).state = null;
    ref.read(authLoadingProvider.notifier).state = true;

    try {
      final authService = ref.read(authServiceProvider);
      await authService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      // Pop back to the root route so AuthWrapper (now showing MainShell)
      // is actually visible, instead of staying buried under this screen.
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ref.read(authErrorProvider.notifier).state = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: _AuthColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        ref.read(authLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);

    return Scaffold(
      backgroundColor: _AuthColors.bg,
      appBar: AppBar(
        backgroundColor: _AuthColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: _AuthColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Start your grow',
                  style: TextStyle(
                    color: _AuthColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create an account to monitor your room',
                  style: TextStyle(
                    color: _AuthColors.textMuted,
                    fontSize: 14.5,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                _buildLabel('Full name'),
                const SizedBox(height: 8),
                _buildTextInput(
                  controller: _nameController,
                  hintText: 'John Doe',
                  keyboardType: TextInputType.name,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your full name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _buildLabel('Email'),
                const SizedBox(height: 8),
                _buildTextInput(
                  controller: _emailController,
                  hintText: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _buildLabel('Password'),
                const SizedBox(height: 8),
                _buildTextInput(
                  controller: _passwordController,
                  hintText: 'Min. 8 characters',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _AuthColors.textFaint,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                      return 'Include at least one uppercase letter';
                    }
                    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                      return 'Include at least one number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),
                _PasswordStrengthHint(password: _passwordController.text),

                const SizedBox(height: 18),

                _buildLabel('Confirm password'),
                const SizedBox(height: 8),
                _buildTextInput(
                  controller: _confirmPasswordController,
                  hintText: 'Re-enter your password',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _AuthColors.textFaint,
                      size: 20,
                    ),
                    onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Terms checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _agreedToTerms,
                        activeColor: _AuthColors.glow,
                        checkColor: const Color(0xFF06150C),
                        side: const BorderSide(color: _AuthColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        onChanged: (val) =>
                            setState(() => _agreedToTerms = val ?? false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _agreedToTerms = !_agreedToTerms),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: _AuthColors.textMuted,
                              height: 1.4,
                            ),
                            children: const [
                              TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: _AuthColors.glow,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: _AuthColors.glow,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _AuthColors.glow,
                      disabledBackgroundColor: _AuthColors.glow.withValues(
                        alpha: 0.4,
                      ),
                      foregroundColor: const Color(0xFF06150C),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Color(0xFF06150C),
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Create account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: _AuthColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            color: _AuthColors.glow,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _AuthColors.textMuted,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: _AuthColors.textPrimary),
      cursorColor: _AuthColors.glow,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: _AuthColors.textFaint, fontSize: 15),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: _AuthColors.textFaint, size: 20)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _AuthColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AuthColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AuthColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _AuthColors.borderFocus,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AuthColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AuthColors.danger, width: 1.5),
        ),
      ),
    );
  }
}

/// Inline password strength indicator, restyled for the dark palette.
class _PasswordStrengthHint extends StatelessWidget {
  final String password;

  const _PasswordStrengthHint({required this.password});

  int get _strength {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final labels = ['Weak', 'Fair', 'Good', 'Strong'];
    final colors = [
      _AuthColors.danger,
      const Color(0xFFD89A3E),
      const Color(0xFF4CAF50),
      _AuthColors.glow,
    ];

    final idx = (_strength - 1).clamp(0, 3);

    return Row(
      children: [
        ...List.generate(
          4,
          (i) => Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              height: 3,
              decoration: BoxDecoration(
                color: i < _strength ? colors[idx] : _AuthColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          labels[idx],
          style: TextStyle(
            fontSize: 12,
            color: colors[idx],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
