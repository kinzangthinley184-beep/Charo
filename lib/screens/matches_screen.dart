import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/app_user.dart';
import '../state/app_state.dart';
import 'chat_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  int _matchPct(AppUser u) => 70 + u.id.hashCode.abs() % 28;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final matches = appState.matches;
    final currentUser = appState.currentUser;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(currentUser: currentUser),
            Expanded(
              child: matches.isEmpty
                  ? _EmptyMatches()
                  : _MatchesList(
                      matches: matches,
                      matchPct: _matchPct,
                      currentUser: currentUser,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final AppUser? currentUser;
  const _Header({this.currentUser});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          decoration: const BoxDecoration(
            color: Color(0xB3111111),
            border: Border(
              bottom: BorderSide(color: AppColors.borderThin, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'MATCHES',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white30,
                    letterSpacing: 4.0,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderThin, width: 0.5),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.white60,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _AvatarBadge(user: currentUser),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final AppUser? user;
  const _AvatarBadge({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderThin, width: 0.5),
      ),
      child: ClipOval(
        child: user != null && user!.profileImage.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: user!.profileImage,
                fit: BoxFit.cover,
                httpHeaders: const {
                  'User-Agent':
                      'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
                },
                placeholder: (_, _) =>
                    const ColoredBox(color: Color(0xFF111111)),
                errorWidget: (_, _, _) => _fallback(user!),
              )
            : (user != null ? _fallback(user!) : const SizedBox()),
      ),
    );
  }

  Widget _fallback(AppUser u) {
    return Container(
      color: const Color(0xFF111111),
      child: Center(
        child: Text(
          u.initial,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}


// ── Matches list ───────────────────────────────────────────────────────────────

class _MatchesList extends StatelessWidget {
  final List<AppUser> matches;
  final int Function(AppUser) matchPct;
  final AppUser? currentUser;

  const _MatchesList({
    required this.matches,
    required this.matchPct,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // TEMPORAL PULSE section
        SliverToBoxAdapter(
          child: _SectionLabel(label: 'TEMPORAL PULSE').animate().fadeIn(
                delay: 60.ms,
                duration: 280.ms,
              ),
        ),
        SliverToBoxAdapter(
          child: _PulseRow(
            matches: matches,
            matchPct: matchPct,
            currentUser: currentUser,
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 300.ms)
              .slideX(begin: 0.08, end: 0, delay: 100.ms, duration: 300.ms),
        ),
        // ESTABLISHED BONDS section
        SliverToBoxAdapter(
          child: _SectionLabel(label: 'ESTABLISHED BONDS').animate().fadeIn(
                delay: 160.ms,
                duration: 280.ms,
              ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _BondCard(
                user: matches[i],
                matchPct: matchPct(matches[i]),
                currentUser: currentUser,
              )
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 180 + i * 60),
                    duration: 300.ms,
                  )
                  .slideY(
                    begin: 0.12,
                    end: 0,
                    delay: Duration(milliseconds: 180 + i * 60),
                    duration: 300.ms,
                  ),
              childCount: matches.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 4 / 5,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.white30,
          letterSpacing: 3.5,
        ),
      ),
    );
  }
}

// ── Temporal Pulse (horizontal scroll) ────────────────────────────────────────

class _PulseRow extends StatelessWidget {
  final List<AppUser> matches;
  final int Function(AppUser) matchPct;
  final AppUser? currentUser;

  const _PulseRow({
    required this.matches,
    required this.matchPct,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: matches.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (_, i) => _PulseAvatar(
          user: matches[i],
          currentUser: currentUser,
        ),
      ),
    );
  }
}

class _PulseAvatar extends StatelessWidget {
  final AppUser user;
  final AppUser? currentUser;

  const _PulseAvatar({required this.user, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openChat(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderThin, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.06),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipOval(
              child: user.profileImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: user.profileImage,
                      fit: BoxFit.cover,
                      httpHeaders: const {
                        'User-Agent':
                            'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
                      },
                      placeholder: (_, _) =>
                          const ColoredBox(color: Color(0xFF111111)),
                      errorWidget: (_, _, _) => _fallback(),
                    )
                  : _fallback(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.name,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.white60,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFF111111),
      child: Center(
        child: Text(
          user.initial,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _openChat(BuildContext context) {
    final appState = context.read<AppState>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          user: user,
          currentUser: appState.currentUser,
        ),
      ),
    );
  }
}

// ── Bond card (grid) ───────────────────────────────────────────────────────────

class _BondCard extends StatelessWidget {
  final AppUser user;
  final int matchPct;
  final AppUser? currentUser;

  const _BondCard({
    required this.user,
    required this.matchPct,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final appState = context.read<AppState>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              user: user,
              currentUser: appState.currentUser,
            ),
          ),
        );
      },
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
                  stops: [0.45, 1.0],
                ),
              ),
            ),
            // Match % badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface2.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderThin, width: 0.5),
                ),
                child: Text(
                  '$matchPct%',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Name / age / location
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
        child: Text(
          user.initial,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyMatches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 48,
              color: AppColors.white30,
            ),
            const SizedBox(height: 20),
            Text(
              'No connections yet',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'When someone likes you back\nyou\'ll see them here.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.white30,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
