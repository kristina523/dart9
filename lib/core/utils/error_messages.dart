// Централизованные сообщения об ошибках на русском языке

class ErrorMessages {
  // Firebase Auth ошибки
  static const String weakPassword = 'Пароль слишком слабый.';
  static const String emailAlreadyInUse = 'Аккаунт с таким email уже существует.';
  static const String invalidEmail = 'Некорректный email адрес.';
  static const String userDisabled = 'Этот аккаунт был заблокирован.';
  static const String userNotFound = 'Пользователь с таким email не найден.';
  static const String wrongPassword = 'Неверный пароль.';
  static const String tooManyRequests = 'Слишком много запросов. Пожалуйста, подождите некоторое время перед повторной попыткой.';
  static const String networkError = 'Ошибка сети. Проверьте подключение к интернету.';
  static const String unknownError = 'Произошла ошибка. Попробуйте еще раз.';

  // Общие ошибки
  static const String emailVerificationFailed = 'Не удалось отправить письмо для подтверждения email. Попробуйте позже.';
  static const String passwordResetFailed = 'Не удалось отправить письмо для сброса пароля. Попробуйте позже.';
  static const String loginFailed = 'Не удалось войти в систему. Проверьте данные.';
  static const String registrationFailed = 'Не удалось зарегистрироваться. Попробуйте еще раз.';
  static const String logoutFailed = 'Не удалось выйти из системы.';

  // Firestore ошибки
  static const String productsLoadFailed = 'Не удалось загрузить продукты.';
  static const String productNotFound = 'Продукт не найден.';
  static const String favoritesLoadFailed = 'Не удалось загрузить избранное.';
  static const String addToFavoritesFailed = 'Не удалось добавить в избранное.';
  static const String removeFromFavoritesFailed = 'Не удалось удалить из избранного.';

  // Валидация
  static const String emptyEmail = 'Пожалуйста, введите email';
  static const String emptyPassword = 'Пожалуйста, введите пароль';
  static const String emptyName = 'Пожалуйста, введите имя';
  static const String invalidEmailFormat = 'Введите корректный email';
  static const String passwordTooShort = 'Пароль должен содержать минимум 6 символов';
  static const String passwordsDoNotMatch = 'Пароли не совпадают';

  // Успешные операции
  static const String registrationSuccess = 'Регистрация успешна! Проверьте почту для подтверждения email.';
  static const String emailVerificationSent = 'Письмо для подтверждения отправлено! Проверьте почту.';
  static const String passwordResetSent = 'Письмо для сброса пароля отправлено! Проверьте почту.';
  static const String addedToFavorites = 'Добавлено в избранное!';
  static const String removedFromFavorites = 'Удалено из избранного';
  static const String dataSaved = 'Данные сохранены';

  // Получить сообщение об ошибке Firebase по коду
  static String getFirebaseAuthError(String code) {
    switch (code) {
      case 'weak-password':
        return weakPassword;
      case 'email-already-in-use':
        return emailAlreadyInUse;
      case 'invalid-email':
        return invalidEmail;
      case 'user-disabled':
        return userDisabled;
      case 'user-not-found':
        return userNotFound;
      case 'wrong-password':
        return wrongPassword;
      case 'too-many-requests':
        return tooManyRequests;
      case 'network-request-failed':
        return networkError;
      default:
        return '$unknownError ($code)';
    }
  }
}

