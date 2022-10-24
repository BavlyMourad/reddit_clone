// loggedOut
// loggedIn

import 'package:flutter/material.dart';
import 'package:reddit_clone/features/auth/screens/login_screen.dart';
import 'package:reddit_clone/features/community/screens/community_screen.dart';
import 'package:reddit_clone/features/community/screens/create_community_screen.dart';
import 'package:reddit_clone/features/community/screens/edit_community_screen.dart';
import 'package:reddit_clone/features/community/screens/mod_tools_screen.dart';
import 'package:reddit_clone/features/home/screens/home_screen.dart';
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
        child: HomeScreen(),
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
  },
);
