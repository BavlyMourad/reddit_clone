import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/providers/storage_repository_provider.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/user_profile/repository/user_profile_repository.dart';
import 'package:reddit_clone/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>(
  (ref) {
    return UserProfileController(ref: ref);
  },
);

class UserProfileController extends StateNotifier<bool> {
  final Ref _ref;

  UserProfileController({required Ref ref})
      : _ref = ref,
        super(false); // isLoading

  void editProfile({
    required File? avatarFile,
    required File? bannerFile,
    required BuildContext context,
    required String name,
  }) async {
    state = true; // isLoading

    final storageRepository = _ref.read(storageRepositoryProvider);
    final userProfileRepository = _ref.read(userProfileRepositoryProvider);

    UserModel user = _ref.read(userProvider)!;

    if (avatarFile != null) {
      // users/avatar/id
      final res = await storageRepository.storeFile(
        path: 'users/profile',
        id: user.uid,
        file: avatarFile,
      );

      res.fold(
        (failure) => showSnackBar(context, failure.message),
        (downloadUrl) => user = user.copyWith(profilePicture: downloadUrl),
      );
    }

    if (bannerFile != null) {
      // users/banner/id
      final res = await storageRepository.storeFile(
        path: 'users/banner',
        id: user.uid,
        file: bannerFile,
      );

      res.fold(
        (failure) => showSnackBar(context, failure.message),
        (downloadUrl) => user = user.copyWith(banner: downloadUrl),
      );
    }

    user = user.copyWith(name: name);

    final res = await userProfileRepository.editProfile(user);

    state = false;

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (r) {
        _ref.read(userProvider.notifier).update((state) => user);
        Routemaster.of(context).pop();
      },
    );
  }
}
