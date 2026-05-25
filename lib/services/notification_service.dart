import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../state/app_state.dart';
import '../screens/chat_detail_screen.dart';

class NotificationService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final _messaging = FirebaseMessaging.instance;

  Future<void> init(String userId, GlobalKey<NavigatorState> navKey) async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    if (token != null) await _saveToken(userId, token);

    _messaging.onTokenRefresh.listen((t) => _saveToken(userId, t));

    // App opened from terminated state via notification tap
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage, navKey);
    }

    // Foreground notification — tappable snackbar
    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? 'New message';
      messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(title),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => _handleNotificationTap(message, navKey),
          ),
        ),
      );
    });

    // Background/quit notification tap
    FirebaseMessaging.onMessageOpenedApp
        .listen((msg) => _handleNotificationTap(msg, navKey));
  }

  void _handleNotificationTap(
      RemoteMessage message, GlobalKey<NavigatorState> navKey) {
    final otherUserId = message.data['senderId'] as String?;
    if (otherUserId == null || otherUserId.isEmpty) return;

    final context = navKey.currentContext;
    if (context == null) return;

    final appState = Provider.of<AppState>(context, listen: false);

    final otherUser = appState.allUsers.firstWhere(
      (u) => u.id == otherUserId,
      orElse: () => AppUser(
        id: otherUserId,
        name: message.data['senderName'] ?? 'User',
        age: 0,
        gender: '',
        bio: '',
        profileImage: '',
        interests: [],
        location: 'Bhutan',
        verified: false,
      ),
    );

    appState.openChatWith(otherUserId);

    navKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          user: otherUser,
          currentUserId: appState.userId ?? '',
          messages: appState.conversations[otherUserId] ?? [],
          onSendMessage: (text) => appState.sendMessage(otherUserId, text),
        ),
      ),
    );
  }

  Future<void> _saveToken(String userId, String token) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({'fcmToken': token}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FCM] Error saving token: $e');
    }
  }
}
