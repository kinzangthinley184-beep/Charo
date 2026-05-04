import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../data/bhutan_profile_data.dart';
import '../data/mock_data.dart';
import '../models/app_user.dart';
import '../widgets/verified_badge.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends StatefulWidget {
  final bool isPremium;
  final VoidCallback onUpgrade;
  const ProfileScreen({super.key, required this.isPremium, required this.onUpgrade});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _planTab = 0;
  late AppUser _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = kCurrentUser;
  }

  double _calculateCompletion(AppUser user) {
    int score = 0;
    if ((user.photos ?? []).isNotEmpty) score += 20;
    if (user.occupation.isNotEmpty) score += 15;
    if (user.education?.isNotEmpty == true) score += 10;
    if (user.interests.length >= 3) score += 10;
    if (user.height?.isNotEmpty == true) score += 5;
    if (user.zodiacSign?.isNotEmpty == true) score += 5;
    if (user.religion?.isNotEmpty == true) score += 5;
    if (user.ethnicity?.isNotEmpty == true) score += 5;
    if (user.drinkingHabit?.isNotEmpty == true) score += 5;
    if (user.smokingHabit?.isNotEmpty == true) score += 5;
    if (user.lookingFor?.isNotEmpty == true) score += 10;
    if (user.languages?.isNotEmpty == true) score += 5;
    return score / 100.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildProfileRow()
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.1, duration: 600.ms, curve: Curves.easeOut),
              const SizedBox(height: 20),
              _buildPlanTabs(),
              const SizedBox(height: 20),
              if (_planTab == 0) ...[
                _buildFeatureCards(),
                const SizedBox(height: 16),
                _buildSubscriptionCarousel(),
                const SizedBox(height: 24),
                _buildWhatYouGet(),
              ] else
                _buildSafetyWellbeing(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Text('Profile', style: GoogleFonts.poppins(
            fontSize: 26, fontWeight: FontWeight.w700,
            color: AppColors.darkTextPrimary)),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline_rounded,
                color: AppColors.darkTextSecondary)),
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.darkTextSecondary)),
        ],
      ),
    );
  }

  Widget _buildProfileRow() {
    final user = _currentUser;
    final completion = _calculateCompletion(user);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          SizedBox(
            width: 80, height: 80,
            child: Stack(
              children: [
                CustomPaint(size: const Size(80, 80),
                    painter: _CompletionRingPainter(completion)),
                Center(
                  child: Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: user.gradient),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(user.initial,
                      style: const TextStyle(fontSize: 26,
                          fontWeight: FontWeight.bold, color: Colors.white))),
                  ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(10)),
                      child: Text('${(completion * 100).toInt()}%',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(user.name, style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w700,
                    color: AppColors.darkTextPrimary)),
                  const SizedBox(width: 6),
                  const VerifiedBadge(size: 20),
                ]),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showCompleteProfile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.darkBorder, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Complete profile', style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.darkTextPrimary)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _PlanTab(label: 'Pay plan', selected: _planTab == 0,
              onTap: () => setState(() => _planTab = 0)),
          const SizedBox(width: 28),
          _PlanTab(label: 'Safety and wellbeing', selected: _planTab == 1,
              onTap: () => setState(() => _planTab = 1)),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _FeatureCard(icon: Icons.add_circle_rounded,
            title: 'Spotlight', subtitle: 'Stand out',
            onTap: () => _showPremiumModal('Spotlight'))
              .animate(delay: 200.ms)
              .fadeIn(duration: 500.ms)
              .slideX(begin: -0.1, duration: 500.ms)),
          const SizedBox(width: 12),
          Expanded(child: _FeatureCard(icon: Icons.star_rounded,
            title: 'SuperSwipe', subtitle: 'Get noticed',
            onTap: () => _showPremiumModal('SuperSwipe'))
              .animate(delay: 300.ms)
              .fadeIn(duration: 500.ms)
              .slideX(begin: 0.1, duration: 500.ms)),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCarousel() {
    return SizedBox(
      height: 190,
      child: PageView(
        controller: PageController(viewportFraction: 0.88),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 8),
            child: _PremiumCard(isPremium: widget.isPremium,
                onExplore: _showFullPremiumModal)),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 20),
            child: _BoostCard(onExplore: () => _showPremiumModal('Boost'))),
        ],
      ),
    );
  }

  Widget _buildWhatYouGet() {
    final features = [
      ('Unlimited likes', true, false),
      ('See who liked you', true, false),
      ('Advanced filters', true, false),
      ('Incognito mode', true, false),
      ('Travel mode', true, false),
      ('Read receipts', true, true),
      ('Rematch expired connections', true, true),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('What you get:', style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary)),
            const Spacer(),
            Text('Premium', style: GoogleFonts.poppins(fontSize: 13,
              fontWeight: FontWeight.w700,
              color: widget.isPremium ? AppColors.gold : AppColors.darkTextPrimary)),
            const SizedBox(width: 16),
            Text('Boost', style: GoogleFonts.poppins(fontSize: 13,
              fontWeight: FontWeight.w700, color: AppColors.darkTextSecondary)),
          ]),
          const SizedBox(height: 8),
          Divider(color: AppColors.darkBorder),
          ...features.map((f) => _FeatureRow(
            label: f.$1, premium: f.$2, boost: f.$3,
            isPremiumActive: widget.isPremium)),
        ],
      ),
    );
  }

  Widget _buildSafetyWellbeing() {
    final items = [
      (Icons.block_rounded, 'Block & Report', 'Control who can contact you'),
      (Icons.visibility_off_rounded, 'Incognito Mode', 'Browse without being seen'),
      (Icons.verified_user_rounded, 'Profile Verification', 'Verify your identity'),
      (Icons.location_off_rounded, 'Location Privacy', 'Control your location sharing'),
      (Icons.shield_rounded, 'Safety Resources', 'Access help and resources'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: items.map((item) => _SafetyTile(
          icon: item.$1, title: item.$2, subtitle: item.$3)).toList(),
      ),
    );
  }

  void _showPremiumModal(String feature) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PremiumBottomSheet(feature: feature,
        isPremium: widget.isPremium, onUpgrade: () {
          Navigator.pop(context);
          widget.onUpgrade();
        }),
    );
  }

  void _showFullPremiumModal() {
    if (widget.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already have Charo Premium! ✨')));
      return;
    }
    _showPremiumModal('Charo Premium');
  }

  void _showCompleteProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CompleteProfileSheet(
        user: _currentUser,
        onUpdate: (updated) => setState(() => _currentUser = updated),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
            color: AppColors.darkBorder, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Settings', style: GoogleFonts.poppins(fontSize: 20,
            fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary)),
          const SizedBox(height: 16),
          ...['Edit Profile', 'Notifications', 'Privacy', 'Help & Support', 'Log Out']
            .map((item) => ListTile(
              title: Text(item, style: GoogleFonts.poppins(
                color: item == 'Log Out' ? AppColors.matchPink : AppColors.darkTextPrimary)),
              trailing: item == 'Log Out' ? null
                : const Icon(Icons.chevron_right_rounded,
                    color: AppColors.darkTextSecondary),
              onTap: () => Navigator.pop(context))),
        ]),
      ),
    );
  }
}

// ── Plan Tab (fixed: IntrinsicWidth avoids infinite-width crash) ───────────

class _PlanTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PlanTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(label, style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? AppColors.darkTextPrimary : AppColors.darkTextSecondary)),
            const SizedBox(height: 5),
            if (selected)
              Container(height: 2.5,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(2))),
          ],
        ),
      ),
    );
  }
}

// ── Feature card ──────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _FeatureCard({required this.icon, required this.title,
      required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.darkElevated, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.gold, size: 20)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 14,
              fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary)),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 12,
              color: AppColors.darkTextSecondary)),
          ]),
        ]),
      ),
    );
  }
}

// ── Premium card ──────────────────────────────────────────────────────────

class _PremiumCard extends StatelessWidget {
  final bool isPremium;
  final VoidCallback onExplore;
  const _PremiumCard({required this.isPremium, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.premiumYellow,
        borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.darkBg,
            borderRadius: BorderRadius.circular(6)),
          child: Text('CHARO+', style: GoogleFonts.poppins(fontSize: 16,
            fontWeight: FontWeight.w900, color: AppColors.premiumYellow,
            letterSpacing: 1))),
        const SizedBox(height: 10),
        Text(isPremium ? 'You have Charo Premium! ✨'
            : 'See who likes you and connect faster.',
          style: GoogleFonts.poppins(fontSize: 14,
            fontWeight: FontWeight.w500, color: AppColors.darkBg)),
        const Spacer(),
        GestureDetector(
          onTap: onExplore,
          child: Container(
            width: double.infinity, height: 44,
            decoration: BoxDecoration(
              color: AppColors.darkBg,
              borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(
              isPremium ? 'Manage Plan' : 'Explore Premium',
              style: GoogleFonts.poppins(fontSize: 14,
                fontWeight: FontWeight.w700, color: Colors.white))))),
      ]),
    );
  }
}

class _BoostCard extends StatelessWidget {
  final VoidCallback onExplore;
  const _BoostCard({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.darkTextSecondary, width: 2),
            borderRadius: BorderRadius.circular(6)),
          child: Text('BOOST', style: GoogleFonts.poppins(fontSize: 16,
            fontWeight: FontWeight.w900, color: AppColors.darkTextPrimary,
            letterSpacing: 1))),
        const SizedBox(height: 10),
        Text('More profile views.\nBoost your visibility.', style: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w500,
          color: AppColors.darkTextPrimary)),
        const Spacer(),
        GestureDetector(
          onTap: onExplore,
          child: Container(
            width: double.infinity, height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text('Get Boost', style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))))),
      ]),
    );
  }
}

// ── Feature comparison row ────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final String label;
  final bool premium;
  final bool boost;
  final bool isPremiumActive;
  const _FeatureRow({required this.label, required this.premium,
      required this.boost, required this.isPremiumActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Expanded(child: Text(label, style: GoogleFonts.poppins(
          fontSize: 14, color: AppColors.darkTextPrimary))),
        SizedBox(width: 60, child: Center(child: premium
          ? Icon(Icons.check_rounded,
              color: isPremiumActive ? AppColors.gold : AppColors.darkTextPrimary,
              size: 20)
          : Icon(Icons.check_rounded, color: AppColors.darkBorder, size: 20))),
        SizedBox(width: 50, child: Center(child: boost
          ? Icon(Icons.check_rounded, color: AppColors.darkTextSecondary, size: 20)
          : const SizedBox())),
      ]),
    );
  }
}

class _SafetyTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SafetyTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.saffron.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.saffron, size: 22)),
      title: Text(title, style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600, fontSize: 14,
        color: AppColors.darkTextPrimary)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(
        fontSize: 12, color: AppColors.darkTextSecondary)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.darkTextSecondary),
      onTap: () {},
    );
  }
}

// ── Premium bottom sheet ──────────────────────────────────────────────────

class _PremiumBottomSheet extends StatelessWidget {
  final String feature;
  final bool isPremium;
  final VoidCallback onUpgrade;
  const _PremiumBottomSheet({required this.feature,
      required this.isPremium, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(
          color: AppColors.darkBorder,
          borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 24),
        Container(width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppColors.premiumYellow,
            borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.star_rounded, color: Colors.white, size: 32)),
        const SizedBox(height: 16),
        Text(feature, style: GoogleFonts.poppins(fontSize: 22,
          fontWeight: FontWeight.w800, color: AppColors.darkTextPrimary)),
        const SizedBox(height: 8),
        Text(isPremium
          ? 'You already have access to $feature!'
          : 'Upgrade to Charo+ to unlock $feature.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 14,
            color: AppColors.darkTextSecondary, height: 1.5)),
        const SizedBox(height: 28),
        if (!isPremium) ...[
          _PriceCard(price: 'Nu. 199/month', label: 'Monthly', best: false),
          const SizedBox(height: 8),
          _PriceCard(price: 'Nu. 999/6 months', label: '6 Months', best: true),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onUpgrade,
            child: Container(
              width: double.infinity, height: 54,
              decoration: BoxDecoration(
                color: AppColors.premiumYellow,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                  color: AppColors.premiumYellow.withValues(alpha: 0.3),
                  blurRadius: 16, offset: const Offset(0, 6))]),
              child: Center(child: Text('Upgrade to Charo+',
                style: GoogleFonts.poppins(fontSize: 16,
                  fontWeight: FontWeight.w800, color: AppColors.darkBg))))),
        ] else
          Container(
            width: double.infinity, height: 54,
            decoration: BoxDecoration(color: AppColors.likeGreen,
              borderRadius: BorderRadius.circular(16)),
            child: Center(child: Text('Already Unlocked ✓',
              style: GoogleFonts.poppins(fontSize: 16,
                fontWeight: FontWeight.w700, color: Colors.white)))),
      ]),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String price;
  final String label;
  final bool best;
  const _PriceCard({required this.price, required this.label, required this.best});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: best
          ? AppColors.premiumYellow.withValues(alpha: 0.1)
          : AppColors.darkElevated,
        border: Border.all(
          color: best ? AppColors.premiumYellow : AppColors.darkBorder,
          width: 1.5),
        borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Text(label, style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary)),
        if (best) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.premiumYellow,
              borderRadius: BorderRadius.circular(6)),
            child: Text('BEST VALUE', style: GoogleFonts.poppins(
              fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.darkBg))),
        ],
        const Spacer(),
        Text(price, style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary)),
      ]),
    );
  }
}

// ── Complete profile sheet ────────────────────────────────────────────────

class _CompleteProfileSheet extends StatefulWidget {
  final AppUser user;
  final void Function(AppUser) onUpdate;
  const _CompleteProfileSheet({required this.user, required this.onUpdate});

  @override
  State<_CompleteProfileSheet> createState() => _CompleteProfileSheetState();
}

class _CompleteProfileSheetState extends State<_CompleteProfileSheet> {
  late AppUser _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  int _score() {
    int s = 0;
    if ((_user.photos ?? []).isNotEmpty) s += 20;
    if (_user.occupation.isNotEmpty) s += 15;
    if (_user.education?.isNotEmpty == true) s += 10;
    if (_user.interests.length >= 3) s += 10;
    if (_user.height?.isNotEmpty == true) s += 5;
    if (_user.zodiacSign?.isNotEmpty == true) s += 5;
    if (_user.religion?.isNotEmpty == true) s += 5;
    if (_user.ethnicity?.isNotEmpty == true) s += 5;
    if (_user.drinkingHabit?.isNotEmpty == true) s += 5;
    if (_user.smokingHabit?.isNotEmpty == true) s += 5;
    if (_user.lookingFor?.isNotEmpty == true) s += 10;
    if (_user.languages?.isNotEmpty == true) s += 5;
    return s;
  }

  void _update(AppUser u) {
    setState(() => _user = u);
    widget.onUpdate(u);
  }

  void _picker(String title, List<String> options, String? current, void Function(String) onSelect) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => _PickerSheet(title: title, options: options, currentValue: current, onSelect: onSelect),
    );
  }

  void _textEditor(String title, String hint, String? current, void Function(String) onSave) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => _TextEditorSheet(title: title, hint: hint, currentValue: current, onSave: onSave),
    );
  }

  Widget _row({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDone,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: isDone ? AppColors.likeGreen.withValues(alpha: 0.15) : AppColors.gold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isDone ? AppColors.likeGreen : AppColors.gold, size: 22),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.darkTextPrimary)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: isDone ? AppColors.saffron : AppColors.darkTextSecondary)),
      trailing: isDone
          ? const Icon(Icons.check_circle_rounded, color: AppColors.likeGreen)
          : const Icon(Icons.add_circle_outline_rounded, color: AppColors.darkTextSecondary),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final score = _score();
    final photos = _user.photos ?? [];
    final langs = (_user.languages ?? '').split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.darkBorder, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text('Complete your profile', style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary)),
                const SizedBox(height: 4),
                Text('$score% complete — profiles with more info get 3x more connections!',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.darkTextSecondary)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100.0,
                    backgroundColor: AppColors.darkElevated,
                    color: AppColors.saffron,
                    minHeight: 8,
                  ),
                ),
              ]),
            ),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                children: [
                  _row(
                    icon: Icons.photo_camera_rounded,
                    title: 'Add photos',
                    subtitle: photos.isEmpty ? 'Add up to 6 photos' : '${photos.length} photos added',
                    isDone: photos.isNotEmpty,
                    onTap: () => showModalBottomSheet(
                      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
                      builder: (_) => _PhotosEditorSheet(
                        photos: photos,
                        onSave: (p) => _update(_user.copyWith(photos: p)),
                      ),
                    ),
                  ),
                  _row(
                    icon: Icons.work_outline_rounded,
                    title: 'Occupation',
                    subtitle: _user.occupation.isNotEmpty ? _user.occupation : 'What do you do?',
                    isDone: _user.occupation.isNotEmpty,
                    onTap: () => _textEditor('Your occupation', 'e.g. Civil Servant, Teacher, Monk...', _user.occupation, (v) => _update(_user.copyWith(occupation: v))),
                  ),
                  _row(
                    icon: Icons.school_outlined,
                    title: 'Education',
                    subtitle: _user.education ?? 'Highest qualification',
                    isDone: _user.education?.isNotEmpty == true,
                    onTap: () => _picker('Education level', kEducationLevels, _user.education, (v) => _update(_user.copyWith(education: v))),
                  ),
                  _row(
                    icon: Icons.favorite_outline_rounded,
                    title: 'Looking for',
                    subtitle: _user.lookingFor ?? 'What are you here for?',
                    isDone: _user.lookingFor?.isNotEmpty == true,
                    onTap: () => _picker('I am looking for...', kLookingFor, _user.lookingFor, (v) => _update(_user.copyWith(lookingFor: v))),
                  ),
                  _row(
                    icon: Icons.interests_rounded,
                    title: 'Interests',
                    subtitle: _user.interests.isEmpty ? 'What do you love?' : _user.interests.take(3).join(' · '),
                    isDone: _user.interests.length >= 3,
                    onTap: () => showModalBottomSheet(
                      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
                      builder: (_) => _InterestsEditorSheet(
                        selected: List.from(_user.interests),
                        onSave: (interests) => _update(_user.copyWith(interests: interests)),
                      ),
                    ),
                  ),
                  _row(
                    icon: Icons.language_rounded,
                    title: 'Languages',
                    subtitle: _user.languages ?? 'Languages you speak',
                    isDone: _user.languages?.isNotEmpty == true,
                    onTap: () => showModalBottomSheet(
                      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
                      builder: (_) => _MultiPickerSheet(
                        title: 'Languages you speak',
                        options: kLanguages,
                        selectedValues: langs,
                        onSave: (v) => _update(_user.copyWith(languages: v)),
                      ),
                    ),
                  ),
                  _row(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Zodiac sign',
                    subtitle: _user.zodiacSign ?? 'Western zodiac',
                    isDone: _user.zodiacSign?.isNotEmpty == true,
                    onTap: () => _picker('Your zodiac sign', kZodiacSigns, _user.zodiacSign, (v) => _update(_user.copyWith(zodiacSign: v))),
                  ),
                  _row(
                    icon: Icons.pets_rounded,
                    title: 'Bhutanese zodiac',
                    subtitle: _user.bhutaneseZodiac ?? 'Losar birth animal',
                    isDone: _user.bhutaneseZodiac?.isNotEmpty == true,
                    onTap: () => _picker('Your birth year animal', kBhutaneseZodiacAnimals, _user.bhutaneseZodiac, (v) => _update(_user.copyWith(bhutaneseZodiac: v))),
                  ),
                  _row(
                    icon: Icons.temple_buddhist_rounded,
                    title: 'Religion',
                    subtitle: _user.religion ?? 'Optional',
                    isDone: _user.religion?.isNotEmpty == true,
                    onTap: () => _picker('Religion', kReligions, _user.religion, (v) => _update(_user.copyWith(religion: v))),
                  ),
                  _row(
                    icon: Icons.people_outline_rounded,
                    title: 'Ethnicity',
                    subtitle: _user.ethnicity ?? 'Optional',
                    isDone: _user.ethnicity?.isNotEmpty == true,
                    onTap: () => _picker('Ethnicity', kEthnicities, _user.ethnicity, (v) => _update(_user.copyWith(ethnicity: v))),
                  ),
                  _row(
                    icon: Icons.height_rounded,
                    title: 'Height',
                    subtitle: _user.height ?? 'Optional',
                    isDone: _user.height?.isNotEmpty == true,
                    onTap: () => _picker('Your height', kHeights, _user.height, (v) => _update(_user.copyWith(height: v))),
                  ),
                  _row(
                    icon: Icons.local_bar_outlined,
                    title: 'Drinking',
                    subtitle: _user.drinkingHabit ?? 'Optional',
                    isDone: _user.drinkingHabit?.isNotEmpty == true,
                    onTap: () => _picker('Drinking habits', kDrinkingHabits, _user.drinkingHabit, (v) => _update(_user.copyWith(drinkingHabit: v))),
                  ),
                  _row(
                    icon: Icons.smoking_rooms_outlined,
                    title: 'Smoking',
                    subtitle: _user.smokingHabit ?? 'Optional',
                    isDone: _user.smokingHabit?.isNotEmpty == true,
                    onTap: () => _picker('Smoking habits', kSmokingHabits, _user.smokingHabit, (v) => _update(_user.copyWith(smokingHabit: v))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Picker sheet ──────────────────────────────────────────────────────────

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? currentValue;
  final void Function(String) onSelect;

  const _PickerSheet({
    required this.title,
    required this.options,
    required this.currentValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: [
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.darkBorder, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary)),
            const SizedBox(height: 16),
            ...options.map((opt) {
              final selected = opt == currentValue;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    onSelect(opt);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.saffron : AppColors.darkElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(opt, style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      color: selected ? Colors.white : AppColors.darkTextPrimary,
                    )),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Multi-picker sheet ────────────────────────────────────────────────────

class _MultiPickerSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<String> selectedValues;
  final void Function(String) onSave;

  const _MultiPickerSheet({
    required this.title,
    required this.options,
    required this.selectedValues,
    required this.onSave,
  });

  @override
  State<_MultiPickerSheet> createState() => _MultiPickerSheetState();
}

class _MultiPickerSheetState extends State<_MultiPickerSheet> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.darkBorder, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text(widget.title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary)),
                const SizedBox(height: 8),
              ]),
            ),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.options.length,
                itemBuilder: (_, i) {
                  final opt = widget.options[i];
                  final selected = _selected.contains(opt);
                  return CheckboxListTile(
                    value: selected,
                    onChanged: (_) => setState(() {
                      if (selected) { _selected.remove(opt); } else { _selected.add(opt); }
                    }),
                    title: Text(opt, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.darkTextPrimary)),
                    activeColor: AppColors.saffron,
                    checkColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.trailing,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              child: GestureDetector(
                onTap: () {
                  widget.onSave(_selected.join(', '));
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity, height: 54,
                  decoration: BoxDecoration(gradient: AppColors.buttonGradient, borderRadius: BorderRadius.circular(16)),
                  child: Center(child: Text('Save', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Text editor sheet ─────────────────────────────────────────────────────

class _TextEditorSheet extends StatefulWidget {
  final String title;
  final String hint;
  final String? currentValue;
  final void Function(String) onSave;

  const _TextEditorSheet({
    required this.title,
    required this.hint,
    required this.currentValue,
    required this.onSave,
  });

  @override
  State<_TextEditorSheet> createState() => _TextEditorSheetState();
}

class _TextEditorSheetState extends State<_TextEditorSheet> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentValue ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.darkBorder, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(widget.title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                cursorColor: AppColors.saffron,
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.darkTextPrimary),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.darkTextSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (_) {
                  final v = _ctrl.text.trim();
                  if (v.isNotEmpty) { widget.onSave(v); Navigator.pop(context); }
                },
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                final v = _ctrl.text.trim();
                if (v.isNotEmpty) { widget.onSave(v); Navigator.pop(context); }
              },
              child: Container(
                width: double.infinity, height: 54,
                decoration: BoxDecoration(gradient: AppColors.buttonGradient, borderRadius: BorderRadius.circular(16)),
                child: Center(child: Text('Save', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Interests editor sheet ────────────────────────────────────────────────

const List<String> _kAllInterests = [
  'Archery', 'Dzongkha poetry', 'Tsechu festival', 'Hiking', 'Butter tea',
  'Ema Datshi', 'Thangka painting', 'Traditional music', 'Farming', 'Meditation',
  'GNH philosophy', 'Football', 'Basketball', 'Cooking', 'Photography',
  'Travel', 'Reading', 'Movies', 'Gaming', 'Fitness', 'Dancing', 'Fashion',
  'Technology', 'Business', 'Art', 'Music', 'Volunteering',
];

class _InterestsEditorSheet extends StatefulWidget {
  final List<String> selected;
  final void Function(List<String>) onSave;

  const _InterestsEditorSheet({required this.selected, required this.onSave});

  @override
  State<_InterestsEditorSheet> createState() => _InterestsEditorSheetState();
}

class _InterestsEditorSheetState extends State<_InterestsEditorSheet> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.darkBorder, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text('Interests', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary)),
                const SizedBox(height: 4),
                Text('Pick at least 3', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.darkTextSecondary)),
                const SizedBox(height: 16),
              ]),
            ),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                children: [
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _kAllInterests.map((interest) {
                      final isSelected = _selected.contains(interest);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isSelected) { _selected.remove(interest); } else { _selected.add(interest); }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.saffron : AppColors.darkElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? AppColors.saffron : AppColors.darkBorder),
                          ),
                          child: Text(interest, style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? Colors.white : AppColors.darkTextSecondary,
                          )),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              child: GestureDetector(
                onTap: () { widget.onSave(_selected); Navigator.pop(context); },
                child: Container(
                  width: double.infinity, height: 54,
                  decoration: BoxDecoration(gradient: AppColors.buttonGradient, borderRadius: BorderRadius.circular(16)),
                  child: Center(child: Text('Save', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Photos editor sheet ───────────────────────────────────────────────────

class _PhotosEditorSheet extends StatefulWidget {
  final List<String> photos;
  final void Function(List<String>) onSave;

  const _PhotosEditorSheet({required this.photos, required this.onSave});

  @override
  State<_PhotosEditorSheet> createState() => _PhotosEditorSheetState();
}

class _PhotosEditorSheetState extends State<_PhotosEditorSheet> {
  late List<String> _photos;

  @override
  void initState() {
    super.initState();
    _photos = List.from(widget.photos);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.darkBorder, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text('Add photos', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary)),
                const SizedBox(height: 4),
                Text('Your first photo is your main profile photo',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.darkTextSecondary)),
              ]),
            ),
            Expanded(
              child: GridView.count(
                controller: ctrl,
                crossAxisCount: 3,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: List.generate(6, (i) {
                  final hasPhoto = i < _photos.length;
                  return GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Photo upload coming soon!')),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: hasPhoto ? null : AppColors.darkElevated,
                        gradient: hasPhoto ? AppColors.headerGradient : null,
                        borderRadius: BorderRadius.circular(12),
                        border: hasPhoto ? null : Border.all(color: AppColors.darkBorder, width: 1.5),
                      ),
                      child: hasPhoto
                          ? Center(child: Text(_photos[i][0].toUpperCase(),
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_rounded,
                                    color: i == 0 ? AppColors.saffron : AppColors.darkTextSecondary,
                                    size: 28),
                                const SizedBox(height: 4),
                                if (i == 0)
                                  Text('Add photo', style: GoogleFonts.poppins(
                                    fontSize: 11, color: AppColors.saffron, fontWeight: FontWeight.w600)),
                              ],
                            ),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: GestureDetector(
                onTap: () { widget.onSave(_photos); Navigator.pop(context); },
                child: Container(
                  width: double.infinity, height: 54,
                  decoration: BoxDecoration(gradient: AppColors.buttonGradient, borderRadius: BorderRadius.circular(16)),
                  child: Center(child: Text('Done', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Completion ring painter ───────────────────────────────────────────────

class _CompletionRingPainter extends CustomPainter {
  final double progress;
  _CompletionRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 3;
    canvas.drawCircle(Offset(cx, cy), r,
      Paint()..color = AppColors.darkBorder
        ..style = PaintingStyle.stroke..strokeWidth = 4);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2, 2 * math.pi * progress, false,
      Paint()..color = AppColors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_CompletionRingPainter old) => old.progress != progress;
}
