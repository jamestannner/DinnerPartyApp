import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinnerparty/modules/posts/data/cloud_post.dart';
import 'package:dinnerparty/modules/posts/data/cloud_storage_constants.dart';
import 'package:dinnerparty/modules/posts/data/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final posts = FirebaseFirestore.instance.collection('posts');

  Future<void> deletePost({required String documentId}) async {
    await posts.doc(documentId).delete();
    try {} catch (e) {
      throw CouldNotDeletePostException();
    }
  }

  Future<void> updatePost({
    required String documentId,
    required String text,
  }) async {
    try {
      await posts.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdatePostException();
    }
  }

  Stream<Iterable<CloudPost>> allPosts({required String ownerUserId}) =>
      posts.snapshots().map((event) => event.docs
          .map((doc) => CloudPost.fromSnapshot(doc))
          .where((post) => post.ownerUserId == ownerUserId));

  Future<Iterable<CloudPost>> getPosts({required String ownerUserId}) async {
    try {
      return await posts
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudPost.fromSnapshot(doc)),
          );
    } catch (e) {
      throw CouldNotGetAllPostsException();
    }
  }

  Future<CloudPost> createNewPost({required String ownerUserId}) async {
    final document = await posts.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final fetchedPost = await document.get();
    return CloudPost(
      documentId: fetchedPost.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  // singleton
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
