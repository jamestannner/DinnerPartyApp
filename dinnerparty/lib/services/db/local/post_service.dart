// import 'dart:async';

// import 'package:dinnerparty/extensions/list/filter.dart';
// import 'package:dinnerparty/services/db/local/local_storage_exceptions.dart';
// import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart'
//     show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
// import 'package:path/path.dart' show join;

// class PostsService {
//   Database? _db;

//   List<LocalDatabasePost> _posts = [];

//   LocalDatabaseUser? _user;

//   // makes PostsService a singleton
//   static final PostsService _shared = PostsService._sharedInstance();
//   PostsService._sharedInstance() {
//     _postsStreamController =
//         StreamController<List<LocalDatabasePost>>.broadcast(onListen: () {
//       _postsStreamController.sink.add(_posts);
//     });
//   }
//   factory PostsService() => _shared;

//   late final StreamController<List<LocalDatabasePost>> _postsStreamController;

//   Stream<List<LocalDatabasePost>> get allPosts =>
//       _postsStreamController.stream.filter((post) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return post.userId == currentUser.id;
//         } else {
//           throw UserShouldBeSetBeforeReadingAllPosts();
//         }
//       });

//   Future<LocalDatabaseUser> getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUser {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> _cachePosts() async {
//     final allPosts = await getAllPosts();
//     _posts = allPosts.toList();
//     _postsStreamController.add(_posts);
//   }

//   Future<LocalDatabasePost> updatePost({
//     required LocalDatabasePost post,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     await getPost(id: post.id);

//     final updatesCount = await db.update(
//       localPostTable,
//       {
//         postColumn: text,
//       },
//       where: 'id = ?',
//       whereArgs: [post.id],
//     );

//     if (updatesCount == 0) {
//       throw CouldNotUpdatePost();
//     } else {
//       final updatedPost = await getPost(id: post.id);
//       _posts.removeWhere((post) => post.id == updatedPost.id);
//       _posts.add(updatedPost);
//       _postsStreamController.add(_posts);
//       return updatedPost;
//     }
//   }

//   Future<Iterable<LocalDatabasePost>> getAllPosts() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final posts = await db.query(localPostTable);

//     return posts.map((postRow) => LocalDatabasePost.fromRow(postRow));
//   }

//   Future<LocalDatabasePost> getPost({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final posts = await db.query(
//       localPostTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (posts.isEmpty) {
//       throw CouldNotFindPost();
//     } else {
//       final post = LocalDatabasePost.fromRow(posts.first);
//       _posts.removeWhere((post) => post.id == id);
//       _posts.add(post);
//       _postsStreamController.add(_posts);
//       return post;
//     }
//   }

//   Future<int> deleteAllPosts() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final numberOfDeletions = await db.delete(localPostTable);
//     _posts = [];
//     _postsStreamController.add(_posts);
//     return numberOfDeletions;
//   }

//   Future<void> deletePost({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       localPostTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (deletedCount == 0) {
//       throw CouldNotDeletePost();
//     } else {
//       _posts.removeWhere((post) => post.id == id);
//       _postsStreamController.add(_posts);
//     }
//   }

//   Future<LocalDatabasePost> createPost(
//       {required LocalDatabaseUser author}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     // ensure that the author exists in the db with appropriate id
//     final dbUser = await getUser(email: author.email);
//     if (dbUser != author) {
//       throw CouldNotFindUser();
//     }

//     const postContent = '';

//     // create the post
//     final postId = await db.insert(
//       localPostTable,
//       {
//         userIdColumn: author.id,
//         postColumn: postContent,
//       },
//     );

//     final post = LocalDatabasePost(
//       id: postId,
//       userId: author.id,
//       post: postContent,
//     );

//     _posts.add(post);
//     _postsStreamController.add(_posts);

//     return post;
//   }

//   Future<LocalDatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();

//     final results = await db.query(
//       localUserTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );

//     if (results.isEmpty) {
//       throw CouldNotFindUser();
//     } else {
//       return LocalDatabaseUser.fromRow(results.first);
//     }
//   }

//   Future<LocalDatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     email = email.toLowerCase();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       localUserTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email],
//     );
//     if (results.isNotEmpty) {
//       throw UserAlreadyExists();
//     }

//     final userId = await db.insert(localUserTable, {emailColumn: email});

//     return LocalDatabaseUser(id: userId, email: email);
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       localUserTable,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deletedCount != 1) {
//       throw CouldNotDeleteUser();
//     }
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       return db;
//     }
//   }

//   Future<void> open() async {
//     if (_db != null) throw DatabaseAlreadyOpenException();
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, localDatabaseName);
//       final db = await openDatabase(dbPath);
//       _db = db;

//       await db.execute(createUserTable);

//       await db.execute(createPostTable);
//       await _cachePosts();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectory();
//     }
//   }

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       //empty
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }
// }

// @immutable
// class LocalDatabaseUser {
//   final int id;
//   final String email;
//   const LocalDatabaseUser({
//     required this.id,
//     required this.email,
//   });

//   LocalDatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   @override
//   String toString() =>
//       '----- LocalDatabaseUser -----\nid = $id\nemail = $email\n';

//   @override
//   bool operator ==(covariant LocalDatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class LocalDatabasePost {
//   final int id;
//   final int userId;
//   final String post;

//   LocalDatabasePost({
//     required this.id,
//     required this.userId,
//     required this.post,
//   });

//   LocalDatabasePost.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         post = map[postColumn] as String;

//   @override
//   String toString() =>
//       '----- LocalDatabasePost -----\nid = $id\nuserId = $userId\npost = $post\n';

//   @override
//   bool operator ==(covariant LocalDatabasePost other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// // constants

// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const postColumn = 'post';
// const localDatabaseName = 'posts.db';
// const localPostTable = 'post';
// const localUserTable = 'user';

// const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
//   "id"	INTEGER NOT NULL,
//   "email"	TEXT NOT NULL UNIQUE,
//   PRIMARY KEY("id" AUTOINCREMENT)
// );''';

// const createPostTable = '''CREATE TABLE IF NOT EXISTS "post" (
//   "id"	INTEGER NOT NULL,
//   "user_id"	INTEGER NOT NULL,
//   "post"	TEXT,
//   FOREIGN KEY("user_id") REFERENCES "user"("id"),
//   PRIMARY KEY("id" AUTOINCREMENT)
// );''';
