import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/storage_repository_provider.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/repository/community_repository.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:routemaster/routemaster.dart';

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>(
  (ref) {
    return CommunityController(ref: ref);
  },
);

final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);

  return communityController.getUserCommunities();
});

final getCommunityByNameProvider = FutureProvider.family((ref, String name) {
  final communityController = ref.watch(communityControllerProvider.notifier);

  return communityController.getCommunityByName(name);
});

final communityProvider = StateProvider<CommunityModel?>((ref) => null);

final searchCommunityProvider = FutureProvider.family(
  (ref, String query) {
    final communityController = ref.watch(communityControllerProvider.notifier);

    return communityController.searchCommunity(query);
  },
  name: 'searchCommunityProvider',
);

final getCommunityPostsProvider =
    FutureProvider.family((ref, String communityName) {
  final communityController = ref.watch(communityControllerProvider.notifier);

  return communityController.getCommunityPosts(communityName);
});

class CommunityController extends StateNotifier<bool> {
  final Ref _ref;

  CommunityController({required Ref ref})
      : _ref = ref,
        super(false); // isLoading

  void createCommunity(BuildContext context, String name) async {
    state = true; // isLoading

    final uid = _ref.read(userProvider)?.uid ?? 'Unknown';
    final communityRepository = _ref.read(communityRepositoryProvider);

    CommunityModel communityModel = CommunityModel(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );

    final result = await communityRepository.createCommunity(communityModel);

    state = false;

    result.fold(
      (failure) => showSnackBar(context, failure.message),
      (r) {
        showSnackBar(context, 'Community created successfully');

        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<CommunityModel>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.uid;
    final communityRepository = _ref.read(communityRepositoryProvider);

    return communityRepository.getUserCommunities(uid);
  }

  Future<CommunityModel> getCommunityByName(String name) async {
    final communityRepository = _ref.read(communityRepositoryProvider);

    final community = await communityRepository.getCommunityByName(name).first;

    _ref.read(communityProvider.notifier).update((state) => community);

    return community;
  }

  void editCommunity({
    required File? avatarFile,
    required File? bannerFile,
    required BuildContext context,
    required CommunityModel communityModel,
  }) async {
    state = true; // isLoading

    final storageRepository = _ref.read(storageRepositoryProvider);
    final communityRepository = _ref.read(communityRepositoryProvider);

    if (avatarFile != null) {
      // communities/avatar/memes
      final res = await storageRepository.storeFile(
        path: 'communities/avatar',
        id: communityModel.name,
        file: avatarFile,
      );

      res.fold(
        (failure) => showSnackBar(context, failure.message),
        (downloadUrl) {
          communityModel = communityModel.copyWith(avatar: downloadUrl);
        },
      );
    }

    if (bannerFile != null) {
      // communities/banner/memes
      final res = await storageRepository.storeFile(
        path: 'communities/banner',
        id: communityModel.name,
        file: bannerFile,
      );

      res.fold(
        (failure) => showSnackBar(context, failure.message),
        (downloadUrl) {
          communityModel = communityModel.copyWith(banner: downloadUrl);
        },
      );
    }

    final res = await communityRepository.editCommunity(communityModel);

    state = false;

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (r) {
        _ref.invalidate(getCommunityByNameProvider);
        Routemaster.of(context).pop();
      },
    );
  }

  Future<List<CommunityModel>> searchCommunity(String query) {
    final communityRepository = _ref.read(communityRepositoryProvider);

    return communityRepository.searchCommunity(query);
  }

  void joinOrLeaveCommunity(
    CommunityModel communityModel,
    BuildContext context,
  ) async {
    final user = _ref.read(userProvider)!;
    final communityRepository = _ref.read(communityRepositoryProvider);

    Either<Failure, void> res;

    if (communityModel.members.contains(user.uid)) {
      res = await communityRepository.leaveCommunity(
        communityModel.name,
        user.uid,
      );
    } else {
      res = await communityRepository.joinCommunity(
        communityModel.name,
        user.uid,
      );
    }

    _ref.invalidate(getCommunityByNameProvider);

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (r) {
        if (communityModel.members.contains(user.uid)) {
          showSnackBar(context, 'You Left ${communityModel.name}');
        } else {
          showSnackBar(context, 'You Joined ${communityModel.name}');
        }
      },
    );
  }

  void addMods(
      String communityName, List<String> uids, BuildContext context) async {
    final communityRepository = _ref.read(communityRepositoryProvider);

    final res = await communityRepository.addMods(communityName, uids);

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  Future<List<PostModel>> getCommunityPosts(String communityName) {
    final communityRepository = _ref.read(communityRepositoryProvider);

    _ref.invalidate(getCommunityPostsProvider);

    return communityRepository.getCommunityPosts(communityName);
  }
}
