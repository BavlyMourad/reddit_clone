import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key, required this.name});

  final String name;

  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools');
  }

  void joinOrLeaveCommunity(
    WidgetRef ref,
    CommunityModel communityModel,
    BuildContext context,
  ) {
    ref
        .read(communityControllerProvider.notifier)
        .joinOrLeaveCommunity(communityModel, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      body: ref.watch(getCommunityByNameProvider(name)).when(
            data: (community) {
              return SafeArea(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 200.0,
                        floating: true,
                        snap: true,
                        flexibleSpace: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                community.banner,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Align(
                                alignment: Alignment.topLeft,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    community.avatar,
                                  ),
                                  radius: 35.0,
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'r/${community.name}',
                                    style: const TextStyle(
                                      fontSize: 19.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (!isGuest)
                                    OutlinedButton(
                                      onPressed: () =>
                                          community.mods.contains(user.uid)
                                              ? navigateToModTools(context)
                                              : joinOrLeaveCommunity(
                                                  ref,
                                                  community,
                                                  context,
                                                ),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20.0,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 25.0,
                                        ),
                                      ),
                                      child: community.mods.contains(user.uid)
                                          ? const Text('Mod Tools')
                                          : community.members.contains(user.uid)
                                              ? const Text('Joined')
                                              : const Text('Join'),
                                    ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child:
                                    Text('${community.members.length} members'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ];
                  },
                  body:
                      ref.watch(getCommunityPostsProvider(community.name)).when(
                            data: (posts) {
                              return ListView.builder(
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  final post = posts[index];

                                  return PostCard(post: post);
                                },
                              );
                            },
                            error: (error, stackTrace) =>
                                ErrorText(error: error.toString()),
                            loading: () => const Loader(),
                          ),
                ),
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
