import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/secure_storage.dart';
import '../models/user.dart';
import 'api_provider.dart';

sealed class AuthState {
  const AuthState();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  const AuthAuthenticated(this.user);
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restoreSession();
    return const AuthLoading();
  }

  Future<void> _restoreSession() async {
    try {
      final token = await SecureStorage.readToken();
      if (token == null) {
        state = const AuthUnauthenticated();
        return;
      }

      final api = ref.read(apiClientProvider);
      final me = await api.get('/auth/me');
      state = AuthAuthenticated(AppUser.fromJson(me));
    } catch (_) {
      try {
        await SecureStorage.clearToken();
      } catch (_) {}
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    final api = ref.read(apiClientProvider);
    final response = await api.post('/auth/login', body: {'email': email, 'password': password});
    await SecureStorage.saveToken(response['token'] as String);
    state = AuthAuthenticated(AppUser.fromJson(response['user'] as Map<String, dynamic>));
  }

  Future<void> register(String name, String email, String password) async {
    final api = ref.read(apiClientProvider);
    final response = await api.post('/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
    });
    await SecureStorage.saveToken(response['token'] as String);
    state = AuthAuthenticated(AppUser.fromJson(response['user'] as Map<String, dynamic>));
  }

  Future<void> logout() async {
    try {
      await ref.read(apiClientProvider).post('/auth/logout');
    } catch (_) {}
    await SecureStorage.clearToken();
    state = const AuthUnauthenticated();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
