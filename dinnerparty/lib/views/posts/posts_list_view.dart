import 'package:dinnerparty/services/db/local/post_service.dart';
import 'package:dinnerparty/utilities/dialogs/delete_dialog.dart';
import 'package:flutter/material.dart';

typedef PostCallback = void Function(LocalDatabasePost post);

class PostsListView extends StatelessWidget {
  final List<LocalDatabasePost> posts;
  final PostCallback onDeletePost;
  final PostCallback onTap;

  const PostsListView({
    super.key,
    required this.posts,
    required this.onDeletePost,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final thisPost = posts[index];
        return ListTile(
          onTap: () {
            onTap(thisPost);
          },
          title: Text(
            thisPost.post,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: (() async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeletePost(thisPost);
              }
            }),
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
