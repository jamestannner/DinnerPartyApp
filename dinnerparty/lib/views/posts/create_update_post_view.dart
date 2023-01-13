import 'package:dinnerparty/services/auth/auth_service.dart';
import 'package:dinnerparty/services/db/local/post_service.dart';
import 'package:dinnerparty/utilities/generics/get_arguments.dart';
import 'package:flutter/material.dart';

class CreateUpdatePostView extends StatefulWidget {
  const CreateUpdatePostView({super.key});

  @override
  State<CreateUpdatePostView> createState() => _CreateUpdatePostViewState();
}

class _CreateUpdatePostViewState extends State<CreateUpdatePostView> {
  LocalDatabasePost? _post;
  late final PostsService _postsService;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _postsService = PostsService();
    _textController = TextEditingController();
  }

  void _textControllerListener() async {
    final post = _post;
    if (post == null) return;
    final text = _textController.text;
    await _postsService.updatePost(
      post: post,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<LocalDatabasePost> createOrGetExistingNote(
    BuildContext buildContext,
  ) async {
    final widgetPost = context.getArgument<LocalDatabasePost>();

    if (widgetPost != null) {
      _post = widgetPost;
      _textController.text = widgetPost.post;
      return widgetPost;
    }

    final existingPost = _post;
    if (existingPost != null) {
      return existingPost;
    } else {
      final currentUser = AuthService.firebase().currentUser!;
      final id = currentUser.id!;
      final owner = await _postsService.getUser(email: id);
      final newPost = await _postsService.createPost(author: owner);
      _post = newPost;
      return newPost;
    }
  }

  void _deletePostIfTextIsEmpty() {
    final post = _post;
    if (_textController.text.isEmpty && post != null) {
      _postsService.deletePost(id: post.id);
    }
  }

  void _savePostIfTextNotEmpty() {
    final post = _post;
    final text = _textController.text;
    if (_textController.text.isNotEmpty && post != null) {
      _postsService.updatePost(
        post: post,
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
