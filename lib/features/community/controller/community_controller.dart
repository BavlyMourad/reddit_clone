import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/repository/community_repository.dart';
import 'package:reddit_clone/models/community_model.dart';
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

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  final communityController = ref.watch(communityControllerProvider.notifier);

  return communityController.getCommunityByName(name);
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

  Stream<CommunityModel> getCommunityByName(String name) {
    final communityRepository = _ref.read(communityRepositoryProvider);

    return communityRepository.getCommunityByName(name);
  }
}
