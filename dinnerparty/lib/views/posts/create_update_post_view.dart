import 'package:dinnerparty/services/auth/auth_service.dart';
import 'package:dinnerparty/services/db/cloud/cloud_post.dart';
import 'package:dinnerparty/services/db/cloud/firebase_cloud_storage.dart';
import 'package:dinnerparty/utilities/dialogs/cannot_share_empty_dialog.dart';
import 'package:dinnerparty/utilities/generics/get_arguments.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdatePostView extends StatefulWidget {
  const CreateUpdatePostView({super.key});

  @override
  State<CreateUpdatePostView> createState() => _CreateUpdatePostViewState();
}

class _CreateUpdatePostViewState extends State<CreateUpdatePostView> {
  CloudPost? _post;
  late final FirebaseCloudStorage _postsService;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _postsService = FirebaseCloudStorage();
    _textController = TextEditingController();
  }

  void _textControllerListener() async {
    final post = _post;
    if (post == null) return;
    final text = _textController.text;
    await _postsService.updatePost(
      documentId: post.documentId,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudPost> createOrGetExistingNote(
    BuildContext buildContext,
  ) async {
    final widgetPost = context.getArgument<CloudPost>();

    if (widgetPost != null) {
      _post = widgetPost;
      _textController.text = widgetPost.text;
      return widgetPost;
    }

    final existingPost = _post;
    if (existingPost != null) {
      return existingPost;
    } else {
      final currentUser = AuthService.firebase().currentUser!;
      final userId = currentUser.id;
      final newPost = await _postsService.createNewPost(ownerUserId: userId);
      _post = newPost;
      return newPost;
    }
  }

  void _deletePostIfTextIsEmpty() {
    final post = _post;
    if (_textController.text.isEmpty && post != null) {
      _postsService.deletePost(documentId: post.documentId);
    }
  }

  void _savePostIfTextNotEmpty() {
    final post = _post;
    final text = _textController.text;
    if (_textController.text.isNotEmpty && post != null) {
      _postsService.updatePost(
        documentId: post.documentId,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deletePostIfTextIsEmpty();
    _savePostIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_post == null || text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Start typing your note here...',
                  ));
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
