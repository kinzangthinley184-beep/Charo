import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'state/app_state.dart';
import 'firebase_options.dart';
import 'utils/seed_users.dart' show deleteSeedUsers;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  try {
    await deleteSeedUsers();
  } catch (e) {
    debugPrint('Cleanup skipped: $e');
  }
  runApp(const CharoApp());
}

class CharoApp extends StatelessWidget {
  const CharoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Charo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: NotificationService.messengerKey,
        home: Consumer<AppState>(
          builder: (_, appState, _) {
            if (!appState.isAuthenticated) return const SplashScreen();
            if (appState.needsOnboarding) return const OnboardingScreen();
            return const HomeScreen();
          },
        ),
      ),
    );
  }
}
