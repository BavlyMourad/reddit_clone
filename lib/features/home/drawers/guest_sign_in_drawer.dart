import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/sign_in_button.dart';

class GuestSignInDrawer extends ConsumerWidget {
  const GuestSignInDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SignInButton(),
          ],
        ),
      ),
    );
  }
}
