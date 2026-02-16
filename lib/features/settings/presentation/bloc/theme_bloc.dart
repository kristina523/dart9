import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeBloc() : super(ThemeInitial()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  Future<void> _onLoadTheme(LoadThemeEvent event, Emitter<ThemeState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      emit(ThemeLoaded(isDark: isDark));
    } catch (e) {
      emit(ThemeLoaded(isDark: false));
    }
  }

  Future<void> _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newIsDark = !(state is ThemeLoaded ? (state as ThemeLoaded).isDark : false);
      await prefs.setBool(_themeKey, newIsDark);
      emit(ThemeLoaded(isDark: newIsDark));
    } catch (e) {
      // Если ошибка, просто переключаем без сохранения
      final newIsDark = !(state is ThemeLoaded ? (state as ThemeLoaded).isDark : false);
      emit(ThemeLoaded(isDark: newIsDark));
    }
  }
}

