import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/theme/pallete.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  const EditCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? avatarFile;

  void selectBannerImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectAvatarImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        avatarFile = File(res.files.first.path!);
      });
    }
  }

  void save(CommunityModel communityModel) {
    ref.read(communityControllerProvider.notifier).editCommunity(
          avatarFile: avatarFile,
          bannerFile: bannerFile,
          context: context,
          communityModel: communityModel,
        );
  }

  @override
  Widget build(BuildContext context) {
    final community = ref.watch(communityProvider)!;
    final isLoading = ref.watch(communityControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      backgroundColor: currentTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit Community'),
        actions: [
          TextButton(
            onPressed: () => save(community),
            child: const Text('Save'),
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 200.0,
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: selectBannerImage,
                      child: DottedBorder(
                        color: currentTheme.textTheme.bodyText2!.color!,
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(10.0),
                        dashPattern: const [10, 4],
                        strokeCap: StrokeCap.round,
                        child: Container(
                          width: double.infinity,
                          height: 150.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: bannerFile != null
                              ? Image.file(bannerFile!)
                              : community.banner.isEmpty ||
                                      community.banner ==
                                          Constants.bannerDefault
                                  ? const Center(
                                      child: Icon(Icons.camera_alt_outlined,
                                          size: 40.0),
                                    )
                                  : Image.network(community.banner),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20.0,
                      left: 20.0,
                      child: GestureDetector(
                        onTap: selectAvatarImage,
                        child: avatarFile != null
                            ? CircleAvatar(
                                backgroundImage: FileImage(avatarFile!),
                                radius: 32.0,
                              )
                            : CircleAvatar(
                                backgroundImage: NetworkImage(community.avatar),
                                radius: 32.0,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
