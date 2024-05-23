import 'dart:developer';
import 'package:chat_app2/models/chat_user.dart';
import 'package:chat_app2/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs {
  static late ChatUser me;

  static User? get user => auth.currentUser;

  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user!.uid)
        .update({'name:': me.name, 'about': me.about});
  }

  static Future<void> sendFirstMessage(ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user!.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }


  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user!.uid).get()).exists;
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id != user!.uid) {
      firestore
          .collection('users')
          .doc(user!.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user!.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString()
    });
  }

  static Future<void> getSelfInfo() async {
    if (user == null) return;

    await firestore
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((userDoc) async {
      if (userDoc.exists) {
        me = ChatUser.fromJson(userDoc.data()!);
        APIs.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<void> createUser() async {
    if (user == null) return;

    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      id: user!.uid,
      name: user!.displayName ?? '', // Ensure to handle null displayName
      pushToken: '',
      email: user!.email ?? '', // Ensure to handle null email
      about: 'I am using Aloha app',
      image: user!.photoURL ?? '', // Ensure to handle null photoURL
      createdAt: time,
      isOnline: true,
      lastActive: time,
    );

    return (await firestore
        .collection('users')
        .doc(user!.uid)
        .set(chatUser.toJson()));
  }

 static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static String getConversationID(String id) =>
      user!.uid.hashCode <= id.hashCode
          ? '${user!.uid}_$id'
          : '${id}_${user!.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .snapshots();
  }

  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message = Message(
        msg: msg,
        fromId: user!.uid,
        toId: chatUser.id,
        read: '',
        type: Type.text,
        sent: time);
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc().set(message.toJson());
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user!.uid)
        .collection('my_users')
        .snapshots();
  }

  static Stream<QuerySnapshot> getLastMessage(ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .limit(1)
        .orderBy('sent', descending: true)
        .snapshots();
  }
}