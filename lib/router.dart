// loggedOut
// loggedIn

import 'package:flutter/material.dart';
import 'package:reddit_clone/features/auth/screens/login_screen.dart';
import 'package:reddit_clone/features/community/screens/add_mods_screen.dart';
import 'package:reddit_clone/features/community/screens/community_screen.dart';
import 'package:reddit_clone/features/community/screens/create_community_screen.dart';
import 'package:reddit_clone/features/community/screens/edit_community_screen.dart';
import 'package:reddit_clone/features/community/screens/mod_tools_screen.dart';
import 'package:reddit_clone/features/home/screens/home_screen.dart';
import 'package:reddit_clone/features/posts/screens/add_post_type_screen.dart';
import 'package:reddit_clone/features/posts/screens/comments_screen.dart';
import 'package:reddit_clone/features/user_profile/screens/edit_profile_screen.dart';
import 'package:reddit_clone/features/user_profile/screens/user_profile_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(
  routes: {
    '/': (_) {
      return const MaterialPage(child: LoginScreen());
    },
  },
);

final loggedInRoute = RouteMap(
  routes: {
    '/': (_) {
      return const MaterialPage(
        child: HoomScreen(),
      );
    },
    '/create-community': (_) {
      return const MaterialPage(
        child: CreateCommunityScreen(),
      );
    },
    '/r/:name': (route) {
      return MaterialPage(
        child: CommunityScreen(name: route.pathParameters['name']!),
      );
    },
    '/mod-tools': (_) {
      return const MaterialPage(
        child: ModToolsScreen(),
      );
    },
    '/edit-community': (_) {
      return const MaterialPage(
        child: EditCommunityScreen(),
      );
    },
    '/add-mods': (_) {
      return const MaterialPage(
        child: AddModsScreen(),
      );
    },
    '/u/:uid': (routeData) {
      return MaterialPage(
        child: UserProfileScreen(
          uid: routeData.pathParameters['uid']!,
        ),
      );
    },
    '/edit-profile/:uid': (routeData) {
      return MaterialPage(
        child: EditProfileScreen(
          uid: routeData.pathParameters['uid']!,
        ),
      );
    },
    '/add-post/:type': (routeData) {
      return MaterialPage(
        child: AddPostTypeScreen(
          postType: routeData.pathParameters['type']!,
        ),
      );
    },
    '/post/:postId/comments': (routeData) {
      return MaterialPage(
        child: CommentsScreen(
          postId: routeData.pathParameters['postId']!,
        ),
      );
    },
  },
);
