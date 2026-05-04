import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../data/mock_data.dart';

class LikedYouScreen extends StatelessWidget {
  final bool isPremium;
  final VoidCallback onUpgrade;

  const LikedYouScreen(
      {super.key, required this.isPremium, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    final likedYou = kDiscoverUsers.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text('Liked You',
                      style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkTextPrimary)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.matchPink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${likedYou.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (!isPremium) _PremiumBanner(onUpgrade: onUpgrade),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: likedYou.length,
                itemBuilder: (_, i) => _LikedCard(
                  user: likedYou[i],
                  isRevealed: isPremium,
                  onReveal: onUpgrade,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  final VoidCallback onUpgrade;
  const _PremiumBanner({required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUpgrade,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.premiumYellow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_open_rounded,
                color: AppColors.darkBg, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upgrade to Charo+',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBg)),
                  Text('See everyone who likes you',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.darkBg.withValues(alpha: 0.7))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.darkBg),
          ],
        ),
      ),
    );
  }
}

class _LikedCard extends StatelessWidget {
  final dynamic user;
  final bool isRevealed;
  final VoidCallback onReveal;

  const _LikedCard(
      {required this.user,
      required this.isRevealed,
      required this.onReveal});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isRevealed ? null : onReveal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: user.gradient,
                ),
              ),
              child: Center(
                child: Text(
                  isRevealed ? user.initial : '?',
                  style: TextStyle(
                    fontSize: isRevealed ? 64 : 80,
                    fontWeight: FontWeight.w900,
                    color: Colors.white
                        .withValues(alpha: isRevealed ? 0.15 : 0.4),
                  ),
                ),
              ),
            ),
            if (!isRevealed)
              Container(
                color: Colors.black.withValues(alpha: 0.55),
              ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black
                          .withValues(alpha: isRevealed ? 0.75 : 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRevealed
                          ? '${user.name}, ${user.age}'
                          : '••• ••',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    Text(
                      isRevealed ? user.location : '•••••',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            if (!isRevealed)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: AppColors.premiumYellow, size: 28),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
