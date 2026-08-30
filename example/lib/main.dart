import 'package:flutter/material.dart';
import 'package:flutter_swipe_to_reply/flutter_swipe_to_reply.dart';

void main() => runApp(const SwipeToReplyExampleApp());

class SwipeToReplyExampleApp extends StatelessWidget {
  const SwipeToReplyExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF087E8B);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swipe to reply',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF7F9FA),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF40C9A2),
          brightness: Brightness.dark,
        ),
      ),
      home: const ConversationPage(),
    );
  }
}

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final _composerController = TextEditingController();
  final _focusNode = FocusNode();
  final _messages = <_Message>[
    const _Message(
      id: 1,
      sender: 'Avery',
      text: 'Can you send the revised schedule?',
      time: '10:24',
    ),
    const _Message(
      id: 2,
      sender: 'You',
      text: 'Yes, I moved the launch review to Thursday.',
      time: '10:25',
      isMine: true,
    ),
    const _Message(
      id: 3,
      sender: 'Avery',
      text: 'Perfect, I will update the team.',
      time: '10:26',
    ),
  ];
  _Message? _replyTarget;

  @override
  void dispose() {
    _composerController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _selectReplyTarget(_Message message) {
    setState(() => _replyTarget = message);
    _focusNode.requestFocus();
  }

  void _sendMessage() {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _Message(
          id: _messages.last.id + 1,
          sender: 'You',
          text: text,
          time: 'Now',
          isMine: true,
        ),
      );
      _replyTarget = null;
      _composerController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 36,
        titleSpacing: 8,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE9B872),
              child: Text('AC'),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Avery Chen'),
                Text('Online', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Video call',
            onPressed: () {},
            icon: const Icon(Icons.videocam_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 18),
                itemCount: _messages.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return SwipeToReply(
                    key: ValueKey('message-${message.id}'),
                    direction: message.isMine
                        ? SwipeToReplyDirection.left
                        : SwipeToReplyDirection.right,
                    hapticRearmDistance: 6,
                    onReply: () => _selectReplyTarget(message),
                    child: Align(
                      alignment: message.isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: _MessageBubble(message: message),
                    ),
                  );
                },
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: _replyTarget == null
                  ? const SizedBox.shrink()
                  : Container(
                      key: ValueKey(_replyTarget!.id),
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 9, 8, 9),
                      color: colors.surfaceContainerHigh,
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 38,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Replying to ${_replyTarget!.sender}',
                                  key: const Key('reply-target-label'),
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _replyTarget!.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Cancel reply',
                            onPressed: () =>
                                setState(() => _replyTarget = null),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.outlineVariant)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _composerController,
                        focusNode: _focusNode,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: 'Message',
                          filled: true,
                          fillColor: colors.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filled(
                      tooltip: 'Send',
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _Message message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = message.isMine
        ? colors.primaryContainer
        : colors.surfaceContainerHighest;
    final foreground = message.isMine
        ? colors.onPrimaryContainer
        : colors.onSurface;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(message.text, style: TextStyle(color: foreground)),
              const SizedBox(height: 4),
              Text(
                message.time,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground.withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message {
  const _Message({
    required this.id,
    required this.sender,
    required this.text,
    required this.time,
    this.isMine = false,
  });

  final int id;
  final String sender;
  final String text;
  final String time;
  final bool isMine;
}
