import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cosmetics_catalog/features/auth/domain/entities/user_entity.dart';
import 'package:cosmetics_catalog/features/auth/domain/repositories/auth_repository.dart';
import 'package:cosmetics_catalog/features/auth/domain/usecases/login_usecase.dart';
import 'package:cosmetics_catalog/features/auth/domain/usecases/register_usecase.dart';
import 'package:cosmetics_catalog/features/auth/domain/usecases/logout_usecase.dart';
import 'package:cosmetics_catalog/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:cosmetics_catalog/features/auth/domain/usecases/send_email_verification_usecase.dart';
import 'package:cosmetics_catalog/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:cosmetics_catalog/features/auth/domain/usecases/update_password_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final SendEmailVerificationUseCase sendEmailVerificationUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.resetPasswordUseCase,
    required this.sendEmailVerificationUseCase,
    required this.updateProfileUseCase,
    required this.updatePasswordUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<ResetPasswordEvent>(_onResetPassword);
    on<SendEmailVerificationEvent>(_onSendEmailVerification);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdatePasswordEvent>(_onUpdatePassword);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(event.email, event.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerUseCase(event.email, event.password, event.displayName);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await logoutUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onResetPassword(ResetPasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await resetPasswordUseCase(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(PasswordResetSent()),
    );
  }

  Future<void> _onSendEmailVerification(SendEmailVerificationEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await sendEmailVerificationUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(EmailVerificationSent()),
    );
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await updateProfileUseCase(
      displayName: event.displayName,
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        emit(ProfileUpdated(user));
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onUpdatePassword(UpdatePasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await updatePasswordUseCase(event.currentPassword, event.newPassword);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(PasswordUpdated()),
    );
  }
}

