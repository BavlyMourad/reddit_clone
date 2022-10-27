import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/providers/storage_repository_provider.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/posts/repository/posts_repository.dart';
import 'package:reddit_clone/models/comment_model.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final postsControllerProvider = StateNotifierProvider<PostsController, bool>(
  (ref) {
    return PostsController(ref: ref);
  },
);

final userPostsProvider =
    FutureProvider.family((ref, List<CommunityModel> communities) {
  final postsController = ref.watch(postsControllerProvider.notifier);

  return postsController.fetchUserPosts(communities);
});

final getPostByIdProvider = FutureProvider.family((ref, String postId) {
  final postsController = ref.watch(postsControllerProvider.notifier);

  return postsController.getPostById(postId);
});

final getPostCommentsProvider = FutureProvider.family((ref, String postId) {
  final postsController = ref.watch(postsControllerProvider.notifier);

  return postsController.getPostComments(postId);
});

class PostsController extends StateNotifier<bool> {
  final Ref _ref;

  PostsController({required Ref ref})
      : _ref = ref,
        super(false); // isLoading

  void addPost({
    required BuildContext context,
    required String title,
    required CommunityModel selectedCommunity,
    required String postType,
    String? description,
    String? link,
    File? imageFile,
  }) async {
    state = true; // isLoading

    String postId = const Uuid().v1();

    final user = _ref.read(userProvider)!;
    if (postType == 'Image') {
      final storageRepository = _ref.read(storageRepositoryProvider);
      final imageRes = await storageRepository.storeFile(
        path: 'posts/${selectedCommunity.name}',
        id: postId,
        file: imageFile,
      );

      imageRes.fold(
        (failure) {
          showSnackBar(context, failure.message);
          return;
        },
        (downloadUrl) => link = downloadUrl,
      );
    }

    final PostModel postModel = PostModel(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      postType: postType,
      createdAt: DateTime.now(),
      awards: [],
      description: description ?? '',
      link: link ?? '',
    );

    final postsRepository = _ref.read(postsRepositoryProvider);

    final res = await postsRepository.addPost(postModel);

    state = false;

    // _ref.invalidate(postsControllerProvider);
    _ref.invalidate(userPostsProvider);

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (success) {
        showSnackBar(context, 'Post Created Successfully');
        Routemaster.of(context).pop();
      },
    );
  }

  Future<List<PostModel>> fetchUserPosts(List<CommunityModel> communities) {
    final postsRepository = _ref.read(postsRepositoryProvider);

    if (communities.isNotEmpty) {
      return postsRepository.fetchUserPosts(communities);
    }

    return Future.value([]);
  }

  void deletePost(BuildContext context, PostModel postModel) async {
    final postsRepository = _ref.read(postsRepositoryProvider);

    final res = await postsRepository.deletePost(postModel);

    _ref.invalidate(userPostsProvider);

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (success) => showSnackBar(context, 'Post Deleted Successfully'),
    );
  }

  void upvote(PostModel postModel) async {
    final postsRepository = _ref.read(postsRepositoryProvider);
    final uid = _ref.read(userProvider)!.uid;

    postsRepository.upvote(postModel, uid);

    _ref.invalidate(userPostsProvider);
  }

  void downvote(PostModel postModel) async {
    final postsRepository = _ref.read(postsRepositoryProvider);
    final uid = _ref.read(userProvider)!.uid;

    postsRepository.downvote(postModel, uid);

    _ref.invalidate(userPostsProvider);
  }

  Future<PostModel> getPostById(String postId) {
    final postsRepository = _ref.read(postsRepositoryProvider);

    return postsRepository.getPostById(postId);
  }

  void addComment(
      BuildContext context, String comment, PostModel postModel) async {
    final postsRepository = _ref.read(postsRepositoryProvider);
    final user = _ref.read(userProvider)!;

    String commentId = const Uuid().v1();

    CommentModel commentModel = CommentModel(
      id: commentId,
      text: comment,
      createdAt: DateTime.now(),
      postId: postModel.id,
      username: user.name,
      profilePic: user.profilePicture,
      uid: user.uid,
    );

    final res = await postsRepository.addComment(commentModel);

    _ref.invalidate(getPostCommentsProvider);
    _ref.invalidate(getPostByIdProvider);
    _ref.invalidate(userPostsProvider);

    res.fold(
      (failure) => showSnackBar(context, failure.message),
      (success) => null,
    );
  }

  Future<List<CommentModel>> getPostComments(String postId) {
    final postsRepository = _ref.read(postsRepositoryProvider);

    return postsRepository.getPostComments(postId);
  }
}
