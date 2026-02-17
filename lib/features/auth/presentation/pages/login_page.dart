import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';

/// Página de Login con Supabase Auth
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureNewPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _handleMigration() {
    final state = context.read<AuthBloc>().state;
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthMigrateLegacyUser(
            email: state.migrationEmail!,
            newPassword: _newPasswordController.text,
            legacyUserId: state.legacyUserId!,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.isAuthenticated) {
            context.go('/dashboard');
          }
        },
        builder: (context, state) {
          // Show migration form if user needs to migrate
          if (state.needsPasswordMigration) {
            return _buildMigrationForm(state);
          }

          // Show login form
          return _buildLoginForm(state);
        },
      ),
    );
  }

  Widget _buildLoginForm(AuthState state) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: AppSpacing.paddingXl,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppSpacing.borderRadiusLg,
                ),
                child: const Icon(
                  Icons.sports_soccer,
                  color: AppColors.white,
                  size: 40,
                ),
              ),
              AppSpacing.vSpaceXl,
              Text(
                'Iniciar Sesión',
                style: AppTypography.h3,
              ),
              AppSpacing.vSpaceMd,
              Text(
                'Bienvenido a FutBase 3.0',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gray500,
                ),
              ),
              AppSpacing.vSpaceXxxl,

              // Error message
              if (state.hasError) ...[
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      AppSpacing.hSpaceMd,
                      Expanded(
                        child: Text(
                          state.errorMessage ?? 'Error desconocido',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vSpaceLg,
              ],

              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa tu email';
                  }
                  if (!value.contains('@')) {
                    return 'Por favor, ingresa un email válido';
                  }
                  return null;
                },
              ),
              AppSpacing.vSpaceLg,

              // Password field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa tu contraseña';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _handleLogin(),
              ),
              AppSpacing.vSpaceLg,

              // Login button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusMd,
                    ),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              AppSpacing.vSpaceLg,

              // Forgot password
              TextButton(
                onPressed: () => _showPasswordResetDialog(context),
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              AppSpacing.vSpaceXl,

              // Back button
              TextButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMigrationForm(AuthState state) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: AppSpacing.paddingXl,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Warning icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sync_lock_outlined,
                  color: AppColors.warning,
                  size: 40,
                ),
              ),
              AppSpacing.vSpaceXl,
              Text(
                'Actualización Requerida',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              AppSpacing.vSpaceMd,
              Text(
                'Hola! Hemos mejorado nuestro sistema de seguridad. '
                'Por favor, crea una nueva contraseña para tu cuenta.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.gray500,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vSpaceMd,
              Container(
                padding: AppSpacing.paddingSm,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  state.migrationEmail ?? '',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppSpacing.vSpaceXxxl,

              // New password field
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'Nueva Contraseña',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  helperText: 'Mínimo 6 caracteres',
                ),
              ),
              AppSpacing.vSpaceLg,

              // Confirm password field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                ),
              ),
              AppSpacing.vSpaceXl,

              // Migrate button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _handleMigration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusMd,
                    ),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : const Text(
                          'Actualizar y Continuar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              AppSpacing.vSpaceLg,

              // Cancel button
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasswordResetDialog(BuildContext context) {
    final resetEmailController = TextEditingController(
      text: _emailController.text,
    );
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Recuperar Contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Introduce tu email y te enviaremos un enlace para restablecer tu contraseña.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.pop(dialogContext);
                    },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final email = resetEmailController.text.trim();
                      if (email.isEmpty || !email.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor, introduce un email válido'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      try {
                        context.read<AuthBloc>().add(
                              AuthPasswordResetRequested(email: email),
                            );

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Se ha enviado un email de recuperación. Revisa tu bandeja de entrada.',
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() => isLoading = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}
