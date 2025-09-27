import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../models/user_model.dart';
import '../models/project_model.dart';

@injectable
class FirebaseDataSource {
  /// Creates a Firebase data source
  FirebaseDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  // User operations
  /// Creates a new user in Firestore
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  /// Gets a user by ID from Firestore
  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  /// Updates a user in Firestore
  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toJson());
  }

  /// Searches for users by username
  Future<List<UserModel>> searchUsers(String query) async {
    final snapshot =
        await _firestore
            .collection('users')
            .where('username', isGreaterThanOrEqualTo: query)
            .where('username', isLessThan: '${query}z')
            .limit(20)
            .get();

    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }

  // Project operations
  /// Creates a new project in Firestore
  Future<void> createProject(ProjectModel project) async {
    await _firestore
        .collection('projects')
        .doc(project.id)
        .set(project.toJson());
  }

  /// Gets a project by ID from Firestore
  Future<ProjectModel?> getProject(String projectId) async {
    final doc = await _firestore.collection('projects').doc(projectId).get();
    if (doc.exists) {
      return ProjectModel.fromJson(doc.data()!);
    }
    return null;
  }

  /// Gets all projects by a specific user
  Future<List<ProjectModel>> getProjectsByUser(String userId) async {
    final snapshot =
        await _firestore
            .collection('projects')
            .where('ownerId', isEqualTo: userId)
            .orderBy('updatedAt', descending: true)
            .limit(20)
            .get();

    return snapshot.docs
        .map((doc) => ProjectModel.fromJson(doc.data()))
        .toList();
  }

  /// Gets trending projects ordered by stars
  Future<List<ProjectModel>> getTrendingProjects() async {
    final snapshot =
        await _firestore
            .collection('projects')
            .orderBy('starsCount', descending: true)
            .limit(20)
            .get();

    return snapshot.docs
        .map((doc) => ProjectModel.fromJson(doc.data()))
        .toList();
  }

  // Match operations
  /// Creates a new match in Firestore
  Future<void> createMatch(Map<String, dynamic> match) async {
    await _firestore.collection('matches').add(match);
  }

  /// Gets all matches for a user
  Future<List<Map<String, dynamic>>> getMatches(String userId) async {
    final snapshot1 =
        await _firestore
            .collection('matches')
            .where('userId1', isEqualTo: userId)
            .orderBy('matchedAt', descending: true)
            .limit(20)
            .get();

    final snapshot2 =
        await _firestore
            .collection('matches')
            .where('userId2', isEqualTo: userId)
            .orderBy('matchedAt', descending: true)
            .limit(20)
            .get();

    final allDocs = [...snapshot1.docs, ...snapshot2.docs];

    return allDocs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  // Chat operations
  /// Creates a new chat in Firestore
  Future<void> createChat(Map<String, dynamic> chat) async {
    await _firestore.collection('chats').add(chat);
  }

  /// Gets all chats for a user
  Future<List<Map<String, dynamic>>> getChats(String userId) async {
    final snapshot =
        await _firestore
            .collection('chats')
            .where('participants', arrayContains: userId)
            .orderBy('lastMessageAt', descending: true)
            .limit(20)
            .get();

    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// Sends a message to a chat
  Future<void> sendMessage(String chatId, Map<String, dynamic> message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);
  }

  /// Gets all messages for a chat
  Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
    final snapshot =
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('sentAt', descending: true)
            .limit(50)
            .get();

    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  // Streams
  /// Gets a stream of user data
  Stream<UserModel> getUserStream(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((doc) => UserModel.fromJson(doc.data()!));

  /// Gets a stream of chats for a user
  Stream<List<Map<String, dynamic>>> getChatsStream(String userId) => _firestore
      .collection('chats')
      .where('participants', arrayContains: userId)
      .orderBy('lastMessageAt', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
      );

  /// Gets a stream of messages for a chat
  Stream<List<Map<String, dynamic>>> getMessagesStream(String chatId) =>
      _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('sentAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => {'id': doc.id, ...doc.data()})
                    .toList(),
          );
}
