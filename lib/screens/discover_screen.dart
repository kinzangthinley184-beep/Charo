import 'dart:math' show sin, cos, sqrt, atan2;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/app_user.dart';
import '../state/app_state.dart';
import '../widgets/profile_card.dart';
import '../widgets/action_buttons.dart';

class DiscoverScreen extends StatefulWidget {
  final void Function(AppUser)? onSwipeRight;
  final void Function(AppUser)? onSwipeLeft;
  final bool isPremium;

  const DiscoverScreen({
    super.key,
    this.onSwipeRight,
    this.onSwipeLeft,
    this.isPremium = false,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _tab = 0;
  int _previousTab = 0;
  List<AppUser> _stack = [];
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stack.isEmpty) _rebuildStack();
  }

  void _rebuildStack() {
    final state = context.read<AppState>();
    final excluded = {
      ...state.likedIds,
      ...state.passedIds,
      if (state.currentUser?.id != null) state.currentUser!.id,
    };
    final filtered =
        state.allUsers.where((u) => !excluded.contains(u.id)).toList();
    setState(() {
      _stack = filtered;
      _currentIndex = 0;
    });
  }

  void _switchTab(int t) {
    if (_tab == t) return;
    setState(() {
      _previousTab = _tab;
      _tab = t;
    });
  }

  void _onLike() {
    if (_currentIndex >= _stack.length) return;
    final user = _stack[_currentIndex];
    context.read<AppState>().swipeRight(user);
    widget.onSwipeRight?.call(user);
    setState(() => _currentIndex++);
  }

  void _onPass() {
    if (_currentIndex >= _stack.length) return;
    final user = _stack[_currentIndex];
    HapticFeedback.lightImpact();
    context.read<AppState>().swipeLeft(user);
    widget.onSwipeLeft?.call(user);
    setState(() => _currentIndex++);
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final phi1 = lat1 * 3.141592653589793 / 180;
    final phi2 = lat2 * 3.141592653589793 / 180;
    final dPhi = (lat2 - lat1) * 3.141592653589793 / 180;
    final dLam = (lon2 - lon1) * 3.141592653589793 / 180;
    final a = sin(dPhi / 2) * sin(dPhi / 2) +
        cos(phi1) * cos(phi2) * sin(dLam / 2) * sin(dLam / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  void _onNearbyTap(AppUser user) {
    setState(() {
      _stack.removeWhere((u) => u.id == user.id);
      _stack.insert(0, user);
      _currentIndex = 0;
      _previousTab = _tab;
      _tab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final goingRight = _tab > _previousTab;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab('CURATED', 0),
                const SizedBox(width: 48),
                _buildTab('PROXIMITY', 1),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, animation) {
                  final isIncoming = child.key == ValueKey(_tab);
                  final begin = isIncoming
                      ? Offset(goingRight ? 1.0 : -1.0, 0)
                      : Offset(goingRight ? -1.0 : 1.0, 0);
                  return SlideTransition(
                    position: Tween(begin: begin, end: Offset.zero).animate(
                      CurvedAnimation(
                          parent: animation, curve: Curves.easeOut),
                    ),
                    child: child,
                  );
                },
                child: _tab == 0
                    ? KeyedSubtree(
                        key: const ValueKey(0),
                        child: _buildCurated(),
                      )
                    : KeyedSubtree(
                        key: const ValueKey(1),
                        child: _buildProximity(appState),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _tab == index;
    return GestureDetector(
      onTap: () => _switchTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isActive ? 40 : 0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurated() {
    if (_currentIndex >= _stack.length) {
      return _EmptyState(onReset: _rebuildStack);
    }
    final user = _stack[_currentIndex];
    final nextUser =
        _currentIndex + 1 < _stack.length ? _stack[_currentIndex + 1] : null;

    return Column(
      children: [
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ProfileCard(
              key: ValueKey(_currentIndex),
              user: user,
              nextUser: nextUser,
              onLike: _onLike,
              onPass: _onPass,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ActionButtons(onPass: _onPass, onLike: _onLike),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildProximity(AppState appState) {
    final myLat = appState.currentLat;
    final myLng = appState.currentLng;
    var users = appState.allUsers
        .where((u) => u.id != appState.currentUser?.id)
        .toList();
    if (myLat != null && myLng != null) {
      users = users
          .where((u) => u.latitude != null && u.longitude != null)
          .toList();
      users.sort((a, b) {
        final da = _haversineKm(myLat, myLng, a.latitude!, a.longitude!);
        final db = _haversineKm(myLat, myLng, b.latitude!, b.longitude!);
        return da.compareTo(db);
      });
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3 / 4,
      ),
      itemCount: users.length,
      itemBuilder: (_, i) {
        final u = users[i];
        String distLabel = '';
        if (myLat != null && myLng != null && u.latitude != null && u.longitude != null) {
          final km = _haversineKm(myLat, myLng, u.latitude!, u.longitude!);
          distLabel = km < 1 ? '< 1 km' : '${km.round()} km';
        }
        return _ProximityCard(
          user: u,
          distanceLabel: distLabel,
          onTap: () => _onNearbyTap(u),
        );
      },
    );
  }
}

// ── Proximity grid card ────────────────────────────────────────────────────────

class _ProximityCard extends StatelessWidget {
  final AppUser user;
  final String distanceLabel;
  final VoidCallback onTap;

  const _ProximityCard({
    required this.user,
    required this.distanceLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            user.profileImage.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: user.profileImage,
                    fit: BoxFit.cover,
                    httpHeaders: const {
                      'User-Agent':
                          'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
                    },
                    placeholder: (_, _) =>
                        const ColoredBox(color: Color(0xFF1A1A1A)),
                    errorWidget: (_, _, _) => _fallback(),
                  )
                : _fallback(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
            // Distance badge
            if (distanceLabel.isNotEmpty)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15), width: 0.5),
                  ),
                  child: Text(
                    distanceLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            // Name + location
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${user.name}, ${user.age}',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.location.isNotEmpty)
                    Text(
                      user.location.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white60,
                        letterSpacing: 1.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFF111111),
      child: Center(
        child: Icon(
          Icons.person,
          color: Colors.white.withValues(alpha: 0.2),
          size: 36,
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onReset;
  const _EmptyState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'All caught up',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "You've seen everyone nearby.\nCheck back later.",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.white30,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: onReset,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 36, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'START OVER',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
