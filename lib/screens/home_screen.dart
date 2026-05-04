import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/app_user.dart';
import '../data/mock_data.dart';
import '../state/app_state.dart';
import 'profile_screen.dart';
import 'discover_screen.dart';
import 'people_screen.dart';
import 'liked_you_screen.dart';
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
            setState(() => _tab = 4);
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
      PeopleScreen(
        matches: state.matches,
        conversations: state.conversations,
        onSendMessage: (userId, text) =>
            context.read<AppState>().sendMessage(userId, text),
        onReceiveMessage: (userId, text) =>
            context.read<AppState>().receiveMessage(userId, text),
      ),
      LikedYouScreen(
        isPremium: state.isPremium,
        onUpgrade: () => context.read<AppState>().upgradePremium(),
      ),
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
      body: IndexedStack(index: _tab, children: screens),
      bottomNavigationBar: _BottomNav(
        currentIndex: _tab,
        unreadMessages: state.unreadCount,
        likedYouCount: state.likedYouCount,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

// ── Bottom Navigation ──────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final int unreadMessages;
  final int likedYouCount;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.unreadMessages,
    required this.likedYouCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(top: BorderSide(color: AppColors.darkBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(icon: Icons.person_rounded, label: 'Profile',
                  selected: currentIndex == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.explore_rounded, label: 'Discover',
                  selected: currentIndex == 1, onTap: () => onTap(1)),
              _NavItem(icon: Icons.people_rounded, label: 'People',
                  selected: currentIndex == 2, onTap: () => onTap(2)),
              _NavItem(
                icon: Icons.favorite_rounded,
                label: 'Liked You',
                selected: currentIndex == 3,
                badge: likedYouCount,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.chat_bubble_rounded,
                label: 'Chats',
                selected: currentIndex == 4,
                badge: unreadMessages,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.darkTextPrimary : AppColors.navUnselected;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 26),
                if (badge > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.matchPink,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
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
                _AvatarBubble(user: kCurrentUser),
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
