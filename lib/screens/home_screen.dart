import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/app_user.dart';
import '../state/app_state.dart';
import '../widgets/bottom_nav.dart';
import 'profile_screen.dart';
import 'discover_screen.dart';
import 'matches_screen.dart';
import 'chats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 1; // Start on Discover
  AppState? _appState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newState = context.read<AppState>();
    if (_appState != newState) {
      _appState?.removeListener(_onStateChange);
      _appState = newState;
      _appState!.addListener(_onStateChange);
    }
  }

  @override
  void dispose() {
    _appState?.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    final state = context.read<AppState>();
    if (state.pendingMatchNotification != null) {
      final user = state.pendingMatchNotification!;
      state.clearPendingMatch();
      _showMatchDialog(user);
    }
  }

  void _showMatchDialog(AppUser user) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierColor: Colors.black87,
        barrierDismissible: false,
        builder: (_) => _MatchDialog(
          user: user,
          onMessage: () {
            Navigator.pop(context);
            setState(() => _tab = 3);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final screens = [
      ProfileScreen(
        isPremium: state.isPremium,
        onUpgrade: () => context.read<AppState>().upgradePremium(),
      ),
      DiscoverScreen(
        onSwipeRight: (user) => context.read<AppState>().swipeRight(user),
        onSwipeLeft: (user) => context.read<AppState>().swipeLeft(user),
        isPremium: state.isPremium,
      ),
      const MatchesScreen(),
      ChatsScreen(
        matches: state.matches,
        conversations: state.conversations,
        onSendMessage: (userId, text) =>
            context.read<AppState>().sendMessage(userId, text),
        onReceiveMessage: (userId, text) =>
            context.read<AppState>().receiveMessage(userId, text),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _tab,
              children: screens,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNav(
              currentIndex: _tab,
              onTap: (i) => setState(() => _tab = i),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Match celebration dialog ───────────────────────────────────────────────

class _MatchDialog extends StatelessWidget {
  final AppUser user;
  final VoidCallback onMessage;

  const _MatchDialog({required this.user, required this.onMessage});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.saffronDeep, AppColors.saffron, AppColors.orangeRed],
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✨', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            const Text(
              "It's a Match!",
              style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You and ${user.name} liked each other',
              style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.85)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (context.read<AppState>().currentUser != null)
                  _AvatarBubble(user: context.read<AppState>().currentUser!)
                else
                  const SizedBox(width: 72, height: 72),
                const SizedBox(width: 8),
                const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                _AvatarBubble(user: user),
              ],
            ),
            const SizedBox(height: 28),
            _WhiteButton(label: 'Send a Message', onTap: onMessage),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Keep Discovering',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Maybe later',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarBubble extends StatelessWidget {
  final AppUser user;
  const _AvatarBubble({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72, height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: user.gradient),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Center(
        child: Text(user.initial,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

class _WhiteButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _WhiteButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(label,
            style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: AppColors.saffron,
            )),
        ),
      ),
    );
  }
}
