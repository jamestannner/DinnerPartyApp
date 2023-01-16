import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dinnerparty/services/db/cloud/cloud_storage_constants.dart';
import 'package:flutter/material.dart';

@immutable
class CloudPost {
  final String documentId;
  final String ownerUserId;
  final String text;
  const CloudPost({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  CloudPost.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String;
}
