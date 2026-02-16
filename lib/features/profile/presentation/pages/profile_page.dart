import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cosmetics_catalog/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cosmetics_catalog/core/widgets/loading_overlay.dart';
import 'package:cosmetics_catalog/core/widgets/error_snackbar.dart';
import 'package:cosmetics_catalog/core/widgets/success_snackbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  DateTime? _lastEmailSentTime;
  bool _isEmailSendingDisabled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const LogoutEvent());
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  void _handleSendVerification() {
    // Проверяем, прошло ли достаточно времени с последней отправки
    if (_lastEmailSentTime != null) {
      final timeSinceLastSent = DateTime.now().difference(_lastEmailSentTime!);
      if (timeSinceLastSent.inSeconds < 60) {
        final remainingSeconds = 60 - timeSinceLastSent.inSeconds;
        showErrorSnackBar(
          context,
          'Пожалуйста, подождите $remainingSeconds секунд перед повторной отправкой',
        );
        return;
      }
    }

    // Отключаем кнопку на 60 секунд
    setState(() {
      _lastEmailSentTime = DateTime.now();
      _isEmailSendingDisabled = true;
    });

    context.read<AuthBloc>().add(const SendEmailVerificationEvent());

    // Включаем кнопку через 60 секунд
    Future.delayed(const Duration(seconds: 60), () {
      if (mounted) {
        setState(() {
          _isEmailSendingDisabled = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: user == null
          ? const Center(
              child: Text('Пожалуйста, войдите в систему'),
            )
          : BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthUnauthenticated) {
                  context.go('/login');
                } else if (state is EmailVerificationSent) {
                  showSuccessSnackBar(
                    context,
                    'Письмо для подтверждения отправлено! Проверьте почту.',
                  );
                } else if (state is ProfileUpdated) {
                  // Обновляем страницу после изменения профиля
                  setState(() {});
                } else if (state is AuthError) {
                  // Если ошибка связана с слишком частыми запросами, показываем более понятное сообщение
                  if (state.message.contains('too-many-requests') || 
                      state.message.contains('Слишком много запросов')) {
                    showErrorSnackBar(
                      context,
                      'Слишком много запросов. Пожалуйста, подождите минуту перед повторной попыткой.',
                    );
                    // Сбрасываем флаг, чтобы пользователь мог попробовать снова через минуту
                    setState(() {
                      _isEmailSendingDisabled = false;
                    });
                  } else {
                    showErrorSnackBar(context, state.message);
                    // При любой ошибке сбрасываем флаг
                    setState(() {
                      _isEmailSendingDisabled = false;
                    });
                  }
                }
              },
              builder: (context, state) {
                return LoadingOverlay(
                  isLoading: state is AuthLoading,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFFE91E63),
                            child: Text(
                              user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.displayName ?? 'User',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.email ?? '',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          Card(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    user.emailVerified
                                        ? Icons.verified
                                        : Icons.verified_outlined,
                                    color: user.emailVerified
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  title: Text(
                                    user.emailVerified
                                        ? 'Email подтвержден'
                                        : 'Email не подтвержден',
                                  ),
                                  subtitle: Text(
                                    user.emailVerified
                                        ? 'Ваш email подтвержден'
                                        : 'Пожалуйста, подтвердите ваш email адрес',
                                  ),
                                  trailing: !user.emailVerified
                                      ? TextButton(
                                          onPressed: _isEmailSendingDisabled ? null : _handleSendVerification,
                                          child: Text(
                                            _isEmailSendingDisabled && _lastEmailSentTime != null
                                                ? 'Подождите...'
                                                : 'Отправить',
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Card(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text('Редактировать профиль'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => context.push('/edit-profile'),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.favorite_outline),
                                  title: const Text('Мои избранные'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => context.push('/favorites'),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.settings_outlined),
                                  title: const Text('Настройки'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => context.push('/settings'),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.logout, color: Colors.red),
                                  title: const Text(
                                    'Выйти',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onTap: _handleLogout,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

