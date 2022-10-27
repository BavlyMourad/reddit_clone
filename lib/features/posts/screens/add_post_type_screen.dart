import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/posts/controller/posts_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/theme/pallete.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  const AddPostTypeScreen({super.key, required this.postType});

  final String postType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descirptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  File? postFile;

  List<CommunityModel> communities = [];
  CommunityModel? selectedCommunity;

  void selectPostImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        postFile = File(res.files.first.path!);
      });
    }
  }

  void addPost() {
    if (titleController.text.isNotEmpty) {
      if (widget.postType == 'Image' && postFile != null) {
        ref.read(postsControllerProvider.notifier).addPost(
              context: context,
              title: titleController.text.trim(),
              selectedCommunity: selectedCommunity ?? communities[0],
              postType: widget.postType,
              imageFile: postFile,
            );
      } else if (widget.postType == 'Text') {
        ref.read(postsControllerProvider.notifier).addPost(
              context: context,
              title: titleController.text.trim(),
              selectedCommunity: selectedCommunity ?? communities[0],
              postType: widget.postType,
              description: descirptionController.text.trim(),
            );
      } else if (widget.postType == 'Link' && linkController.text.isNotEmpty) {
        ref.read(postsControllerProvider.notifier).addPost(
              context: context,
              title: titleController.text.trim(),
              selectedCommunity: selectedCommunity ?? communities[0],
              postType: widget.postType,
              link: linkController.text.trim(),
            );
      } else {
        showSnackBar(context, 'Please provide ${widget.postType}');
      }
    } else {
      showSnackBar(context, 'Please enter a title');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descirptionController.dispose();
    linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postsControllerProvider);

    final isImagePost = widget.postType == 'Image';
    final isTextPost = widget.postType == 'Text';
    final isLinkPost = widget.postType == 'Link';

    return Scaffold(
      appBar: AppBar(
        title: Text('Post ${widget.postType}'),
        actions: [
          TextButton(
            onPressed: addPost,
            child: const Text('Post'),
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'Title',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                    maxLength: 30,
                  ),
                  const SizedBox(height: 10.0),
                  if (isImagePost)
                    GestureDetector(
                      onTap: selectPostImage,
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
                          child: postFile != null
                              ? Image.file(postFile!)
                              : const Center(
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40.0,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  if (isTextPost)
                    TextField(
                      controller: descirptionController,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Description',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                      maxLines: 5,
                    ),
                  if (isLinkPost)
                    TextField(
                      controller: linkController,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Link',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                    ),
                  const SizedBox(height: 25.0),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text('Select Community'),
                  ),
                  ref.watch(userCommunitiesProvider).when(
                        data: (data) {
                          communities = data;

                          if (data.isEmpty) {
                            return const SizedBox();
                          }

                          return DropdownButton(
                            value: selectedCommunity ?? data[0],
                            items: data.map(
                              (community) {
                                return DropdownMenuItem(
                                  value: community,
                                  child: Text(community.name),
                                );
                              },
                            ).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCommunity = value;
                              });
                            },
                          );
                        },
                        error: (error, stackTrace) =>
                            ErrorText(error: error.toString()),
                        loading: () => const Loader(),
                      ),
                ],
              ),
            ),
    );
  }
}
