import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:reddit_clone/core/type_defs.dart';
import 'package:reddit_clone/models/comment_model.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/post_model.dart';

final postsRepositoryProvider = Provider((ref) {
  final firestore = ref.watch(firestoreProvider);

  return PostsRepository(firestore: firestore);
});

class PostsRepository {
  final FirebaseFirestore _firestore;

  PostsRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);
  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstants.commentsCollection);

  FutureVoid addPost(PostModel postModel) async {
    try {
      final result = _posts.doc(postModel.id).set(postModel.toMap());
      return right(result);
    } on FirebaseException catch (e) {
      return left(Failure(e.message.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<List<PostModel>> fetchUserPosts(List<CommunityModel> communities) {
    return _posts
        .where(
          'communityName',
          whereIn: communities.map((e) => e.name).toList(),
        )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map((e) => PostModel.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        )
        .first;
  }

  FutureVoid deletePost(PostModel postModel) async {
    try {
      return right(_posts.doc(postModel.id).delete());
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void upvote(PostModel postModel, String userId) async {
    if (postModel.downvotes.contains(userId)) {
      _posts.doc(postModel.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    }
    if (postModel.upvotes.contains(userId)) {
      _posts.doc(postModel.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _posts.doc(postModel.id).update({
        'upvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  void downvote(PostModel postModel, String userId) async {
    if (postModel.upvotes.contains(userId)) {
      _posts.doc(postModel.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    }
    if (postModel.downvotes.contains(userId)) {
      _posts.doc(postModel.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _posts.doc(postModel.id).update({
        'downvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Future<PostModel> getPostById(String postId) {
    return _posts
        .doc(postId)
        .snapshots()
        .map((event) => PostModel.fromMap(event.data() as Map<String, dynamic>))
        .first;
  }

  FutureVoid addComment(CommentModel commentModel) async {
    try {
      await _comments.doc(commentModel.id).set(commentModel.toMap());

      return right(
        _posts.doc(commentModel.postId).update({
          'commentCount': FieldValue.increment(1),
        }),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<List<CommentModel>> getPostComments(String postId) {
    return _comments
        .where(
          'postId',
          isEqualTo: postId,
        )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                  (e) => CommentModel.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        )
        .first;
  }
}
