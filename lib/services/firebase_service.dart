import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  FirebaseService._();

  bool get isInitialized => Firebase.apps.isNotEmpty;
}
