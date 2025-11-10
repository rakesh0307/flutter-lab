import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/word.dart';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _videosCollection => _firestore.collection('videos');
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Add new video data
  Future<void> addVideo(String title, String description, String thumbnailUrl, String videoUrl) async {
    await _videosCollection.add({
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get all videos as stream
  Stream<List<VideoData>> getVideos() {
    return _videosCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => VideoData.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  // Search videos by query (title or description)
  Stream<List<VideoData>> searchVideos(String query) {
    if (query.isEmpty) {
      return getVideos();
    }
    return _videosCollection
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: query + '\uf8ff')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => VideoData.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
        });
  }

  // Update video
  Future<void> updateVideo(String id, String title, String description, String thumbnailUrl, String videoUrl) async {
    await _videosCollection.doc(id).update({
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
    });
  }

  // Get user by email and password
  Future<User?> getUser(String email, String password) async {
    final querySnapshot = await _usersCollection
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return User.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Upload file to Firebase Storage and return download URL
  Future<String> uploadFile(dynamic file, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);

    UploadTask uploadTask;
    if (kIsWeb) {
      // For web, file is Uint8List
      uploadTask = ref.putData(file as Uint8List);
    } else {
      // For mobile, file is File
      uploadTask = ref.putFile(file as File);
    }

    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }
}
