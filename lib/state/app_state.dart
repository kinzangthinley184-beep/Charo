import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/app_user.dart';
import '../services/notification_service.dart';
import '../main.dart' show navigatorKey;

class AppState extends ChangeNotifier {
  final Set<String> likedIds = {};
  final Set<String> passedIds = {};
  final List<AppUser> matches = [];
  final Map<String, List<ChatMessage>> conversations = {};
  bool isPremium = false;
  bool shareLocation = false;
  AppUser? pendingMatchNotification;

  bool _isAuthenticated = false;
  String? _userId;
  String? _phoneNumber;
  List<AppUser> _allUsers = [];
  bool _loadingUsers = false;
  AppUser? _currentUser;
  bool _profileLoaded = false;
  double? _currentLat;
  double? _currentLng;
  Set<String> _blockedIds = {};

  StreamSubscription? _matchesSub;
  final Map<String, StreamSubscription> _messageSubs = {};

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get phoneNumber => _phoneNumber;
  List<AppUser> get allUsers => _allUsers;
  bool get loadingUsers => _loadingUsers;
  AppUser? get currentUser => _currentUser;
  bool get isLoadingProfile => _isAuthenticated && !_profileLoaded;
  double? get currentLat => _currentLat;
  double? get currentLng => _currentLng;
  Set<String> get blockedIds => _blockedIds;

  bool get needsOnboarding {
    if (!_profileLoaded || _currentUser == null) return false;
    final u = _currentUser!;
    return u.name.isEmpty || u.name == 'User' || u.age == 0;
  }

  AppState() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userId = prefs.getString('userId');
    _phoneNumber = prefs.getString('phoneNumber');
    notifyListeners();

    if (_isAuthenticated && _userId != null) {
      await _loadSwipes();
      await fetchUsersFromFirestore();
      await fetchCurrentUser();
      _subscribeToMatches();
      NotificationService().init(_userId!, navigatorKey);
      fetchCurrentLocation();
    }
  }

  Future<void> setAuthenticated(String userId, String phoneNumber) async {
    _isAuthenticated = true;
    _userId = userId;
    _phoneNumber = phoneNumber;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('userId', userId);
    await prefs.setString('phoneNumber', phoneNumber);
    notifyListeners();

    await _loadSwipes();
    await fetchUsersFromFirestore();
    await fetchCurrentUser();
    _subscribeToMatches();
    NotificationService().init(_userId!, navigatorKey);
    fetchCurrentLocation();
  }

  // ── Swipe persistence ────────────────────────────────────────────────────

  Future<void> _loadSwipes() async {
    if (_userId == null) return;
    try {
      final likedSnap = await FirebaseFirestore.instance
          .collection('users').doc(_userId!).collection('likes').get();
      final passedSnap = await FirebaseFirestore.instance
          .collection('users').doc(_userId!).collection('passes').get();
      likedIds.addAll(likedSnap.docs.map((d) => d.id));
      passedIds.addAll(passedSnap.docs.map((d) => d.id));
    } catch (e) {
      debugPrint('Error loading swipes: $e');
    }
  }

  Future<void> swipeRight(AppUser user) async {
    if (likedIds.contains(user.id)) return;
    likedIds.add(user.id);
    notifyListeners();
    if (_userId == null) return;

    try {
      // Save our like
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId!)
          .collection('likes')
          .doc(user.id)
          .set({'timestamp': FieldValue.serverTimestamp()});

      // Check if they already liked us back
      final reverseDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .collection('likes')
          .doc(_userId!)
          .get();

      if (reverseDoc.exists) {
        // Mutual like — create match
        final matchId = ([_userId!, user.id]..sort()).join('_');
        final matchRef = FirebaseFirestore.instance
            .collection('matches')
            .doc(matchId);
        final matchDoc = await matchRef.get();

        if (!matchDoc.exists) {
          await matchRef.set({
            'participants': [_userId!, user.id],
            'createdAt': FieldValue.serverTimestamp(),
          });
          debugPrint('[Match] Created match: $matchId');
        }
      }
    } catch (e) {
      debugPrint('Error in swipeRight: $e');
    }
  }

  Future<void> swipeLeft(AppUser user) async {
    if (passedIds.contains(user.id)) return;
    passedIds.add(user.id);
    notifyListeners();
    if (_userId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users').doc(_userId!).collection('passes').doc(user.id)
          .set({'timestamp': FieldValue.serverTimestamp()});
    } catch (e) {
      debugPrint('Error persisting pass: $e');
    }
  }

  // ── Matches ──────────────────────────────────────────────────────────────

  void _subscribeToMatches() {
    if (_userId == null) return;
    _matchesSub?.cancel();
    _matchesSub = FirebaseFirestore.instance
        .collection('matches')
        .where('participants', arrayContains: _userId!)
        .snapshots()
        .listen((snap) {
      final newMatchIds = <String>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        final otherId =
            participants.firstWhere((id) => id != _userId, orElse: () => '');
        if (otherId.isEmpty) continue;
        newMatchIds.add(otherId);
        final alreadyAdded = matches.any((m) => m.id == otherId);
        if (!alreadyAdded) {
          final user = _allUsers.firstWhere(
            (u) => u.id == otherId,
            orElse: () => AppUser(
              id: otherId,
              name: 'User',
              age: 0,
              gender: '',
              bio: '',
              profileImage: '',
              interests: [],
              location: 'Bhutan',
              verified: false,
            ),
          );
          matches.add(user);
          _subscribeToMessages(doc.id, otherId);
        }
      }
      // Remove matches no longer in Firestore
      matches.removeWhere((m) => !newMatchIds.contains(m.id));
      notifyListeners();
    }, onError: (e) => debugPrint('Matches subscription error: $e'));
  }

  // ── Messaging ────────────────────────────────────────────────────────────

  String matchId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  void _subscribeToMessages(String chatId, String otherUserId) {
    if (_messageSubs.containsKey(chatId)) return;
    final sub = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snap) {
      conversations[otherUserId] = snap.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          id: doc.id,
          senderId: data['senderId'] ?? '',
          text: data['text'] ?? '',
          timestamp:
              (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isRead: data['isRead'] ?? false,
        );
      }).toList();
      notifyListeners();
    }, onError: (e) => debugPrint('Messages subscription error: $e'));
    _messageSubs[chatId] = sub;
  }

  void openChatWith(String otherUserId) {
    if (_userId == null) return;
    final chatId = matchId(_userId!, otherUserId);
    if (!_messageSubs.containsKey(chatId)) {
      _subscribeToMessages(chatId, otherUserId);
    }
  }

  Future<void> sendMessage(String otherUserId, String text) async {
    if (_userId == null) return;
    try {
      final cid = matchId(_userId!, otherUserId);
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(cid)
          .collection('messages')
          .add({
        'senderId': _userId!,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  void receiveMessage(String userId, String text) {
    // Messages arrive via real-time listener — no-op.
  }

  // ── User profile ─────────────────────────────────────────────────────────

  Future<void> fetchCurrentUser() async {
    if (_userId == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId!)
          .get();
      if (doc.exists && doc.data() != null) {
        _currentUser = AppUser.fromFirestore(doc.id, doc.data()!);
      } else {
        _currentUser = AppUser(
          id: _userId!,
          name: '',
          age: 0,
          gender: '',
          bio: '',
          profileImage: '',
          interests: [],
          location: 'Bhutan',
          verified: false,
        );
      }
    } catch (e) {
      debugPrint('Error fetching current user: $e');
    }
    _profileLoaded = true;
    notifyListeners();
  }

  Future<void> fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      _currentLat = pos.latitude;
      _currentLng = pos.longitude;
      if (_userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(_userId!).update({
          'latitude': _currentLat,
          'longitude': _currentLng,
        });
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  // Firestore rules needed:
  // match /users/{uid}/blocks/{targetId} { allow write: if request.auth.uid == uid; }
  // match /reports/{id} { allow create: if request.auth != null; }

  Future<void> blockUser(String targetUid) async {
    if (_userId == null) return;
    _blockedIds.add(targetUid);
    _allUsers.removeWhere((u) => u.id == targetUid);
    notifyListeners();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId!)
        .collection('blocks')
        .doc(targetUid)
        .set({'blockedAt': FieldValue.serverTimestamp()});
  }

  Future<void> reportUser(String targetUid, String reason) async {
    if (_userId == null) return;
    await FirebaseFirestore.instance.collection('reports').add({
      'reportedBy': _userId!,
      'reportedUser': targetUid,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> fetchUsersFromFirestore() async {
    _loadingUsers = true;
    notifyListeners();
    try {
      if (_userId != null) {
        final blocksSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId!)
            .collection('blocks')
            .get();
        _blockedIds = blocksSnap.docs.map((d) => d.id).toSet();
      }
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      _allUsers = snapshot.docs
          .map((doc) => AppUser.fromFirestore(doc.id, doc.data()))
          .toList();
      _allUsers = _allUsers.where((u) => !_blockedIds.contains(u.id)).toList();
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
    _loadingUsers = false;
    notifyListeners();
  }

  Future<void> updateUserProfile({
    required String name,
    required int age,
    required String gender,
    required String bio,
    required List<String> interests,
  }) async {
    if (_userId == null) return;
    final data = {
      'name': name,
      'age': age,
      'gender': gender,
      'bio': bio,
      'interests': interests,
    };
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId!)
        .set(data, SetOptions(merge: true));
    _currentUser = (_currentUser ?? AppUser(
      id: _userId!,
      name: name,
      age: age,
      gender: gender,
      bio: bio,
      profileImage: '',
      interests: interests,
      location: 'Bhutan',
      verified: false,
    )).copyWith(
      name: name,
      age: age,
      gender: gender,
      bio: bio,
      interests: interests,
    );
    notifyListeners();
  }

  Future<void> updateUserPhotos(List<String> photoUrls) async {
    if (_userId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId!)
          .set({'photos': photoUrls}, SetOptions(merge: true));
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(photos: photoUrls);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating user photos: $e');
    }
  }

  Future<void> updateUserLocation(double latitude, double longitude) async {
    if (_userId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId!)
          .set({'latitude': latitude, 'longitude': longitude},
              SetOptions(merge: true));
      if (_currentUser != null) {
        _currentUser =
            _currentUser!.copyWith(latitude: latitude, longitude: longitude);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating user location: $e');
    }
  }

  Future<void> saveFcmToken(String token) async {
    if (_userId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId!)
          .set({'fcmToken': token}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  // ── Auth ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    _matchesSub?.cancel();
    _matchesSub = null;
    for (final sub in _messageSubs.values) {
      sub.cancel();
    }
    _messageSubs.clear();

    _isAuthenticated = false;
    _userId = null;
    _phoneNumber = null;
    _currentUser = null;
    _profileLoaded = false;
    likedIds.clear();
    passedIds.clear();
    matches.clear();
    conversations.clear();
    _allUsers.clear();
    isPremium = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  void upgradePremium() {
    isPremium = true;
    notifyListeners();
  }

  void clearPendingMatch() {
    pendingMatchNotification = null;
  }

  int get unreadCount {
    if (_userId == null) return 0;
    int count = 0;
    for (final msgs in conversations.values) {
      count += msgs.where((m) => m.senderId != _userId && !m.isRead).length;
    }
    return count;
  }

  int get likedYouCount => isPremium ? 0 : 3;
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? text,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
