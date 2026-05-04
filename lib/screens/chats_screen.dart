import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/app_user.dart';
import '../data/mock_data.dart';
import 'chat_detail_screen.dart';

class ChatsScreen extends StatelessWidget {
  final List<AppUser> matches;
  final Map<String, List<ChatMessage>> conversations;
  final void Function(String userId, String text) onSendMessage;
  final void Function(String userId, String text) onReceiveMessage;

  const ChatsScreen({
    super.key,
    required this.matches,
    required this.conversations,
    required this.onSendMessage,
    required this.onReceiveMessage,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...matches]..sort((a, b) {
        final aLast = (conversations[a.id] ?? []).lastOrNull?.timestamp ??
            DateTime(2000);
        final bLast = (conversations[b.id] ?? []).lastOrNull?.timestamp ??
            DateTime(2000);
        return bLast.compareTo(aLast);
      });

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
                  Text('Chats',
                      style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkTextPrimary)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search_rounded,
                        color: AppColors.darkTextSecondary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            if (matches.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text('New Matches',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkTextSecondary)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: matches.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _MatchBubble(
                    user: matches[i],
                    onTap: () => _openChat(context, matches[i]),
                  ),
                ),
              ),
              Divider(height: 24, color: AppColors.darkDivider),
            ],

            if (sorted.isEmpty)
              Expanded(
                child: Center(
                  child: Text('No matches yet – start swiping! 💫',
                      style: GoogleFonts.poppins(
                          color: AppColors.darkTextSecondary)),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  itemCount: sorted.length,
                  separatorBuilder: (_, _) => Divider(
                      height: 1,
                      indent: 80,
                      color: AppColors.darkDivider),
                  itemBuilder: (_, i) {
                    final user = sorted[i];
                    final msgs = conversations[user.id] ?? [];
                    final last = msgs.lastOrNull;
                    final unread = msgs
                        .where((m) =>
                            m.senderId != kCurrentUserId && !m.isRead)
                        .length;
                    return _ChatTile(
                      user: user,
                      lastMessage: last?.text ?? 'Say hi! 👋',
                      time: last?.timestamp,
                      unread: unread,
                      onTap: () => _openChat(context, user),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openChat(BuildContext context, AppUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _LiveChatScreen(
          user: user,
          initialMessages: List.from(conversations[user.id] ?? []),
          onSend: (text) => onSendMessage(user.id, text),
          onReceive: (text) => onReceiveMessage(user.id, text),
        ),
      ),
    );
  }
}

// ── Live Chat Screen wrapper ───────────────────────────────────────────────────
// Thin wrapper so ChatsScreen can wire onSend/onReceive without needing to
// know the internal details of ChatDetailScreen.

class _LiveChatScreen extends StatelessWidget {
  final AppUser user;
  final List<ChatMessage> initialMessages;
  final void Function(String) onSend;
  final void Function(String) onReceive;

  const _LiveChatScreen({
    required this.user,
    required this.initialMessages,
    required this.onSend,
    required this.onReceive,
  });

  @override
  Widget build(BuildContext context) {
    return ChatDetailScreen(
      user: user,
      messages: initialMessages,
      onSendMessage: onSend,
      onReceiveMessage: (_, text) => onReceive(text),
    );
  }
}

// ── Match bubble ──────────────────────────────────────────────────────────────

class _MatchBubble extends StatelessWidget {
  final AppUser user;
  final VoidCallback onTap;

  const _MatchBubble({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58, height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: user.gradient),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.matchPink, width: 2.5),
            ),
            child: Center(
              child: Text(user.initial,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(height: 5),
          Text(user.name,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTextPrimary)),
        ],
      ),
    );
  }
}

// ── Chat tile ──────────────────────────────────────────────────────────────────

class _ChatTile extends StatelessWidget {
  final AppUser user;
  final String lastMessage;
  final DateTime? time;
  final int unread;
  final VoidCallback onTap;

  const _ChatTile({
    required this.user,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = time == null ? '' : _formatTime(time!);
    return ListTile(
      tileColor: Colors.transparent,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 54, height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: user.gradient),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(user.initial,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
      ),
      title: Text('${user.name}, ${user.age}',
          style: GoogleFonts.poppins(
            fontWeight:
                unread > 0 ? FontWeight.w700 : FontWeight.w600,
            fontSize: 15,
            color: AppColors.darkTextPrimary,
          )),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: unread > 0
              ? AppColors.saffron
              : AppColors.darkTextSecondary,
          fontWeight:
              unread > 0 ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(timeStr,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.darkTextSecondary)),
          if (unread > 0) ...[
            const SizedBox(height: 4),
            Container(
              width: 20, height: 20,
              decoration: const BoxDecoration(
                  color: AppColors.saffron, shape: BoxShape.circle),
              child: Center(
                child: Text('$unread',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    if (now.difference(t).inMinutes < 60) {
      return '${now.difference(t).inMinutes}m';
    }
    if (t.day == now.day) {
      return '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
    }
    return '${t.day}/${t.month}';
  }
}
