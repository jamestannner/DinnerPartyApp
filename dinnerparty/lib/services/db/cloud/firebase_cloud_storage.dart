import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinnerparty/services/db/cloud/cloud_post.dart';
import 'package:dinnerparty/services/db/cloud/cloud_storage_constants.dart';
import 'package:dinnerparty/services/db/cloud/cloud_storage_exceptions.dart';

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
        (value) {
          return value.docs.map((doc) {
            return CloudPost(
              documentId: doc.id,
              ownerUserId: doc.data()[ownerUserIdFieldName] as String,
              text: doc.data()[textFieldName] as String,
            );
          });
        },
      );
    } catch (e) {
      throw CouldNotGetAllPostsException();
    }
  }

  void createNewPost({required String ownerUserId}) async {
    await posts.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }

  // singleton
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
