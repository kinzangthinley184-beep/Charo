import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/app_user.dart';

class ProfileCard extends StatefulWidget {
  final AppUser user;
  final AppUser? nextUser;
  final VoidCallback onLike;
  final VoidCallback onPass;

  const ProfileCard({
    super.key,
    required this.user,
    this.nextUser,
    required this.onLike,
    required this.onPass,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard>
    with TickerProviderStateMixin {
  Offset _drag = Offset.zero;
  bool _isFlying = false;
  late AnimationController _snapCtrl;
  late Animation<Offset> _snapAnim;

  static const double _threshold = 100.0;
  static const double _maxRotation = 18 * math.pi / 180;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _snapAnim = Tween(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _snapCtrl, curve: Curves.elasticOut),
    );
    _snapCtrl.addListener(() => setState(() => _drag = _snapAnim.value));
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails _) {
    if (_isFlying) return;
    _snapCtrl.stop();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_isFlying) return;
    setState(() => _drag += d.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isFlying) return;
    final vx = details.velocity.pixelsPerSecond.dx;
    if (_drag.dx > _threshold || vx > 600) {
      _flyOut(right: true);
    } else if (_drag.dx < -_threshold || vx < -600) {
      _flyOut(right: false);
    } else {
      _snapAnim = Tween(begin: _drag, end: Offset.zero).animate(
        CurvedAnimation(parent: _snapCtrl, curve: Curves.elasticOut),
      );
      _snapCtrl.forward(from: 0);
    }
  }

  void _flyOut({required bool right}) {
    if (_isFlying) return;
    setState(() => _isFlying = true);
    HapticFeedback.mediumImpact();
    final sw = MediaQuery.of(context).size.width;
    final flyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    final flyAnim = Tween(
      begin: _drag,
      end: Offset(right ? sw * 1.8 : -sw * 1.8, _drag.dy - 60),
    ).animate(CurvedAnimation(parent: flyCtrl, curve: Curves.easeIn));
    flyAnim.addListener(() => setState(() => _drag = flyAnim.value));
    flyCtrl.forward().then((_) {
      flyCtrl.dispose();
      right ? widget.onLike() : widget.onPass();
    });
  }

  int get _matchPct => 70 + widget.user.id.hashCode.abs() % 28;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final dragRatio = (_drag.dx.abs() / (sw * 0.4)).clamp(0.0, 1.0);
    final angle =
        (_drag.dx / 400).clamp(-_maxRotation, _maxRotation).toDouble();
    final likeOpacity = (_drag.dx / _threshold).clamp(0.0, 1.0);
    final nopeOpacity = (-_drag.dx / _threshold).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Next card behind ───────────────────────────────────────────────
        if (widget.nextUser != null)
          Transform.scale(
            scale: 0.88 + 0.08 * dragRatio,
            child: Opacity(
              opacity: 0.2 + 0.3 * dragRatio,
              child: _CardVisual(
                user: widget.nextUser!,
                matchPct: 70 + widget.nextUser!.id.hashCode.abs() % 28,
              ),
            ),
          ),
        // ── Current card (draggable) ───────────────────────────────────────
        GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Transform.translate(
            offset: _drag,
            child: Transform.rotate(
              angle: angle,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _CardVisual(user: widget.user, matchPct: _matchPct),
                  if (likeOpacity > 0)
                    Positioned(
                      top: 48,
                      left: 28,
                      child: _SwipeLabel(
                        label: 'LIKE',
                        color: AppColors.likeGreen,
                        opacity: likeOpacity.toDouble(),
                      ),
                    ),
                  if (nopeOpacity > 0)
                    Positioned(
                      top: 48,
                      right: 28,
                      child: _SwipeLabel(
                        label: 'NOPE',
                        color: AppColors.errorRed,
                        opacity: nopeOpacity.toDouble(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Card visual ────────────────────────────────────────────────────────────────

class _CardVisual extends StatelessWidget {
  final AppUser user;
  final int matchPct;

  const _CardVisual({required this.user, required this.matchPct});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo / fallback
          user.profileImage.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: user.profileImage,
                  fit: BoxFit.cover,
                  httpHeaders: const {
                    'User-Agent':
                        'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
                  },
                  placeholder: (_, _) => _shimmer(),
                  errorWidget: (_, _, _) => _fallback(),
                )
              : _fallback(),

          // Bottom gradient overlay
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Color(0x80000000),
                  Color(0xCC000000),
                ],
                stops: [0.0, 0.45, 0.72, 1.0],
              ),
            ),
          ),

          // Match % badge — top right
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surface2.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderThin, width: 0.5),
              ),
              child: Text(
                '$matchPct%',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Name / location — bottom
          Positioned(
            bottom: 28,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${user.name}, ${user.age}',
                  style: GoogleFonts.outfit(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                if (user.location.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppColors.white60, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        user.location.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white60,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmer() => Container(color: const Color(0xFF1A1A1A));

  Widget _fallback() {
    return Container(
      color: const Color(0xFF111111),
      child: Center(
        child: Text(
          user.initial,
          style: TextStyle(
            fontSize: 100,
            fontWeight: FontWeight.w900,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}

// ── Swipe label ────────────────────────────────────────────────────────────────

class _SwipeLabel extends StatelessWidget {
  final String label;
  final Color color;
  final double opacity;

  const _SwipeLabel({
    required this.label,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.rotate(
        angle: label == 'LIKE' ? -0.22 : 0.22,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }
}
