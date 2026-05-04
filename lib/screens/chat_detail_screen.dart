import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/app_user.dart';
import '../data/mock_data.dart';
import '../widgets/verified_badge.dart';

class ChatDetailScreen extends StatefulWidget {
  final AppUser user;
  final List<ChatMessage> messages;
  final void Function(String) onSendMessage;
  // Called when an auto-reply arrives so the parent can update shared state.
  final void Function(String userId, String text)? onReceiveMessage;

  const ChatDetailScreen({
    super.key,
    required this.user,
    required this.messages,
    required this.onSendMessage,
    this.onReceiveMessage,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late List<ChatMessage> _messages;

  static const _autoReplies = [
    'That sounds amazing! 😊',
    'Tell me more about that!',
    'Haha, yes! Bhutan is so beautiful 🏔️',
    'I totally agree!',
    'We should definitely meet up in Thimphu!',
    'Have you tried the Ema Datshi there? 🌶️',
    'That\'s so cool! Where exactly?',
    'I love that area! Great hiking trails.',
  ];

  @override
  void initState() {
    super.initState();
    _messages = widget.messages
        .map((m) => m.senderId != kCurrentUserId ? m.copyWith(isRead: true) : m)
        .toList();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: kCurrentUserId,
        text: text,
        timestamp: DateTime.now(),
        isRead: true,
      ));
      _textCtrl.clear();
    });
    widget.onSendMessage(text);
    _scrollToBottom();

    final reply = _autoReplies[_messages.length % _autoReplies.length];
    Timer(Duration(milliseconds: 800 + math.Random().nextInt(600)), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          id: '${DateTime.now().millisecondsSinceEpoch}r',
          senderId: widget.user.id,
          text: reply,
          timestamp: DateTime.now(),
          isRead: true,
        ));
      });
      _scrollToBottom();
      widget.onReceiveMessage?.call(widget.user.id, reply);
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.darkTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: widget.user.gradient),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(widget.user.initial,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(widget.user.name,
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkTextPrimary)),
                    if (widget.user.isVerified) ...[
                      const SizedBox(width: 4),
                      const VerifiedBadge(size: 15),
                    ],
                  ],
                ),
                Text(widget.user.location,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.darkTextSecondary)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.darkTextSecondary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.darkBorder),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.darkSurface,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('You matched with ${widget.user.name} 🎉',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.darkTextSecondary)),
              ],
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? _EmptyChat(user: widget.user)
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      final isMe = msg.senderId == kCurrentUserId;
                      final showTime = i == 0 ||
                          _messages[i]
                                  .timestamp
                                  .difference(_messages[i - 1].timestamp)
                                  .inMinutes >
                              5;
                      return Column(
                        children: [
                          if (showTime)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                _formatTime(msg.timestamp),
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.darkTextSecondary),
                              ),
                            ),
                          _MessageBubble(message: msg, isMe: isMe),
                        ],
                      );
                    },
                  ),
          ),
          _InputBar(controller: _textCtrl, onSend: _send),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    if (now.difference(t).inHours < 1) {
      return '${now.difference(t).inMinutes}m ago';
    }
    if (t.day == now.day) {
      return 'Today ${t.hour}:${t.minute.toString().padLeft(2, '0')}';
    }
    return '${t.day}/${t.month} ${t.hour}:${t.minute.toString().padLeft(2, '0')}';
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4, bottom: 4,
          left: isMe ? 60 : 0,
          right: isMe ? 0 : 60,
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.saffron : AppColors.darkElevated,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Text(
          message.text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isMe ? Colors.white : AppColors.darkTextPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final has = widget.controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  void _onSend() {
    if (!_hasText) return;
    widget.onSend();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 12),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(top: BorderSide(color: AppColors.darkBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darkElevated,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: TextField(
                controller: widget.controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.darkTextPrimary),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 14, color: AppColors.darkTextSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedOpacity(
            opacity: _hasText ? 1.0 : 0.35,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: _onSend,
              child: Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  final AppUser user;
  const _EmptyChat({required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: user.gradient),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(user.initial,
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))),
          ),
          const SizedBox(height: 16),
          Text('Say hi to ${user.name}! 👋',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary)),
          const SizedBox(height: 6),
          Text('You matched! Start the conversation.',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.darkTextSecondary)),
        ],
      ),
    );
  }
}
