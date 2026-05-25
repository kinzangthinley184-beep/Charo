import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_colors.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onPass;
  final VoidCallback onLike;

  const ActionButtons({
    super.key,
    required this.onPass,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleButton(
          size: 62,
          onTap: onPass,
          backgroundColor: AppColors.surface2,
          border: Border.all(color: AppColors.borderThin, width: 0.5),
          child: const Icon(Icons.close_rounded,
              color: AppColors.white60, size: 28),
        ),
        const SizedBox(width: 24),
        _CircleButton(
          size: 72,
          onTap: onLike,
          backgroundColor: Colors.white,
          child: const Icon(Icons.favorite_rounded,
              color: Colors.black, size: 32),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 80.ms)
        .slideY(begin: 0.2, end: 0, duration: 300.ms, delay: 80.ms,
            curve: Curves.easeOutCubic);
  }
}

// ── Circle button ──────────────────────────────────────────────────────────────

class _CircleButton extends StatefulWidget {
  final double size;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Border? border;
  final Widget child;

  const _CircleButton({
    required this.size,
    required this.onTap,
    required this.backgroundColor,
    this.border,
    required this.child,
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
      child: AnimatedScale(
        scale: _pressed ? 0.91 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            shape: BoxShape.circle,
            border: widget.border,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
