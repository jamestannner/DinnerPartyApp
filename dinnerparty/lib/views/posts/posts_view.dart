import 'package:dinnerparty/constants/routes.dart';
import 'package:dinnerparty/enums/menu_action.dart';
import 'package:dinnerparty/services/auth/auth_service.dart';
import 'package:dinnerparty/services/db/cloud/cloud_post.dart';
import 'package:dinnerparty/services/db/cloud/firebase_cloud_storage.dart';
import 'package:dinnerparty/services/db/local/post_service.dart';
import 'package:dinnerparty/utilities/dialogs/logout_dialog.dart';
import 'package:dinnerparty/views/posts/posts_list_view.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final FirebaseCloudStorage _postsService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    super.initState();
    _postsService = FirebaseCloudStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts View'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                createOrUpdatePostRoute,
              );
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    if (mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (_) => false,
                      );
                    }
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                )
              ];
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: _postsService.allPosts(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allPosts = snapshot.data as Iterable<CloudPost>;
                return PostsListView(
                  posts: allPosts,
                  onDeletePost: (post) async {
                    await _postsService.deletePost(documentId: post.documentId);
                  },
                  onTap: (post) {
                    Navigator.of(context).pushNamed(
                      createOrUpdatePostRoute,
                      arguments: post,
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
