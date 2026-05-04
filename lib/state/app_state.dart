import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../data/mock_data.dart';

class AppState extends ChangeNotifier {
  final Set<String> likedIds = {};
  final Set<String> passedIds = {};
  final List<AppUser> matches = List.from(kInitialMatches);
  final Map<String, List<ChatMessage>> conversations = kInitialConversations();
  bool isPremium = false;

  // Set to non-null when a new match occurs; HomeScreen consumes and clears it.
  AppUser? pendingMatchNotification;

  void swipeRight(AppUser user) {
    likedIds.add(user.id);
    if (Random().nextDouble() < 0.4 && !matches.any((m) => m.id == user.id)) {
      matches.add(user);
      conversations[user.id] = [];
      pendingMatchNotification = user;
    }
    notifyListeners();
  }

  void swipeLeft(AppUser user) {
    passedIds.add(user.id);
    notifyListeners();
  }

  void sendMessage(String userId, String text) {
    conversations.putIfAbsent(userId, () => []);
    conversations[userId]!.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: kCurrentUserId,
      text: text,
      timestamp: DateTime.now(),
      isRead: true,
    ));
    notifyListeners();
  }

  void receiveMessage(String userId, String text) {
    conversations.putIfAbsent(userId, () => []);
    conversations[userId]!.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: userId,
      text: text,
      timestamp: DateTime.now(),
      isRead: false,
    ));
    notifyListeners();
  }

  void upgradePremium() {
    isPremium = true;
    notifyListeners();
  }

  // Clears the match notification without triggering a rebuild.
  void clearPendingMatch() {
    pendingMatchNotification = null;
  }

  int get unreadCount => conversations.values
      .expand((msgs) => msgs)
      .where((m) => m.senderId != kCurrentUserId && !m.isRead)
      .length;

  int get likedYouCount => isPremium ? 0 : 3;
}
