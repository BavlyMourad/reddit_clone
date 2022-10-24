import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/models/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(ref: ref);
});

final authStateChangerProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);

  return authController.authStateChange;
});

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);

  return authController.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final Ref _ref;

  AuthController({required Ref ref})
      : _ref = ref,
        super(false); // Represents isLoading

  Stream<User?> get authStateChange {
    final authRepository = _ref.read(authRepositoryProvider);

    return authRepository.authStateChange;
  }

  void signInWithGoogle(BuildContext context) async {
    state = true; // Represents isLoading

    final authRepository = _ref.read(authRepositoryProvider);

    final user = await authRepository.signWithGoogle();

    state = false;

    user.fold(
      (failure) => showSnackBar(context, failure.message),
      (userModel) {
        _ref.read(userProvider.notifier).update((state) => userModel);
      },
    );
  }

  Stream<UserModel> getUserData(String uid) {
    return _ref.read(authRepositoryProvider).getUserData(uid);
  }

  void logout() async {
    final authRepository = _ref.read(authRepositoryProvider);

    authRepository.logout();
  }
}
