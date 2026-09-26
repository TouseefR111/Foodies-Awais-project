import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuperAdminChat extends StatefulWidget {
  final String? adminDocumentId;
  final String? adminName;
  final String? adminId;

  const SuperAdminChat({
    super.key,
    this.adminDocumentId,
    this.adminName,
    this.adminId,
  });

  @override
  State<SuperAdminChat> createState() => _SuperAdminChatState();
}

class _SuperAdminChatState extends State<SuperAdminChat> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  bool isSending = false;

  bool get isConversation {
    return widget.adminDocumentId != null && widget.adminDocumentId!.isNotEmpty;
  }

  CollectionReference<Map<String, dynamic>> get messagesCollection {
    return _firestore
        .collection('adminChats')
        .doc(widget.adminDocumentId)
        .collection('messages');
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (isConversation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        markMessagesAsRead();
      });
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> sendMessage() async {
    final String message = messageController.text.trim();

    if (message.isEmpty || isSending) {
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      // ----------------------------------------------------------
      // 1. UPDATE / CREATE MAIN CHAT DOCUMENT
      // ----------------------------------------------------------

      await _firestore
          .collection('adminChats')
          .doc(widget.adminDocumentId)
          .set({
            'adminDocumentId': widget.adminDocumentId,
            'adminId': widget.adminId,
            'adminName': widget.adminName,
            'lastMessage': message,
            'lastMessageAt': FieldValue.serverTimestamp(),
            'lastMessageSender': 'superAdmin',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      // ----------------------------------------------------------
      // 2. SAVE ACTUAL MESSAGE
      // ----------------------------------------------------------

      await messagesCollection.add({
        'message': message,
        'senderId': 'superAdmin',
        'senderName': 'Super Admin',
        'senderRole': 'superAdmin',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      // ----------------------------------------------------------
      // 3. CLEAR INPUT
      // ----------------------------------------------------------

      messageController.clear();

      // ----------------------------------------------------------
      // 4. CLOSE KEYBOARD
      // ----------------------------------------------------------

      if (mounted) {
        FocusScope.of(context).unfocus();
      }

      // ----------------------------------------------------------
      // 5. SCROLL ONLY AFTER SENDING
      // ----------------------------------------------------------

      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        scrollToBottom();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to send message: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  // ============================================================
  // MARK ADMIN MESSAGES AS READ
  // ============================================================

  Future<void> markMessagesAsRead() async {
    if (!isConversation) {
      return;
    }

    try {
      final snapshot = await messagesCollection
          .where('senderRole', isEqualTo: 'admin')
          .where('read', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      final WriteBatch batch = _firestore.batch();

      for (final document in snapshot.docs) {
        batch.update(document.reference, {'read': true});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Unable to mark messages as read: $e');
    }
  }

  // ============================================================
  // CONFIRM CLEAR CHAT
  // ============================================================

  Future<bool> confirmChatAction({
    required String title,
    required String message,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmText, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    return result == true;
  }

  // ============================================================
  // DELETE ALL MESSAGES IN BATCHES
  // ============================================================

  Future<void> deleteAllMessages() async {
    while (true) {
      final snapshot = await messagesCollection.limit(400).get();

      if (snapshot.docs.isEmpty) {
        break;
      }

      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    }
  }

  // ============================================================
  // CLEAR CHAT
  // ============================================================

  Future<void> clearChat() async {
    if (!isConversation) return;

    final confirmed = await confirmChatAction(
      title: 'Clear Chat?',
      message:
          'This will permanently delete all messages in this conversation. '
          'The chat itself will remain available.',
      confirmText: 'Clear',
    );

    if (!confirmed || !mounted) return;

    try {
      await deleteAllMessages();

      await _firestore
          .collection('adminChats')
          .doc(widget.adminDocumentId)
          .set({
            'lastMessage': '',
            'lastMessageAt': null,
            'lastMessageSender': '',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat cleared successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to clear chat: $e')));
    }
  }

  // ============================================================
  // DELETE CHAT
  // ============================================================

  Future<void> deleteChat() async {
    if (!isConversation) return;

    final confirmed = await confirmChatAction(
      title: 'Delete Chat?',
      message:
          'This will permanently delete this conversation and all its messages. '
          'The admin can start a new conversation later.',
      confirmText: 'Delete',
    );

    if (!confirmed || !mounted) return;

    try {
      await deleteAllMessages();

      await _firestore
          .collection('adminChats')
          .doc(widget.adminDocumentId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat deleted successfully.')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to delete chat: $e')));
    }
  }

  // ============================================================
  // SCROLL TO BOTTOM
  // ============================================================

  void scrollToBottom() {
    if (!scrollController.hasClients) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) {
        return;
      }

      final double maxScroll = scrollController.position.maxScrollExtent;

      scrollController.animateTo(
        maxScroll,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String formatTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return '';
    }

    final DateTime date = timestamp.toDate();

    final int hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final String minute = date.minute.toString().padLeft(2, '0');

    final String period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // ============================================================
  // GET LAST MESSAGE
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> lastMessageStream(
    String adminDocumentId,
  ) {
    return _firestore
        .collection('adminChats')
        .doc(adminDocumentId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots();
  }

  // ============================================================
  // GET UNREAD COUNT
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> unreadMessagesStream(
    String adminDocumentId,
  ) {
    return _firestore
        .collection('adminChats')
        .doc(adminDocumentId)
        .collection('messages')
        .where('senderRole', isEqualTo: 'admin')
        .where('read', isEqualTo: false)
        .snapshots();
  }

  // ============================================================
  // ADMIN CHAT LIST
  // ============================================================

  Widget buildAdminChatList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('adminChats').snapshots(),

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Unable to load admin chats.\n\n'
                '${snapshot.error}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.red),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final chats = snapshot.data?.docs ?? [];

        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 70,
                  color: Colors.grey.shade400,
                ),

                const SizedBox(height: 15),

                Text(
                  'No Admin Chats',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Admin conversations will appear here.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final String adminDocumentId = chats[index].id;

            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: _firestore.collection('Admin').doc(adminDocumentId).get(),

              builder: (context, adminSnapshot) {
                if (adminSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 80,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                final Map<String, dynamic>? adminData = adminSnapshot.data
                    ?.data();

                final String adminName =
                    adminData?['name']?.toString() ?? 'Admin';

                final String adminId = adminData?['id']?.toString() ?? '';

                final bool active = adminData?['active'] ?? true;

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: lastMessageStream(adminDocumentId),

                  builder: (context, messageSnapshot) {
                    String lastMessage = 'No messages yet';

                    Timestamp? lastMessageTime;

                    if (messageSnapshot.hasData &&
                        messageSnapshot.data!.docs.isNotEmpty) {
                      final data = messageSnapshot.data!.docs.first.data();

                      lastMessage =
                          data['message']?.toString() ?? 'No messages yet';

                      if (data['createdAt'] is Timestamp) {
                        lastMessageTime = data['createdAt'] as Timestamp;
                      }
                    }

                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: unreadMessagesStream(adminDocumentId),

                      builder: (context, unreadSnapshot) {
                        final int unreadCount =
                            unreadSnapshot.data?.docs.length ?? 0;

                        return buildChatCard(
                          adminDocumentId: adminDocumentId,
                          adminName: adminName,
                          adminId: adminId,
                          active: active,
                          lastMessage: lastMessage,
                          lastMessageTime: lastMessageTime,
                          unreadCount: unreadCount,
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // ============================================================
  // ADMIN CHAT CARD
  // ============================================================

  Widget buildChatCard({
    required String adminDocumentId,
    required String adminName,
    required String adminId,
    required bool active,
    required String lastMessage,
    required Timestamp? lastMessageTime,
    required int unreadCount,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SuperAdminChat(
                adminDocumentId: adminDocumentId,
                adminName: adminName,
                adminId: adminId,
              ),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(14),

          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: active ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(
                  Icons.person,
                  size: 28,
                  color: active
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            adminName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),

                    if (adminId.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'ID: $adminId',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),

                        if (lastMessageTime != null) ...[
                          const SizedBox(width: 8),

                          Text(
                            formatTime(lastMessageTime),
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active ? Colors.green : Colors.orange,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Text(
                          active ? 'Active' : 'Inactive',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: active
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE BUBBLE
  // ============================================================

  Widget messageBubble(Map<String, dynamic> data) {
    final String senderRole = data['senderRole']?.toString() ?? '';

    final bool isSuperAdmin = senderRole == 'superAdmin';

    final String message = data['message']?.toString() ?? '';

    final Timestamp? timestamp = data['createdAt'] is Timestamp
        ? data['createdAt'] as Timestamp
        : null;

    return Align(
      alignment: isSuperAdmin ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),

        margin: EdgeInsets.only(
          left: isSuperAdmin ? 50 : 10,
          right: isSuperAdmin ? 10 : 50,
          top: 5,
          bottom: 5,
        ),

        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),

        decoration: BoxDecoration(
          gradient: isSuperAdmin
              ? const LinearGradient(
                  colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,

          color: isSuperAdmin ? null : Colors.white,

          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isSuperAdmin ? 16 : 4),
            bottomRight: Radius.circular(isSuperAdmin ? 4 : 16),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Align(
              alignment: Alignment.centerLeft,

              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),

            if (timestamp != null) ...[
              const SizedBox(height: 5),

              Text(
                formatTime(timestamp),
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONVERSATION SCREEN
  // ============================================================

  Widget buildConversation() {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFECB04),

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'clear') {
                clearChat();
              } else if (value == 'delete') {
                deleteChat();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services_outlined),
                    SizedBox(width: 10),
                    Text('Clear Chat'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Delete Chat', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.adminName ?? 'Admin',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            Text(
              'Admin ID: ${widget.adminId ?? ''}',
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87),
            ),
          ],
        ),

        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Column(
        children: [
          // ======================================================
          // ADMIN INFORMATION
          // ======================================================
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(13),

            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.shade200),
            ),

            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.orange.shade100,
                  child: Icon(Icons.person, color: Colors.orange.shade800),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.adminName ?? 'Admin',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        'Admin ID: ${widget.adminId ?? ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.chat, color: Colors.orange),
              ],
            ),
          ),

          // ======================================================
          // CHAT
          // ======================================================
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: messagesCollection
                  .orderBy('createdAt', descending: false)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Unable to load messages.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'No messages yet',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Send a message to this admin.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // IMPORTANT:
                //
                // DO NOT scroll here.
                //
                // This StreamBuilder can rebuild when:
                // - keyboard opens
                // - keyboard closes
                // - message changes
                // - read status changes
                //
                // Scrolling here causes the shaking.

                return ListView.builder(
                  controller: scrollController,

                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.manual,

                  padding: const EdgeInsets.only(top: 8, bottom: 10),

                  itemCount: messages.length,

                  itemBuilder: (context, index) {
                    return messageBubble(messages[index].data());
                  },
                );
              },
            ),
          ),

          // ======================================================
          // MESSAGE INPUT
          // ======================================================
          SafeArea(
            top: false,

            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),

              decoration: const BoxDecoration(color: Colors.white),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  // ==================================================
                  // TEXT FIELD
                  // ==================================================
                  Expanded(
                    child: TextField(
                      controller: messageController,

                      minLines: 1,
                      maxLines: 5,

                      textCapitalization: TextCapitalization.sentences,

                      keyboardType: TextInputType.multiline,

                      textInputAction: TextInputAction.newline,

                      // Do NOT send when pressing
                      // keyboard action.
                      //
                      // This prevents the keyboard
                      // from closing unexpectedly.
                      onSubmitted: (_) {},

                      decoration: InputDecoration(
                        hintText: 'Type your message...',

                        hintStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey,
                        ),

                        filled: true,

                        fillColor: Colors.grey.shade100,

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: Colors.orange.shade400,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ==================================================
                  // SEND BUTTON
                  // ==================================================
                  Container(
                    width: 50,
                    height: 50,

                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,

                      gradient: LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),

                    child: IconButton(
                      onPressed: isSending ? null : sendMessage,

                      icon: isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.black,
                              size: 22,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (isConversation) {
      return buildConversation();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFECB04),
        centerTitle: true,

        title: Text(
          'Admin Chats',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),

        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: buildAdminChatList(),
    );
  }
}
