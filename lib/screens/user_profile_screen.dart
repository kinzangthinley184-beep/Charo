import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/app_user.dart';
import '../state/app_state.dart';
import '../widgets/verified_badge.dart';

class UserProfileScreen extends StatefulWidget {
  final AppUser user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  AppUser get user => widget.user;

  void _showBlockReportSheet(BuildContext context, AppUser user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                user.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'What would you like to do?',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),
            _sheetOption(
              context: context,
              icon: Icons.block_rounded,
              label: 'Block ${user.name}',
              sublabel: "They won't be able to see your profile",
              color: Colors.white,
              onTap: () {
                Navigator.pop(context);
                _confirmBlock(context, user);
              },
            ),
            _sheetOption(
              context: context,
              icon: Icons.flag_outlined,
              label: 'Report ${user.name}',
              sublabel: 'Harassment, fake profile, inappropriate content',
              color: const Color(0xFFFF4444),
              onTap: () {
                Navigator.pop(context);
                _showReportSheet(context, user);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 22),
      title: Text(label,
          style: TextStyle(
              color: color, fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(sublabel,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3), fontSize: 12)),
    );
  }

  void _confirmBlock(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Block ${user.name}?',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500)),
        content: Text(
          "They won't appear in your Discover feed and you won't appear in theirs.",
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
              height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style:
                    TextStyle(color: Colors.white.withValues(alpha: 0.4))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AppState>().blockUser(user.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Block',
                style: TextStyle(color: Color(0xFFFF4444))),
          ),
        ],
      ),
    );
  }

  void _showReportSheet(BuildContext context, AppUser user) {
    const reasons = [
      'Fake profile',
      'Inappropriate photos',
      'Harassment or threats',
      'Spam',
      'Underage user',
      'Other',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Report ${user.name}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Select a reason',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 13)),
            ),
            const SizedBox(height: 12),
            ...reasons.map((r) => ListTile(
                  title: Text(r,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14)),
                  trailing: Icon(Icons.chevron_right,
                      color: Colors.white.withValues(alpha: 0.3), size: 18),
                  onTap: () async {
                    Navigator.pop(context);
                    await context.read<AppState>().reportUser(user.id, r);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report submitted. Thank you.'),
                          backgroundColor: Color(0xFF1A1A1A),
                        ),
                      );
                    }
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _AppBar(
                user: user,
                onMoreTap: () => _showBlockReportSheet(context, user),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NameRow(user: user),
                      const SizedBox(height: 8),
                      _MetaRow(user: user),
                      if (user.bio.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _Section(
                          title: 'About',
                          child: Text(
                            user.bio,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.darkTextPrimary,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                      if (user.interests.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _Section(
                          title: 'Interests',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: user.interests
                                .map((tag) => _InterestChip(label: tag))
                                .toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _AboutMeSection(user: user),
                      if (user.photos != null && user.photos!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _Section(
                          title: 'Photos',
                          child: _PhotosGrid(photos: user.photos!),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          _ActionBar(user: user),
        ],
      ),
    );
  }
}

// ── App bar with avatar ───────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final AppUser user;
  final VoidCallback onMoreTap;
  const _AppBar({required this.user, required this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.darkBg,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: onMoreTap,
        ),
      ],
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.darkSurface.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: const Icon(Icons.arrow_back_rounded,
              color: AppColors.darkTextPrimary, size: 20),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.darkSurface,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: user.gradient,
                    ),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: user.gradient[1].withValues(alpha: 0.5),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user.initial,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Name row ─────────────────────────────────────────────────────────────────

class _NameRow extends StatelessWidget {
  final AppUser user;
  const _NameRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            user.age > 0 ? '${user.name}, ${user.age}' : user.name,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
            ),
          ),
        ),
        if (user.verified) ...[
          const SizedBox(width: 8),
          const VerifiedBadge(size: 24),
        ],
      ],
    );
  }
}

// ── Meta row (location + distance) ───────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final AppUser user;
  const _MetaRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        if (user.location.isNotEmpty)
          _Badge(
            icon: Icons.location_on_rounded,
            label: user.location,
            color: AppColors.saffron,
          ),
        if (user.distance.isNotEmpty)
          _Badge(
            icon: Icons.near_me_rounded,
            label: user.distance,
            color: AppColors.nearbyTeal,
          ),
        if (user.occupation.isNotEmpty)
          _Badge(
            icon: Icons.work_outline_rounded,
            label: user.occupation,
            color: AppColors.darkTextSecondary,
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color)),
        ],
      ),
    );
  }
}

// ── Section wrapper ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextPrimary)),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.darkBorder,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

// ── Interest chip ─────────────────────────────────────────────────────────────

class _InterestChip extends StatelessWidget {
  final String label;
  const _InterestChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.darkElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.darkTextPrimary)),
    );
  }
}

// ── About Me section ─────────────────────────────────────────────────────────

class _AboutMeSection extends StatelessWidget {
  final AppUser user;
  const _AboutMeSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final rows = <_AboutRow>[
      if (user.education != null && user.education!.isNotEmpty)
        _AboutRow(icon: Icons.school_outlined, label: 'Education', value: user.education!),
      if (user.lookingFor != null && user.lookingFor!.isNotEmpty)
        _AboutRow(icon: Icons.favorite_border_rounded, label: 'Looking For', value: user.lookingFor!),
      if (user.height != null && user.height!.isNotEmpty)
        _AboutRow(icon: Icons.height_rounded, label: 'Height', value: user.height!),
      if (user.zodiacSign != null && user.zodiacSign!.isNotEmpty)
        _AboutRow(icon: Icons.auto_awesome_rounded, label: 'Zodiac', value: user.zodiacSign!),
      if (user.bhutaneseZodiac != null && user.bhutaneseZodiac!.isNotEmpty)
        _AboutRow(icon: Icons.brightness_3_rounded, label: 'Bhutanese Zodiac', value: user.bhutaneseZodiac!),
      if (user.religion != null && user.religion!.isNotEmpty)
        _AboutRow(icon: Icons.temple_buddhist_outlined, label: 'Religion', value: user.religion!),
      if (user.ethnicity != null && user.ethnicity!.isNotEmpty)
        _AboutRow(icon: Icons.people_outline_rounded, label: 'Ethnicity', value: user.ethnicity!),
      if (user.languages != null && user.languages!.isNotEmpty)
        _AboutRow(icon: Icons.translate_rounded, label: 'Languages', value: user.languages!),
      if (user.drinkingHabit != null && user.drinkingHabit!.isNotEmpty)
        _AboutRow(icon: Icons.local_bar_outlined, label: 'Drinking', value: user.drinkingHabit!),
      if (user.smokingHabit != null && user.smokingHabit!.isNotEmpty)
        _AboutRow(icon: Icons.smoking_rooms_outlined, label: 'Smoking', value: user.smokingHabit!),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return _Section(
      title: 'About Me',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          children: [
            for (int i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i < rows.length - 1)
                Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.darkDivider,
                    indent: 16,
                    endIndent: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AboutRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.saffron),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.darkTextSecondary)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkTextPrimary)),
        ],
      ),
    );
  }
}

// ── Photos grid ───────────────────────────────────────────────────────────────

class _PhotosGrid extends StatelessWidget {
  final List<String> photos;
  const _PhotosGrid({required this.photos});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: photos.length,
      itemBuilder: (_, i) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          photos[i],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            color: AppColors.darkElevated,
            child: const Icon(Icons.broken_image_outlined,
                color: AppColors.darkTextMuted),
          ),
        ),
      ),
    );
  }
}

// ── Action bar ────────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final AppUser user;
  const _ActionBar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(40, 16, 40, 36),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBg.withValues(alpha: 0.0),
              AppColors.darkBg.withValues(alpha: 0.95),
              AppColors.darkBg,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CircleButton(
              size: 64,
              borderColor: const Color(0xFFCC2200),
              bgColor: AppColors.darkElevated,
              icon: Icons.close_rounded,
              iconColor: const Color(0xFFFF3300),
              label: 'Nope',
              labelColor: const Color(0xFFFF3300),
              onTap: () => Navigator.pop(context, 'pass'),
            ),
            const SizedBox(width: 52),
            _CircleButton(
              size: 72,
              borderColor: const Color(0xFF00AA44),
              bgColor: const Color(0xFF0D2010),
              icon: Icons.favorite_rounded,
              iconColor: const Color(0xFF00DD55),
              label: 'Like',
              labelColor: const Color(0xFF00DD55),
              onTap: () => Navigator.pop(context, 'like'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatefulWidget {
  final double size;
  final Color borderColor;
  final Color bgColor;
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color labelColor;
  final VoidCallback onTap;

  const _CircleButton({
    required this.size,
    required this.borderColor,
    required this.bgColor,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.labelColor,
    required this.onTap,
  });

  @override
  State<_CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<_CircleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: _pressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: widget.borderColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: widget.borderColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(widget.icon,
                  color: widget.iconColor, size: widget.size * 0.42),
            ),
          ),
          const SizedBox(height: 6),
          Text(widget.label,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.labelColor)),
        ],
      ),
    );
  }
}
