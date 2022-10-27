import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:reddit_clone/core/type_defs.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/post_model.dart';

final communityRepositoryProvider = Provider((ref) {
  final firestore = ref.watch(firestoreProvider);

  return CommunityRepository(firestore: firestore);
});

class CommunityRepository {
  final FirebaseFirestore _firestore;

  CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);
  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  FutureVoid createCommunity(CommunityModel communityModel) async {
    try {
      var communityDoc = await _communities.doc(communityModel.name).get();

      if (communityDoc.exists) {
        // throw 'Community with this name already exists';
        return left(Failure('Community with this name already exists'));
      }

      // We didn't use await _communities.doc.... since it is void
      // And the function createCommunity is void so we improved performance
      // By not using it
      return right(
        _communities.doc(communityModel.name).set(communityModel.toMap()),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid joinCommunity(String communityName, String userId) async {
    try {
      final result = _communities.doc(communityName).update({
        'members': FieldValue.arrayUnion([userId]),
      });

      return right(result);
    } on FirebaseException catch (e) {
      return left(Failure(e.message.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveCommunity(String communityName, String userId) async {
    try {
      final result = _communities.doc(communityName).update({
        'members': FieldValue.arrayRemove([userId]),
      });

      return right(result);
    } on FirebaseException catch (e) {
      return left(Failure(e.message.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<CommunityModel>> getUserCommunities(String uid) {
    // Check if members field in community contains uid
    return _communities
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      List<CommunityModel> communities = [];

      for (var doc in event.docs) {
        communities.add(
          CommunityModel.fromMap(doc.data() as Map<String, dynamic>),
        );
      }

      return communities;
    });
  }

  Stream<CommunityModel> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map((event) {
      return CommunityModel.fromMap(event.data() as Map<String, dynamic>);
    });
  }

  FutureVoid editCommunity(CommunityModel communityModel) async {
    try {
      return right(
        _communities.doc(communityModel.name).update(communityModel.toMap()),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<List<CommunityModel>> searchCommunity(String query) async {
    return _communities
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(query.codeUnitAt(query.length - 1) + 1),
        )
        .snapshots()
        .map((event) {
      List<CommunityModel> communities = [];

      for (var community in event.docs) {
        communities.add(
          CommunityModel.fromMap(community.data() as Map<String, dynamic>),
        );
      }

      return communities;
    }).first;
  }

  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      return right(
        _communities.doc(communityName).update({
          // Dont use fieldarray.union since we are replacing the whole list
          'mods': uids,
        }),
      );
    } on FirebaseException catch (e) {
      return left(Failure(e.message.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<List<PostModel>> getCommunityPosts(String communityName) {
    return _posts
        .where('communityName', isEqualTo: communityName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => PostModel.fromMap(e.data() as Map<String, dynamic>),
              )
              .toList(),
        )
        .first;
  }
}
