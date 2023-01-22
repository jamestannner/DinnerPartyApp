import 'package:dinnerparty/modules/posts/data/cloud_post.dart';
import 'package:dinnerparty/modules/posts/ui/delete_dialog.dart';
import 'package:flutter/material.dart';

typedef PostCallback = void Function(CloudPost post);

class PostsListView extends StatelessWidget {
  final Iterable<CloudPost> posts;
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
        final thisPost = posts.elementAt(index);
        return ListTile(
          onTap: () {
            onTap(thisPost);
          },
          title: Text(
            thisPost.text,
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
