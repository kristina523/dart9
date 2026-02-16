import 'package:cosmetics_catalog/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String displayName);
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<void> sendEmailVerification();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateProfile({String? displayName, String? email, String? password});
  Future<void> updatePassword(String currentPassword, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl(this.firebaseAuth);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw Exception('User is null');
      }
      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      if (e.toString().contains('network') || e.toString().contains('Network')) {
        throw Exception('Ошибка сети. Проверьте подключение к интернету.');
      }
      throw Exception('Не удалось войти в систему: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register(String email, String password, String displayName) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw Exception('User is null');
      }
      
      // Update display name
      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();
      final updatedUser = firebaseAuth.currentUser;
      
      if (updatedUser == null) {
        throw Exception('User is null');
      }
      
      // Send email verification на русском языке
      firebaseAuth.setLanguageCode('ru');
      await updatedUser.sendEmailVerification(
        ActionCodeSettings(
          url: 'https://cosmetics-catalog-3c357.firebaseapp.com/__/auth/action',
          handleCodeInApp: false,
        ),
      );
      
      return UserModel.fromFirebaseUser(updatedUser);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      if (e.toString().contains('network') || e.toString().contains('Network')) {
        throw Exception('Ошибка сети. Проверьте подключение к интернету.');
      }
      throw Exception('Не удалось зарегистрироваться: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      // Устанавливаем язык на русский перед отправкой письма
      firebaseAuth.setLanguageCode('ru');
      await firebaseAuth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://cosmetics-catalog-3c357.firebaseapp.com/__/auth/action',
          handleCodeInApp: false,
        ),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      if (e.toString().contains('network') || e.toString().contains('Network')) {
        throw Exception('Ошибка сети. Проверьте подключение к интернету.');
      }
      throw Exception('Не удалось отправить письмо для сброса пароля: ${e.toString()}');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }
      // Отправляем письмо на русском языке
      await user.sendEmailVerification(
        ActionCodeSettings(
          url: 'https://cosmetics-catalog-3c357.firebaseapp.com/__/auth/action',
          handleCodeInApp: false,
        ),
      );
      // Устанавливаем язык интерфейса Firebase на русский
      firebaseAuth.setLanguageCode('ru');
    } catch (e) {
      if (e.toString().contains('too-many-requests')) {
        throw Exception('Слишком много запросов. Пожалуйста, подождите некоторое время перед повторной попыткой.');
      }
      if (e.toString().contains('network') || e.toString().contains('Network')) {
        throw Exception('Ошибка сети. Проверьте подключение к интернету.');
      }
      throw Exception('Не удалось отправить письмо для подтверждения email: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    } catch (e) {
      throw Exception('Get current user failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile({String? displayName, String? email, String? password}) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }

      // Обновляем displayName если указан
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }

      // Обновляем email если указан (требует переавторизацию)
      if (email != null && email.isNotEmpty && email != user.email) {
        if (password == null || password.isEmpty) {
          throw Exception('Для изменения email требуется ввести текущий пароль');
        }
        
        // Переавторизуемся перед изменением email
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        
        // Теперь можем изменить email
        await user.updateEmail(email);
        // После изменения email нужно отправить письмо для подтверждения на русском
        firebaseAuth.setLanguageCode('ru');
        await user.sendEmailVerification(
          ActionCodeSettings(
            url: 'https://cosmetics-catalog-3c357.firebaseapp.com/__/auth/action',
            handleCodeInApp: false,
          ),
        );
      }

      // Перезагружаем данные пользователя
      await user.reload();
      final updatedUser = firebaseAuth.currentUser;
      
      if (updatedUser == null) {
        throw Exception('Не удалось обновить профиль');
      }

      return UserModel.fromFirebaseUser(updatedUser);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      if (e.toString().contains('network') || e.toString().contains('Network')) {
        throw Exception('Ошибка сети. Проверьте подключение к интернету.');
      }
      throw Exception('Не удалось обновить профиль: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }

      // Проверяем текущий пароль, переавторизуясь
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Обновляем пароль
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      if (e.toString().contains('network') || e.toString().contains('Network')) {
        throw Exception('Ошибка сети. Проверьте подключение к интернету.');
      }
      throw Exception('Не удалось изменить пароль: ${e.toString()}');
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Пароль слишком слабый.';
      case 'email-already-in-use':
        return 'Аккаунт с таким email уже существует.';
      case 'invalid-email':
        return 'Некорректный email адрес.';
      case 'user-disabled':
        return 'Этот аккаунт был заблокирован.';
      case 'user-not-found':
        return 'Пользователь с таким email не найден.';
      case 'wrong-password':
        return 'Неверный пароль.';
      case 'too-many-requests':
        return 'Слишком много запросов. Пожалуйста, подождите некоторое время перед повторной попыткой.';
      case 'network-request-failed':
        return 'Ошибка сети. Проверьте подключение к интернету.';
      default:
        return 'Произошла ошибка: $code';
    }
  }
}

