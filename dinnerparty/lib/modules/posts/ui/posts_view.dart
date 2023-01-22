import 'package:dinnerparty/config/routes.dart';
import 'package:dinnerparty/config/menu_action_enum.dart';
import 'package:dinnerparty/modules/authentication/bloc/auth_bloc.dart';
import 'package:dinnerparty/modules/authentication/bloc/auth_event.dart';
import 'package:dinnerparty/modules/authentication/data/auth_service.dart';
import 'package:dinnerparty/modules/authentication/ui/logout_dialog.dart';
import 'package:dinnerparty/modules/posts/data/cloud_post.dart';
import 'package:dinnerparty/modules/posts/data/firebase_cloud_storage.dart';
import 'package:dinnerparty/modules/posts/ui/posts_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;

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
                  if (shouldLogout && mounted) {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
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
