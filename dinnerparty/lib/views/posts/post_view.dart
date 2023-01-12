import 'package:dinnerparty/constants/routes.dart';
import 'package:dinnerparty/enums/menu_action.dart';
import 'package:dinnerparty/services/auth/auth_service.dart';
import 'package:dinnerparty/services/db/local/post_service.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final PostsService _postsService;

  String get userId => AuthService.firebase().currentUser!.id!;

  @override
  void initState() {
    super.initState();
    _postsService = PostsService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts View'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(newPostRoute);
              },
              icon: const Icon(Icons.add)),
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
                        (Route<dynamic> route) => false,
                      );
                    }
                  }
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                )
              ];
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _postsService.getOrCreateUser(email: userId),
        builder: ((context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                  stream: _postsService.allPosts,
                  builder: ((context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final allNotes =
                              snapshot.data as List<LocalDatabasePost>;
                          return ListView.builder(
                            itemCount: allNotes.length,
                            itemBuilder: ((context, index) {
                              return const Text('post');
                            }),
                          );
                        } else {
                          return const Text('no posts');
                        }
                      // case ConnectionState.done:
                      //   // TODO: Handle this case.
                      //   break;
                      default:
                        return const CircularProgressIndicator();
                    }
                  }));
            default:
              return const CircularProgressIndicator();
          }
        }),
      ),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Log out')),
          ]);
    },
  ).then(((value) => value ?? false));
}
