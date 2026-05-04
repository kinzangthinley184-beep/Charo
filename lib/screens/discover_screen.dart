import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/app_user.dart';
import '../data/mock_data.dart';
import '../widgets/verified_badge.dart';

class DiscoverScreen extends StatefulWidget {
  final void Function(AppUser) onSwipeRight;
  final void Function(AppUser) onSwipeLeft;
  final bool isPremium;

  const DiscoverScreen({
    super.key,
    required this.onSwipeRight,
    required this.onSwipeLeft,
    required this.isPremium,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late List<AppUser> _stack;
  int _currentIndex = 0;
  bool _showEmpty = false;
  bool _isNearbyMode = false;
  final _dragNotifier = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    _stack = List.from(kDiscoverUsers);
  }

  @override
  void dispose() {
    _dragNotifier.dispose();
    super.dispose();
  }

  void _onLike() {
    if (_currentIndex >= _stack.length) return;
    HapticFeedback.mediumImpact();
    widget.onSwipeRight(_stack[_currentIndex]);
    _advance();
  }

  void _onPass() {
    if (_currentIndex >= _stack.length) return;
    HapticFeedback.mediumImpact();
    widget.onSwipeLeft(_stack[_currentIndex]);
    _advance();
  }

  void _onSuperLike() {
    if (_currentIndex >= _stack.length) return;
    widget.onSwipeRight(_stack[_currentIndex]);
    _advance();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⭐ Super Liked ${_stack[_currentIndex - 1].name}!'),
        backgroundColor: AppColors.superBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _advance() {
    setState(() {
      _currentIndex++;
      if (_currentIndex >= _stack.length) _showEmpty = true;
    });
  }

  void _reset() {
    setState(() {
      _currentIndex = 0;
      _showEmpty = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildModeToggle(),
            Expanded(
              child: _isNearbyMode
                  ? _NearbyView(
                      onLike: (user) {
                        widget.onSwipeRight(user);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❤️ You liked ${user.name}!'),
                            backgroundColor: AppColors.matchPink,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    )
                  : _showEmpty
                      ? _EmptyState(onReset: _reset)
                      : _buildCardStack(),
            ),
            if (!_isNearbyMode) ...[
              _buildActionBar(),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Charo',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkTextPrimary)),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.premiumYellow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('BT',
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBg)),
                  ),
                ],
              ),
              Text('Thimphu, Bhutan',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.darkTextSecondary)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showFilters(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.darkElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: AppColors.darkTextPrimary, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.darkElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _ToggleTab(
              label: 'Discover',
              icon: Icons.explore_rounded,
              selected: !_isNearbyMode,
              onTap: () => setState(() => _isNearbyMode = false),
            ),
            _ToggleTab(
              label: 'Nearby',
              icon: Icons.near_me_rounded,
              selected: _isNearbyMode,
              onTap: () => setState(() => _isNearbyMode = true),
              accentColor: AppColors.nearbyTeal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStack() {
    final remaining = _stack.length - _currentIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = math.min(remaining - 1, 2); i > 0; i--)
            ValueListenableBuilder<double>(
              valueListenable: _dragNotifier,
              builder: (_, dx, _) {
                final progress = (dx.abs() / 150).clamp(0.0, 1.0);
                final baseScale = 1.0 - i * 0.04;
                final animatedScale = baseScale + (i * 0.03 * progress);
                final baseOffset = i * 10.0;
                final animatedOffset = baseOffset - (i * 6.0 * progress);
                return Transform.scale(
                  scale: animatedScale,
                  child: Transform.translate(
                    offset: Offset(0, animatedOffset),
                    child: _StaticCard(user: _stack[_currentIndex + i]),
                  ),
                );
              },
            ),
          if (_currentIndex < _stack.length)
            _SwipeCard(
              key: ValueKey(_currentIndex),
              user: _stack[_currentIndex],
              onLike: _onLike,
              onPass: _onPass,
              onDragUpdate: (dx) => _dragNotifier.value = dx,
            ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
              icon: Icons.close_rounded,
              color: AppColors.passGray,
              size: 56,
              onTap: _onPass),
          _ActionButton(
              icon: Icons.star_rounded,
              color: AppColors.superBlue,
              size: 46,
              onTap: _onSuperLike),
          _ActionButton(
              icon: Icons.favorite_rounded,
              color: AppColors.matchPink,
              size: 56,
              onTap: _onLike),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _FiltersSheet(),
    );
  }
}

// ── Mode toggle tab ───────────────────────────────────────────────────────────

class _ToggleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color accentColor;

  const _ToggleTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.accentColor = AppColors.saffron,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 15,
                  color: selected
                      ? Colors.white
                      : AppColors.darkTextSecondary),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? Colors.white
                      : AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Nearby view ───────────────────────────────────────────────────────────────

class _NearbyView extends StatelessWidget {
  final void Function(AppUser) onLike;

  const _NearbyView({required this.onLike});

  @override
  Widget build(BuildContext context) {
    final sorted = [...kDiscoverUsers]..sort((a, b) {
        final da = double.tryParse(a.distance.replaceAll(' km', '')) ?? 9999;
        final db = double.tryParse(b.distance.replaceAll(' km', '')) ?? 9999;
        return da.compareTo(db);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.nearbyTeal,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${sorted.length} people nearby',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.nearbyTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            addAutomaticKeepAlives: false,
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _NearbyCard(
              user: sorted[i],
              onLike: () => onLike(sorted[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _NearbyCard extends StatelessWidget {
  final AppUser user;
  final VoidCallback onLike;

  const _NearbyCard({required this.user, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: user.gradient),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(user.initial,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${user.name}, ${user.age}',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkTextPrimary)),
                    const SizedBox(width: 4),
                    if (user.isVerified)
                      const VerifiedBadge(size: 14),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.near_me_rounded,
                        color: AppColors.nearbyTeal, size: 13),
                    const SizedBox(width: 3),
                    Text(user.distance,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.nearbyTeal,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.darkTextSecondary, size: 12),
                    const SizedBox(width: 2),
                    Text(user.location,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.darkTextSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 5,
                  children: user.interests.take(2).map((i) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              AppColors.nearbyTeal.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.nearbyTeal
                                  .withValues(alpha: 0.25)),
                        ),
                        child: Text(i,
                            style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.nearbyTeal,
                                fontWeight: FontWeight.w500)),
                      )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onLike,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.matchPink.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.matchPink.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.favorite_rounded,
                  color: AppColors.matchPink, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Swipeable card ────────────────────────────────────────────────────────────

class _SwipeCard extends StatefulWidget {
  final AppUser user;
  final VoidCallback onLike;
  final VoidCallback onPass;
  final void Function(double dx)? onDragUpdate;

  const _SwipeCard({
    super.key,
    required this.user,
    required this.onLike,
    required this.onPass,
    this.onDragUpdate,
  });

  @override
  State<_SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<_SwipeCard>
    with TickerProviderStateMixin {
  Offset _drag = Offset.zero;
  late AnimationController _springCtrl;
  late Animation<Offset> _springAnim;
  bool _isFlying = false;

  static const double _threshold = 100.0;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _springAnim = Tween(begin: Offset.zero, end: Offset.zero)
        .animate(CurvedAnimation(parent: _springCtrl, curve: Curves.elasticOut));
    _springCtrl.addListener(() => setState(() => _drag = _springAnim.value));
  }

  @override
  void dispose() {
    _springCtrl.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails _) {
    if (_isFlying) return;
    _springCtrl.stop();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_isFlying) return;
    setState(() => _drag += d.delta);
    widget.onDragUpdate?.call(_drag.dx);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isFlying) return;

    final velocity = details.velocity.pixelsPerSecond;

    if (_drag.dx > _threshold || velocity.dx > 600) {
      _flyOut(right: true);
    } else if (_drag.dx < -_threshold || velocity.dx < -600) {
      _flyOut(right: false);
    } else {
      widget.onDragUpdate?.call(0.0);
      _springAnim = Tween(begin: _drag, end: Offset.zero).animate(
          CurvedAnimation(parent: _springCtrl, curve: Curves.elasticOut));
      _springCtrl.forward(from: 0);
    }
  }

  void _flyOut({required bool right}) {
    if (_isFlying) return;
    setState(() => _isFlying = true);
    widget.onDragUpdate?.call(0.0);
    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = right ? screenWidth * 1.8 : -screenWidth * 1.8;
    final flyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    final flyAnim = Tween(begin: _drag, end: Offset(targetX, _drag.dy - 80))
        .animate(CurvedAnimation(parent: flyCtrl, curve: Curves.easeIn));
    flyAnim.addListener(() => setState(() => _drag = flyAnim.value));
    flyCtrl.forward().then((_) {
      flyCtrl.dispose();
      if (right) widget.onLike();
      else widget.onPass();
    });
  }

  @override
  Widget build(BuildContext context) {
    final angle = _drag.dx / 800;
    final isLiking = _drag.dx > 30;
    final isPassing = _drag.dx < -30;

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _drag,
        child: Transform.rotate(
          angle: angle,
          child: Stack(
            children: [
              _CardContent(user: widget.user),
              if (isLiking)
                Positioned(
                  top: 40, left: 24,
                  child: _SwipeLabel(
                      label: 'LIKE',
                      color: AppColors.likeGreen,
                      opacity: (_drag.dx / _threshold).clamp(0.0, 1.0)),
                ),
              if (isPassing)
                Positioned(
                  top: 40, right: 24,
                  child: _SwipeLabel(
                      label: 'NOPE',
                      color: AppColors.matchPink,
                      opacity: (-_drag.dx / _threshold).clamp(0.0, 1.0)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaticCard extends StatelessWidget {
  final AppUser user;
  const _StaticCard({required this.user});

  @override
  Widget build(BuildContext context) => _CardContent(user: user);
}

class _CardContent extends StatelessWidget {
  final AppUser user;
  const _CardContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: user.gradient,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(user.initial,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withValues(alpha: 0.15))),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(24)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('${user.name}, ${user.age}',
                          style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      const SizedBox(width: 6),
                      if (user.isVerified)
                        const VerifiedBadge(size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: Colors.white70, size: 14),
                      const SizedBox(width: 3),
                      Text(user.location,
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.white70)),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.near_me_rounded,
                              color: AppColors.nearbyTeal, size: 13),
                          const SizedBox(width: 3),
                          Text(user.distance,
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.nearbyTeal)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(user.bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.4)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: [
                      ...user.interests.take(3).map((i) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Text(i,
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      )),
                      if (user.interests.length > 3)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Text('+${user.interests.length - 3}',
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeLabel extends StatelessWidget {
  final String label;
  final Color color;
  final double opacity;

  const _SwipeLabel(
      {required this.label, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Transform.rotate(
          angle: label == 'LIKE' ? -0.3 : 0.3,
          child: Text(label,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 2)),
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween(begin: 1.0, end: 0.88).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    _ctrl.forward().then((_) => _ctrl.reverse().then((_) => widget.onTap()));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: widget.size, height: widget.size,
          decoration: BoxDecoration(
            color: AppColors.darkElevated,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.darkBorder),
            boxShadow: [
              BoxShadow(
                  color: widget.color.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Icon(widget.icon, color: widget.color, size: widget.size * 0.45),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onReset;
  const _EmptyState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🏔️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text("You've seen everyone!",
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary)),
          const SizedBox(height: 8),
          Text('Check back later for new people near you.',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.darkTextSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.buttonGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text('Start Over',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filters Sheet ──────────────────────────────────────────────────────────────

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet();

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  double _maxDistance = 300;
  RangeValues _ageRange = const RangeValues(20, 35);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.darkBorder,
                      borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Discover Filters',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary)),
          const SizedBox(height: 24),
          Text('Maximum Distance: ${_maxDistance.toInt()} km',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTextPrimary)),
          Slider(
            value: _maxDistance,
            min: 10, max: 600,
            activeColor: AppColors.saffron,
            inactiveColor: AppColors.darkBorder,
            onChanged: (v) => setState(() => _maxDistance = v),
          ),
          const SizedBox(height: 12),
          Text(
              'Age Range: ${_ageRange.start.toInt()} – ${_ageRange.end.toInt()}',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTextPrimary)),
          RangeSlider(
            values: _ageRange,
            min: 18, max: 60,
            activeColor: AppColors.saffron,
            inactiveColor: AppColors.darkBorder,
            onChanged: (v) => setState(() => _ageRange = v),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity, height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.buttonGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text('Apply Filters',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
