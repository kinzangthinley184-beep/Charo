import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final _messaging = FirebaseMessaging.instance;

  Future<void> init(String userId) async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    if (token != null) await _saveToken(userId, token);

    _messaging.onTokenRefresh.listen((t) => _saveToken(userId, t));

    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? 'New notification';
      messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(title)),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] Opened from notification: ${message.messageId}');
    });
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
