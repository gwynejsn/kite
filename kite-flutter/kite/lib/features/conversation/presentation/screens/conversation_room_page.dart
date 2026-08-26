import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kite/features/conversation/domain/conversation.dart';
import 'package:kite/features/conversation/domain/conversation_type.dart';
import 'package:kite/features/media/domain/repositories/media_repository.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_controller.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_room_controller.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_room_state.dart';
import 'package:kite/features/conversation/presentation/controllers/conversation_state.dart';
import 'package:kite/features/conversation/presentation/screens/conversation_details_page.dart';
import 'package:kite/features/conversation/presentation/widgets/conversation_room_app_bar.dart';
import 'package:kite/features/conversation/presentation/widgets/date_divider.dart';
import 'package:kite/features/conversation/presentation/widgets/message_bubble.dart';
import 'package:kite/features/conversation/presentation/widgets/message_input_footer.dart';
import 'package:kite/features/presence/presentation/presence_provider.dart';
import 'package:kite/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:kite/shared/security/encryption_service.dart';
import 'package:provider/provider.dart';

class ConversationRoomPage extends StatefulWidget {
  final Conversation conversation;

  const ConversationRoomPage({super.key, required this.conversation});

  @override
  State<ConversationRoomPage> createState() => _ConversationRoomPageState();
}

class _ConversationRoomPageState extends State<ConversationRoomPage> {
  late final ConversationRoomController _controller;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _controller = sl<ConversationRoomController>();
    _controller.initRoom(widget.conversation.id);

    _scrollController.addListener(() {
      final show =
          _scrollController.hasClients && _scrollController.offset > 200;
      if (show != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = show;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSendMessage(
      String? currentUserId, Conversation activeConv) async {
    final content = _textController.text.trim();
    if (content.isNotEmpty && currentUserId != null) {
      _textController.clear();

      String? recipientPublicKey;
      final otherMemberId = activeConv.memberIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
      if (otherMemberId.isNotEmpty) {
        recipientPublicKey = activeConv.memberPublicKeys[otherMemberId];
      }

      String? groupKeyBase64;
      if (activeConv.type == ConversationType.group) {
        groupKeyBase64 = await activeConv.getGroupKey(
          sl<EncryptionService>(),
          currentUserId: currentUserId,
        );
      }

      _controller.sendMessage(
        conversationId: activeConv.id,
        content: content,
        currentUserId: currentUserId,
        recipientPublicKey: recipientPublicKey,
        memberPublicKeys: activeConv.memberPublicKeys,
        groupKeyBase64: groupKeyBase64,
      );
    }
  }

  Future<void> _handlePickMedia(
    String? currentUserId,
    Conversation activeConv, {
    required bool isVideo,
    required ImageSource source,
  }) async {
    if (currentUserId == null) return;

    final mediaRepository = sl<MediaRepository>();
    final pickResult = isVideo
        ? await mediaRepository.pickVideo(source)
        : await mediaRepository.pickImage(source);

    if (pickResult == null) return;

    final caption = _textController.text.trim();
    if (caption.isNotEmpty) {
      _textController.clear();
    }

    String? recipientPublicKey;
    final otherMemberId = activeConv.memberIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    if (otherMemberId.isNotEmpty) {
      recipientPublicKey = activeConv.memberPublicKeys[otherMemberId];
    }

    String? groupKeyBase64;
    if (activeConv.type == ConversationType.group) {
      groupKeyBase64 = await activeConv.getGroupKey(
        sl<EncryptionService>(),
        currentUserId: currentUserId,
      );
    }

    await _controller.sendMediaMessage(
      conversationId: activeConv.id,
      currentUserId: currentUserId,
      mediaType: pickResult.mediaType,
      rawBytes: pickResult.rawBytes,
      fileName: pickResult.fileName,
      caption: caption.isNotEmpty ? caption : null,
      recipientPublicKey: recipientPublicKey,
      memberPublicKeys: activeConv.memberPublicKeys,
      groupKeyBase64: groupKeyBase64,
    );
  }

  Future<void> _handlePickDocumentOrAudio(
    String? currentUserId,
    Conversation activeConv, {
    required bool isAudio,
  }) async {
    if (currentUserId == null) return;

    final mediaRepository = sl<MediaRepository>();
    final pickResult = isAudio
        ? await mediaRepository.pickAudio()
        : await mediaRepository.pickFile();

    if (pickResult == null) return;

    final caption = _textController.text.trim();
    if (caption.isNotEmpty) {
      _textController.clear();
    }

    String? recipientPublicKey;
    final otherMemberId = activeConv.memberIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    if (otherMemberId.isNotEmpty) {
      recipientPublicKey = activeConv.memberPublicKeys[otherMemberId];
    }

    String? groupKeyBase64;
    if (activeConv.type == ConversationType.group) {
      groupKeyBase64 = await activeConv.getGroupKey(
        sl<EncryptionService>(),
        currentUserId: currentUserId,
      );
    }

    await _controller.sendMediaMessage(
      conversationId: activeConv.id,
      currentUserId: currentUserId,
      mediaType: pickResult.mediaType,
      rawBytes: pickResult.rawBytes,
      fileName: pickResult.fileName,
      caption: caption.isNotEmpty ? caption : null,
      recipientPublicKey: recipientPublicKey,
      memberPublicKeys: activeConv.memberPublicKeys,
      groupKeyBase64: groupKeyBase64,
    );
  }

  Future<void> _handleSendVoiceNote(
    String? currentUserId,
    Conversation activeConv,
    Uint8List audioBytes,
    String fileName,
  ) async {
    if (currentUserId == null) return;

    String? recipientPublicKey;
    final otherMemberId = activeConv.memberIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    if (otherMemberId.isNotEmpty) {
      recipientPublicKey = activeConv.memberPublicKeys[otherMemberId];
    }

    String? groupKeyBase64;
    if (activeConv.type == ConversationType.group) {
      groupKeyBase64 = await activeConv.getGroupKey(
        sl<EncryptionService>(),
        currentUserId: currentUserId,
      );
    }

    await _controller.sendMediaMessage(
      conversationId: activeConv.id,
      currentUserId: currentUserId,
      mediaType: 'AUDIO',
      rawBytes: audioBytes,
      fileName: fileName,
      caption: null,
      recipientPublicKey: recipientPublicKey,
      memberPublicKeys: activeConv.memberPublicKeys,
      groupKeyBase64: groupKeyBase64,
    );
  }

  void _openConversationDetailsPage(
      BuildContext context, bool isOnline, Conversation activeConv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationDetailsPage(
          conversation: activeConv,
          isOnline: isOnline,
          onSearchTap: () {
            Navigator.pop(context);
            setState(() {
              _isSearching = true;
            });
          },
        ),
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _formatDateDivider(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (msgDate == today) {
      return 'Today';
    } else if (msgDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      final weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return weekdays[dateTime.weekday - 1];
    }
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ConversationState>(
      valueListenable: sl<ConversationController>(),
      builder: (context, convState, child) {
        final activeConv = convState.conversations.firstWhere(
          (c) => c.id == widget.conversation.id,
          orElse: () => widget.conversation,
        );

        final currentUserId =
            context.watch<UserProfileProvider>().userProfile?.userId;
        final presenceProvider = context.watch<PresenceProvider>();

        final otherMemberId = activeConv.memberIds.firstWhere(
          (id) => id != currentUserId,
          orElse: () => '',
        );
        final isOnline = presenceProvider.isUserOnline(otherMemberId);
        final searchQuery = _searchController.text.trim().toLowerCase();

        return Scaffold(
          appBar: ConversationRoomAppBar(
            conversation: activeConv,
            isOnline: isOnline,
            isSearching: _isSearching,
            searchController: _searchController,
            onSearchChanged: (val) => setState(() {}),
            onToggleSearch: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
            onOpenDetails: () =>
                _openConversationDetailsPage(context, isOnline, activeConv),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/kite_pattern.png',
                  repeat: ImageRepeat.repeat,
                  opacity: const AlwaysStoppedAnimation(0.04),
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<ConversationRoomState>(
                      valueListenable: _controller,
                      builder: (context, state, child) {
                        if (state.isLoading && state.messages.isEmpty) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (state.errorMessage != null &&
                            state.messages.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    state.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => _controller.initRoom(
                                      widget.conversation.id,
                                    ),
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (state.messages.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.mark_chat_read_outlined,
                                  size: 56,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No messages here yet.',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Say hello to start the conversation!',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.7),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.all(16.0),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            final isMe = message.senderId == currentUserId;

                            bool showDateDivider = false;
                            if (index == state.messages.length - 1) {
                              showDateDivider = true;
                            } else {
                              final prevMessageInTime =
                                  state.messages[index + 1];
                              if (!_isSameDay(
                                message.createdAt,
                                prevMessageInTime.createdAt,
                              )) {
                                showDateDivider = true;
                              }
                            }

                            return Column(
                              children: [
                                if (showDateDivider)
                                  DateDivider(
                                    dateText: _formatDateDivider(
                                      message.createdAt,
                                    ),
                                  ),
                                MessageBubble(
                                  message: message,
                                  isMe: isMe,
                                  searchQuery: searchQuery,
                                  conversation: activeConv,
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Floating Scroll To Bottom Button
                  if (_showScrollToBottom)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: FloatingActionButton.small(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        elevation: 4,
                        onPressed: () {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                        child: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ),

                  // Message Input Field Footer
                  MessageInputFooter(
                    textController: _textController,
                    onSend: () => _handleSendMessage(currentUserId, activeConv),
                    onPickImage: (source) => _handlePickMedia(
                      currentUserId,
                      activeConv,
                      isVideo: false,
                      source: source,
                    ),
                    onPickVideo: (source) => _handlePickMedia(
                      currentUserId,
                      activeConv,
                      isVideo: true,
                      source: source,
                    ),
                    onPickFile: () => _handlePickDocumentOrAudio(
                      currentUserId,
                      activeConv,
                      isAudio: false,
                    ),
                    onPickAudio: () => _handlePickDocumentOrAudio(
                      currentUserId,
                      activeConv,
                      isAudio: true,
                    ),
                    onSendVoiceNote: (audioBytes, fileName) =>
                        _handleSendVoiceNote(
                      currentUserId,
                      activeConv,
                      audioBytes,
                      fileName,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
