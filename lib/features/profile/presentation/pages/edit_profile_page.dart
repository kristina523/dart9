import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cosmetics_catalog/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cosmetics_catalog/core/widgets/loading_overlay.dart';
import 'package:cosmetics_catalog/core/widgets/error_snackbar.dart';
import 'package:cosmetics_catalog/core/widgets/success_snackbar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPasswordSection = false;
  bool _emailChanged = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _emailPasswordController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitProfile() {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final displayName = _nameController.text.trim();
      final email = _emailController.text.trim();

      // Проверяем, изменились ли данные
      final nameChanged = displayName != (user.displayName ?? '');
      final emailChanged = email != (user.email ?? '');

      // Если email изменился, требуется пароль
      if (emailChanged && _emailPasswordController.text.isEmpty) {
        showErrorSnackBar(context, 'Для изменения email требуется ввести текущий пароль');
        return;
      }

      if (nameChanged || emailChanged) {
        context.read<AuthBloc>().add(
              UpdateProfileEvent(
                displayName: nameChanged ? displayName : null,
                email: emailChanged ? email : null,
                password: emailChanged ? _emailPasswordController.text : null,
              ),
            );
      }
    }
  }

  void _submitPassword() {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        showErrorSnackBar(context, 'Новые пароли не совпадают');
        return;
      }

      context.read<AuthBloc>().add(
            UpdatePasswordEvent(
              _currentPasswordController.text,
              _newPasswordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            showSuccessSnackBar(context, 'Профиль успешно обновлен!');
            if (state.user.email != user?.email) {
              showSuccessSnackBar(
                context,
                'Письмо для подтверждения нового email отправлено на почту',
              );
            }
            context.pop();
          } else if (state is PasswordUpdated) {
            showSuccessSnackBar(context, 'Пароль успешно изменен!');
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
            setState(() {
              _showPasswordSection = false;
            });
          } else if (state is AuthError) {
            showErrorSnackBar(context, state.message);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return LoadingOverlay(
              isLoading: isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Секция редактирования профиля
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Основная информация',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Имя',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Введите имя';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.email),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  final user = FirebaseAuth.instance.currentUser;
                                  setState(() {
                                    _emailChanged = value.trim() != (user?.email ?? '');
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Введите email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Некорректный email';
                                  }
                                  return null;
                                },
                              ),
                              if (_emailChanged) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _emailPasswordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Текущий пароль (для изменения email)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.lock),
                                    helperText: 'Для изменения email требуется подтвердить пароль',
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (_emailChanged && (value == null || value.isEmpty)) {
                                      return 'Введите текущий пароль для изменения email';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: isLoading ? null : _submitProfile,
                                child: const Text('Сохранить изменения'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Секция изменения пароля
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Изменить пароль',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _showPasswordSection
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showPasswordSection = !_showPasswordSection;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (_showPasswordSection) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _currentPasswordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Текущий пароль',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.lock),
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Введите текущий пароль';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _newPasswordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Новый пароль',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Введите новый пароль';
                                    }
                                    if (value.length < 6) {
                                      return 'Пароль должен содержать минимум 6 символов';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Подтвердите новый пароль',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Подтвердите новый пароль';
                                    }
                                    if (value != _newPasswordController.text) {
                                      return 'Пароли не совпадают';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: isLoading ? null : _submitPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                  ),
                                  child: const Text('Изменить пароль'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

